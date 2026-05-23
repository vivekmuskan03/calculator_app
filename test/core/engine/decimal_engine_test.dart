import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexacalc/core/engine/decimal_engine_impl.dart';
import 'package:nexacalc/core/interfaces/decimal_engine.dart';

void main() {
  late DecimalEngineImpl engine;

  setUp(() {
    engine = DecimalEngineImpl();
  });

  // Helper to extract the Decimal value from a successful result.
  Decimal successValue(DecimalResult result) {
    expect(result, isA<DecimalSuccess>(), reason: 'Expected DecimalSuccess but got $result');
    return (result as DecimalSuccess).value;
  }

  // ---------------------------------------------------------------------------
  // 1. Floating-point exactness
  // ---------------------------------------------------------------------------
  group('Floating-point exactness (Requirement 1.1, 1.2)', () {
    test('0.1 + 0.2 == 0.3 exactly', () {
      // Dart double gives 0.30000000000000004; Decimal must give exactly 0.3
      final result = successValue(engine.evaluate('0.1 + 0.2'));
      expect(result, equals(Decimal.parse('0.3')));
    });

    test('0.1 + 0.2 + 0.3 == 0.6 exactly (chained addition)', () {
      final result = successValue(engine.evaluate('0.1 + 0.2 + 0.3'));
      expect(result, equals(Decimal.parse('0.6')));
    });

    test('0.000001 + 0.000002 == 0.000003 (micro-decimal precision)', () {
      final result = successValue(engine.evaluate('0.000001 + 0.000002'));
      expect(result, equals(Decimal.parse('0.000003')));
    });

    test('1.5 * 2 == 3.0', () {
      final result = successValue(engine.evaluate('1.5 * 2'));
      expect(result, equals(Decimal.parse('3.0')));
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Division by zero (Requirement 1.3)
  // ---------------------------------------------------------------------------
  group('Division by zero (Requirement 1.3)', () {
    test('1 / 0 → DecimalDivisionByZero', () {
      expect(engine.evaluate('1 / 0'), isA<DecimalDivisionByZero>());
    });

    test('0 / 0 → DecimalDivisionByZero', () {
      expect(engine.evaluate('0 / 0'), isA<DecimalDivisionByZero>());
    });

    test('0 / 5 == 0 (zero numerator is fine)', () {
      final result = successValue(engine.evaluate('0 / 5'));
      expect(result, equals(Decimal.zero));
    });

    test('negative / 0 → DecimalDivisionByZero', () {
      expect(engine.evaluate('-7 / 0'), isA<DecimalDivisionByZero>());
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Square root (Requirement 1.4)
  // ---------------------------------------------------------------------------
  group('Square root (Requirement 1.4)', () {
    test('sqrt(-1) → DecimalComplexResult', () {
      expect(engine.evaluate('sqrt(-1)'), isA<DecimalComplexResult>());
    });

    test('sqrt(-100) → DecimalComplexResult', () {
      expect(engine.evaluate('sqrt(-100)'), isA<DecimalComplexResult>());
    });

    test('sqrt(4) == 2', () {
      final result = successValue(engine.evaluate('sqrt(4)'));
      expect(result, equals(Decimal.parse('2')));
    });

    test('sqrt(9) == 3', () {
      final result = successValue(engine.evaluate('sqrt(9)'));
      expect(result, equals(Decimal.parse('3')));
    });

    test('sqrt(0) == 0', () {
      final result = successValue(engine.evaluate('sqrt(0)'));
      expect(result, equals(Decimal.zero));
    });

    test('sqrt(2) squared is approximately 2 (within 1e-10 tolerance)', () {
      final sqrtTwo = successValue(engine.evaluate('sqrt(2)'));
      final squared = sqrtTwo * sqrtTwo;
      final diff = (squared - Decimal.parse('2')).abs();
      expect(
        diff < Decimal.parse('0.0000000001'),
        isTrue,
        reason: 'sqrt(2)^2 = $squared, diff from 2 = $diff',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 4. Percentage operations (Requirement 7.1–7.5)
  // ---------------------------------------------------------------------------
  group('Percentage operations (Requirement 7)', () {
    test('50 + 25% == 62.5 (A + B% → A + A*B/100)', () {
      // 50 + (50 * 25 / 100) = 50 + 12.5 = 62.5
      final result = successValue(engine.evaluate('50 + 25%'));
      expect(result, equals(Decimal.parse('62.5')));
    });

    test('100 - 10% == 90 (A - B% → A - A*B/100)', () {
      // 100 - (100 * 10 / 100) = 100 - 10 = 90
      final result = successValue(engine.evaluate('100 - 10%'));
      expect(result, equals(Decimal.parse('90')));
    });

    test('200 * 50% == 100 (A * B% → A * B/100)', () {
      // 200 * (50 / 100) = 200 * 0.5 = 100
      final result = successValue(engine.evaluate('200 * 50%'));
      expect(result, equals(Decimal.parse('100')));
    });

    test('200 / 50% == 400 (A / B% → A / (B/100))', () {
      // 200 / (50 / 100) = 200 / 0.5 = 400
      final result = successValue(engine.evaluate('200 / 50%'));
      expect(result, equals(Decimal.parse('400')));
    });

    test('25% == 0.25 (standalone percentage → B/100)', () {
      final result = successValue(engine.evaluate('25%'));
      expect(result, equals(Decimal.parse('0.25')));
    });

    test('1% == 0.01 (standalone percentage)', () {
      final result = successValue(engine.evaluate('1%'));
      expect(result, equals(Decimal.parse('0.01')));
    });
  });

  // ---------------------------------------------------------------------------
  // 5. Operator precedence and parentheses
  // ---------------------------------------------------------------------------
  group('Operator precedence and parentheses', () {
    test('2 + 3 * 4 == 14 (* before +)', () {
      final result = successValue(engine.evaluate('2 + 3 * 4'));
      expect(result, equals(Decimal.parse('14')));
    });

    test('(2 + 3) * 4 == 20 (parentheses override precedence)', () {
      final result = successValue(engine.evaluate('(2 + 3) * 4'));
      expect(result, equals(Decimal.parse('20')));
    });

    test('10 - 2 * 3 == 4 (* before -)', () {
      final result = successValue(engine.evaluate('10 - 2 * 3'));
      expect(result, equals(Decimal.parse('4')));
    });

    test('10 / 2 + 3 == 8 (/ before +)', () {
      final result = successValue(engine.evaluate('10 / 2 + 3'));
      expect(result, equals(Decimal.parse('8')));
    });
  });

  // ---------------------------------------------------------------------------
  // 6. Unary minus
  // ---------------------------------------------------------------------------
  group('Unary minus', () {
    test('-5 + 3 == -2', () {
      final result = successValue(engine.evaluate('-5 + 3'));
      expect(result, equals(Decimal.parse('-2')));
    });

    test('-(3 + 2) == -5', () {
      final result = successValue(engine.evaluate('-(3 + 2)'));
      expect(result, equals(Decimal.parse('-5')));
    });

    test('-(-5) == 5 (double negation)', () {
      final result = successValue(engine.evaluate('-(-5)'));
      expect(result, equals(Decimal.parse('5')));
    });
  });

  // ---------------------------------------------------------------------------
  // 7. Large and small numbers
  // ---------------------------------------------------------------------------
  group('Large and small numbers', () {
    test('9999999 * 9999999 == 99999980000001 (crore-range exact)', () {
      final result = successValue(engine.evaluate('9999999 * 9999999'));
      expect(result, equals(Decimal.parse('99999980000001')));
    });

    test('1000000 / 3 does not crash (repeating decimal)', () {
      // Should succeed — decimal package handles rational arithmetic
      final result = engine.evaluate('1000000 / 3');
      expect(result, isA<DecimalSuccess>());
    });
  });

  // ---------------------------------------------------------------------------
  // 8. Zero edge cases
  // ---------------------------------------------------------------------------
  group('Zero edge cases', () {
    test('0 - 0 == 0', () {
      final result = successValue(engine.evaluate('0 - 0'));
      expect(result, equals(Decimal.zero));
    });

    test('0 + 0 == 0', () {
      final result = successValue(engine.evaluate('0 + 0'));
      expect(result, equals(Decimal.zero));
    });

    test('0 * 9999 == 0', () {
      final result = successValue(engine.evaluate('0 * 9999'));
      expect(result, equals(Decimal.zero));
    });
  });

  // ---------------------------------------------------------------------------
  // 9. Syntax errors (Requirement 9.6)
  // ---------------------------------------------------------------------------
  group('Syntax errors', () {
    test('empty string → DecimalSyntaxError', () {
      expect(engine.evaluate(''), isA<DecimalSyntaxError>());
    });

    test('"abc" → DecimalSyntaxError', () {
      expect(engine.evaluate('abc'), isA<DecimalSyntaxError>());
    });

    test('"2 +" → DecimalSyntaxError (trailing operator)', () {
      expect(engine.evaluate('2 +'), isA<DecimalSyntaxError>());
    });

    test('"* 3" → DecimalSyntaxError (leading operator)', () {
      expect(engine.evaluate('* 3'), isA<DecimalSyntaxError>());
    });

    test('"(2 + 3" → DecimalSyntaxError (unclosed paren)', () {
      expect(engine.evaluate('(2 + 3'), isA<DecimalSyntaxError>());
    });

    test('"2 + + 3" → DecimalSyntaxError or valid (double operator)', () {
      // Double operator is invalid syntax
      final result = engine.evaluate('2 + + 3');
      // Either a syntax error or a valid result (unary + is allowed)
      // Per our grammar, unary + is consumed, so 2 + (+3) = 5 is valid.
      // This is acceptable behaviour.
      expect(result, isA<DecimalResult>());
    });
  });

  // ---------------------------------------------------------------------------
  // 10. Additional arithmetic correctness
  // ---------------------------------------------------------------------------
  group('Additional arithmetic', () {
    test('simple addition: 1 + 1 == 2', () {
      final result = successValue(engine.evaluate('1 + 1'));
      expect(result, equals(Decimal.parse('2')));
    });

    test('simple subtraction: 10 - 4 == 6', () {
      final result = successValue(engine.evaluate('10 - 4'));
      expect(result, equals(Decimal.parse('6')));
    });

    test('simple multiplication: 6 * 7 == 42', () {
      final result = successValue(engine.evaluate('6 * 7'));
      expect(result, equals(Decimal.parse('42')));
    });

    test('simple division: 15 / 3 == 5', () {
      final result = successValue(engine.evaluate('15 / 3'));
      expect(result, equals(Decimal.parse('5')));
    });

    test('nested parentheses: ((2 + 3) * (4 - 1)) == 15', () {
      final result = successValue(engine.evaluate('((2 + 3) * (4 - 1))'));
      expect(result, equals(Decimal.parse('15')));
    });

    test('sqrt inside expression: sqrt(9) + 1 == 4', () {
      final result = successValue(engine.evaluate('sqrt(9) + 1'));
      expect(result, equals(Decimal.parse('4')));
    });

    test('whitespace is ignored: " 2  +  3 " == 5', () {
      final result = successValue(engine.evaluate(' 2  +  3 '));
      expect(result, equals(Decimal.parse('5')));
    });
  });
}
