import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import 'package:nexacalc/core/interfaces/decimal_engine.dart';

/// Concrete implementation of [DecimalEngine] using a recursive-descent parser.
///
/// All arithmetic is performed exclusively with the [Decimal] type from the
/// `decimal` package. Dart [double] is never used for intermediate or final
/// computation (Requirement 1.1).
///
/// Grammar (EBNF):
///   expression  = term ( ('+' | '-') term )*
///   term        = factor ( ('*' | '/') factor )*
///   factor      = '-' factor | primary
///   primary     = NUMBER ['%'] | 'sqrt' '(' expression ')' | '(' expression ')'
///
/// Percentage rewriting is context-aware and happens at the operator level
/// during parsing (Requirement 7):
///   - In additive context (+ or -): A op B%  →  A op (A * B / 100)
///   - In multiplicative context (* or /): A op B%  →  A op (B / 100)
///   - Standalone B% (no preceding operator+operand): B / 100
///
/// Division results are [Rational] values (from the `rational` package, a
/// transitive dependency of `decimal`). They are converted back to [Decimal]
/// using [toDecimal] with [scaleOnInfinitePrecision] = 20 to handle repeating
/// decimals such as 1/3 without throwing.
class DecimalEngineImpl implements DecimalEngine {
  @override
  DecimalResult evaluate(String expression) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) {
      return DecimalSyntaxError('Empty expression');
    }
    try {
      final tokens = _tokenize(trimmed);
      final parser = _Parser(tokens);
      final result = parser.parseExpression();
      // Ensure all tokens were consumed
      if (!parser.isAtEnd) {
        return DecimalSyntaxError(
          'Unexpected token: ${parser.currentToken}',
        );
      }
      return DecimalSuccess(result);
    } on _DivisionByZeroException {
      return DecimalDivisionByZero();
    } on _ComplexResultException {
      return DecimalComplexResult();
    } on _SyntaxException catch (e) {
      return DecimalSyntaxError(e.message);
    } catch (e) {
      return DecimalSyntaxError('Invalid expression: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// Precision constant for converting Rational → Decimal
// ---------------------------------------------------------------------------

/// Number of decimal places to use when converting a [Rational] with infinite
/// precision (e.g. 1/3) to a [Decimal].
const int _kScale = 20;

/// Converts a [Rational] (result of Decimal division) to [Decimal].
///
/// Uses [scaleOnInfinitePrecision] = [_kScale] to handle repeating decimals
/// such as 1/3 without throwing a [StateError].
Decimal _rationalToDecimal(Rational rational) {
  return rational.toDecimal(scaleOnInfinitePrecision: _kScale);
}

// ---------------------------------------------------------------------------
// Token types
// ---------------------------------------------------------------------------

enum _TokenType {
  number,
  plus,
  minus,
  star,
  slash,
  percent,
  lparen,
  rparen,
  sqrt,
  eof,
}

class _Token {
  final _TokenType type;
  final String lexeme;

  const _Token(this.type, this.lexeme);

  @override
  String toString() => 'Token($type, "$lexeme")';
}

// ---------------------------------------------------------------------------
// Tokenizer
// ---------------------------------------------------------------------------

/// Converts an expression string into a flat list of [_Token]s.
///
/// Recognises: numbers (integer and decimal), +, -, *, /, %, (, ), sqrt.
/// Whitespace is ignored.
List<_Token> _tokenize(String source) {
  final tokens = <_Token>[];
  int i = 0;

  while (i < source.length) {
    final ch = source[i];

    // Skip whitespace
    if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
      i++;
      continue;
    }

    // Number: digits with optional decimal point
    if (_isDigit(ch) ||
        (ch == '.' && i + 1 < source.length && _isDigit(source[i + 1]))) {
      final start = i;
      while (i < source.length && _isDigit(source[i])) {
        i++;
      }
      if (i < source.length && source[i] == '.') {
        i++;
        while (i < source.length && _isDigit(source[i])) {
          i++;
        }
      }
      tokens.add(_Token(_TokenType.number, source.substring(start, i)));
      continue;
    }

    // Identifier: sqrt (only supported function)
    if (_isAlpha(ch)) {
      final start = i;
      while (i < source.length && _isAlpha(source[i])) {
        i++;
      }
      final word = source.substring(start, i);
      if (word == 'sqrt') {
        tokens.add(const _Token(_TokenType.sqrt, 'sqrt'));
      } else {
        throw _SyntaxException('Unknown identifier: $word');
      }
      continue;
    }

    switch (ch) {
      case '+':
        tokens.add(const _Token(_TokenType.plus, '+'));
      case '-':
        tokens.add(const _Token(_TokenType.minus, '-'));
      case '*':
        tokens.add(const _Token(_TokenType.star, '*'));
      case '/':
        tokens.add(const _Token(_TokenType.slash, '/'));
      case '%':
        tokens.add(const _Token(_TokenType.percent, '%'));
      case '(':
        tokens.add(const _Token(_TokenType.lparen, '('));
      case ')':
        tokens.add(const _Token(_TokenType.rparen, ')'));
      default:
        throw _SyntaxException('Unexpected character: $ch');
    }
    i++;
  }

  tokens.add(const _Token(_TokenType.eof, ''));
  return tokens;
}

bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
bool _isAlpha(String ch) {
  final c = ch.codeUnitAt(0);
  return (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95;
}

// ---------------------------------------------------------------------------
// Recursive-descent parser
// ---------------------------------------------------------------------------

/// Parses a token list into a [Decimal] value using recursive descent.
///
/// The parser is strictly left-associative for all binary operators.
///
/// Percentage context-awareness:
///   - `A + B%` → `A + (A * B / 100)`  (additive: relative to left operand)
///   - `A - B%` → `A - (A * B / 100)`  (additive: relative to left operand)
///   - `A * B%` → `A * (B / 100)`      (multiplicative: simple fraction)
///   - `A / B%` → `A / (B / 100)`      (multiplicative: simple fraction)
///   - standalone `B%` → `B / 100`     (no preceding operator)
class _Parser {
  final List<_Token> _tokens;
  int _pos = 0;

  _Parser(this._tokens);

  _Token get currentToken => _tokens[_pos];

  bool get isAtEnd => currentToken.type == _TokenType.eof;

  _Token _advance() {
    final t = _tokens[_pos];
    if (_pos < _tokens.length - 1) _pos++;
    return t;
  }

  bool _check(_TokenType type) => currentToken.type == type;

  bool _match(_TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  _Token _expect(_TokenType type, String errorMsg) {
    if (!_check(type)) {
      throw _SyntaxException(errorMsg);
    }
    return _advance();
  }

  // -------------------------------------------------------------------------
  // expression = term ( ('+' | '-') term )*
  //
  // Left-associative. Percentage context-awareness for + and -:
  //   A + B%  →  A + (A * B / 100)
  //   A - B%  →  A - (A * B / 100)
  // -------------------------------------------------------------------------
  Decimal parseExpression() {
    Decimal left = _parseTerm();

    while (_check(_TokenType.plus) || _check(_TokenType.minus)) {
      final op = _advance();

      // Parse the right-hand factor, capturing whether it ends with %
      final (rightRaw, isPercent) = _parseFactorWithPercentFlag();

      if (isPercent) {
        // Context-aware: A +/- B%  →  A +/- (A * B / 100)
        final percentValue = _rationalToDecimal(
          left * rightRaw / Decimal.fromInt(100),
        );
        if (op.type == _TokenType.plus) {
          left = left + percentValue;
        } else {
          left = left - percentValue;
        }
      } else {
        // Normal additive: complete the right-hand term (handle * / after it)
        final right = _completeTerm(rightRaw);
        if (op.type == _TokenType.plus) {
          left = left + right;
        } else {
          left = left - right;
        }
      }
    }

    return left;
  }

  // -------------------------------------------------------------------------
  // term = factor ( ('*' | '/') factor )*
  //
  // Left-associative. Percentage context-awareness for * and /:
  //   A * B%  →  A * (B / 100)
  //   A / B%  →  A / (B / 100)
  // -------------------------------------------------------------------------
  Decimal _parseTerm() {
    Decimal left = _parseFactor();

    while (_check(_TokenType.star) || _check(_TokenType.slash)) {
      final op = _advance();
      final (rightRaw, isPercent) = _parseFactorWithPercentFlag();

      final Decimal right;
      if (isPercent) {
        // A * B%  →  A * (B / 100)
        // A / B%  →  A / (B / 100)
        right = _rationalToDecimal(rightRaw / Decimal.fromInt(100));
      } else {
        right = rightRaw;
      }

      if (op.type == _TokenType.star) {
        left = left * right;
      } else {
        if (right == Decimal.zero) {
          throw _DivisionByZeroException();
        }
        left = _rationalToDecimal(left / right);
      }
    }

    return left;
  }

  // -------------------------------------------------------------------------
  // After parsing a factor (possibly with %) in an additive context, we may
  // still need to consume * / operators that follow (to form a complete term).
  // This is only called when isPercent=false in parseExpression.
  // -------------------------------------------------------------------------
  Decimal _completeTerm(Decimal left) {
    while (_check(_TokenType.star) || _check(_TokenType.slash)) {
      final op = _advance();
      final (rightRaw, isPercent) = _parseFactorWithPercentFlag();

      final Decimal right;
      if (isPercent) {
        right = _rationalToDecimal(rightRaw / Decimal.fromInt(100));
      } else {
        right = rightRaw;
      }

      if (op.type == _TokenType.star) {
        left = left * right;
      } else {
        if (right == Decimal.zero) {
          throw _DivisionByZeroException();
        }
        left = _rationalToDecimal(left / right);
      }
    }
    return left;
  }

  // -------------------------------------------------------------------------
  // factor = '-' factor | primary
  // -------------------------------------------------------------------------
  Decimal _parseFactor() {
    if (_match(_TokenType.minus)) {
      return -_parseFactor();
    }
    // Consume optional unary plus
    _match(_TokenType.plus);
    return _parsePrimary();
  }

  // -------------------------------------------------------------------------
  // Parses a factor and returns (value, isPercent).
  //
  // isPercent=true means the factor was a bare NUMBER followed by %, and the
  // caller should apply context-aware percentage logic rather than dividing
  // by 100 immediately.
  //
  // For non-number primaries (sqrt, parenthesised), % is treated as
  // standalone (divide by 100) and isPercent=false is returned.
  // -------------------------------------------------------------------------
  (Decimal, bool) _parseFactorWithPercentFlag() {
    // Handle unary minus/plus
    bool negative = false;
    if (_check(_TokenType.minus)) {
      _advance();
      negative = true;
    } else {
      _match(_TokenType.plus);
    }

    if (_check(_TokenType.number)) {
      final tok = _advance();
      final value = Decimal.parse(tok.lexeme);
      final signed = negative ? -value : value;
      if (_match(_TokenType.percent)) {
        // Return raw value with percent flag — caller decides context
        return (signed, true);
      }
      return (signed, false);
    }

    // Non-number primary (sqrt or parenthesised expression)
    final value = negative ? -_parsePrimaryNoNumber() : _parsePrimaryNoNumber();
    if (_match(_TokenType.percent)) {
      // Treat as standalone: divide by 100 immediately
      return (_rationalToDecimal(value / Decimal.fromInt(100)), false);
    }
    return (value, false);
  }

  // -------------------------------------------------------------------------
  // primary = NUMBER ['%'] | 'sqrt' '(' expression ')' | '(' expression ')'
  //
  // Used in unary/factor context where standalone % is divided by 100.
  // -------------------------------------------------------------------------
  Decimal _parsePrimary() {
    if (_check(_TokenType.sqrt)) {
      return _parseSqrt();
    }
    if (_check(_TokenType.lparen)) {
      return _parseParenthesised();
    }
    if (_check(_TokenType.number)) {
      final tok = _advance();
      final value = Decimal.parse(tok.lexeme);
      if (_match(_TokenType.percent)) {
        // Standalone % — divide by 100
        return _rationalToDecimal(value / Decimal.fromInt(100));
      }
      return value;
    }
    throw _SyntaxException(
      'Expected number, sqrt, or "(" but got: '
      '${currentToken.lexeme.isEmpty ? "end of expression" : currentToken.lexeme}',
    );
  }

  /// Parses a non-number primary (sqrt or parenthesised expression).
  Decimal _parsePrimaryNoNumber() {
    if (_check(_TokenType.sqrt)) {
      return _parseSqrt();
    }
    if (_check(_TokenType.lparen)) {
      return _parseParenthesised();
    }
    if (_check(_TokenType.number)) {
      // Fallback: parse number here too (handles edge cases)
      final tok = _advance();
      return Decimal.parse(tok.lexeme);
    }
    throw _SyntaxException(
      'Expected number, sqrt, or "(" but got: '
      '${currentToken.lexeme.isEmpty ? "end of expression" : currentToken.lexeme}',
    );
  }

  Decimal _parseSqrt() {
    _expect(_TokenType.sqrt, 'Expected "sqrt"');
    _expect(_TokenType.lparen, 'Expected "(" after sqrt');
    final arg = parseExpression();
    _expect(_TokenType.rparen, 'Expected ")" after sqrt argument');
    return _sqrt(arg);
  }

  Decimal _parseParenthesised() {
    _expect(_TokenType.lparen, 'Expected "("');
    final value = parseExpression();
    _expect(_TokenType.rparen, 'Expected ")"');
    return value;
  }
}

// ---------------------------------------------------------------------------
// Newton's method square root using Decimal arithmetic
// ---------------------------------------------------------------------------

/// Computes sqrt(n) using Newton's method with [Decimal] arithmetic.
///
/// Iterates x_new = (x + n/x) / 2 until |x_new - x| < precision.
/// Throws [_ComplexResultException] for negative inputs (Requirement 1.4).
Decimal _sqrt(Decimal n) {
  if (n < Decimal.zero) {
    throw _ComplexResultException();
  }
  if (n == Decimal.zero) {
    return Decimal.zero;
  }

  // Precision threshold: 10^-20 for high accuracy
  final precision = Decimal.parse('0.00000000000000000001');
  final two = Decimal.fromInt(2);

  // Use higher internal scale for intermediate divisions to avoid truncation
  // errors accumulating during Newton's method iterations.
  const internalScale = 40;

  Decimal _div(Decimal a, Decimal b) =>
      (a / b).toDecimal(scaleOnInfinitePrecision: internalScale);

  // Initial guess:
  //   - For n >= 1: start with n/2 (converges quickly for large n)
  //   - For 0 < n < 1: start with 1 (converges quickly for small n)
  Decimal x;
  if (n >= Decimal.one) {
    x = _div(n, two);
  } else {
    x = Decimal.one;
  }

  const maxIterations = 200;
  for (int i = 0; i < maxIterations; i++) {
    // x_new = (x + n/x) / 2
    final nDivX = _div(n, x);
    final xNew = _div(x + nDivX, two);
    final diff = (xNew - x).abs();
    x = xNew;
    if (diff < precision) {
      break;
    }
  }

  // Check if x is an exact square root (handles perfect squares like sqrt(4)=2,
  // sqrt(9)=3 where Newton's method may converge to a value very close but not
  // exactly equal to the integer root due to truncation).
  final xSquared = x * x;
  if (xSquared == n) {
    return x;
  }

  // For non-perfect squares, round to _kScale decimal places.
  return x.round(scale: _kScale);
}

// ---------------------------------------------------------------------------
// Internal exceptions (converted to DecimalResult at the top level)
// ---------------------------------------------------------------------------

class _DivisionByZeroException implements Exception {}

class _ComplexResultException implements Exception {}

class _SyntaxException implements Exception {
  final String message;
  const _SyntaxException(this.message);
}
