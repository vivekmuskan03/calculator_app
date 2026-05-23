import 'package:decimal/decimal.dart';

/// Abstract interface for the arithmetic evaluation engine.
///
/// All arithmetic is performed using the [decimal] package to guarantee
/// exact results with no floating-point rounding errors (Requirement 1.1).
abstract class DecimalEngine {
  /// Evaluates an arithmetic expression string and returns a [DecimalResult].
  ///
  /// Supported operations: +, -, *, /, sqrt(), parentheses, and % (context-aware).
  /// Never uses Dart [double] for intermediate or final computation.
  DecimalResult evaluate(String expression);
}

/// Sealed base class for all possible results from [DecimalEngine.evaluate].
///
/// Pattern-match on this to handle each outcome:
/// ```dart
/// switch (result) {
///   case DecimalSuccess(:final value): ...
///   case DecimalDivisionByZero(): ...
///   case DecimalComplexResult(): ...
///   case DecimalSyntaxError(:final message): ...
/// }
/// ```
sealed class DecimalResult {}

/// Successful evaluation — [value] holds the exact decimal result.
class DecimalSuccess extends DecimalResult {
  /// The exact decimal result of the evaluated expression.
  final Decimal value;

  DecimalSuccess(this.value);

  @override
  String toString() => 'DecimalSuccess($value)';

  @override
  bool operator ==(Object other) =>
      other is DecimalSuccess && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Returned when any number is divided by zero (Requirement 1.3).
///
/// The UI should display "Undefined" when this result is received.
class DecimalDivisionByZero extends DecimalResult {
  @override
  String toString() => 'DecimalDivisionByZero';

  @override
  bool operator ==(Object other) => other is DecimalDivisionByZero;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Returned when sqrt() is applied to a negative number (Requirement 1.4).
///
/// The UI should display "Complex result (i)" when this result is received.
class DecimalComplexResult extends DecimalResult {
  @override
  String toString() => 'DecimalComplexResult';

  @override
  bool operator ==(Object other) => other is DecimalComplexResult;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Returned when the expression string cannot be parsed (Requirement 9.6).
///
/// [message] describes the syntax error for display in the red tooltip.
class DecimalSyntaxError extends DecimalResult {
  /// Human-readable description of the syntax error.
  final String message;

  DecimalSyntaxError(this.message);

  @override
  String toString() => 'DecimalSyntaxError($message)';

  @override
  bool operator ==(Object other) =>
      other is DecimalSyntaxError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
