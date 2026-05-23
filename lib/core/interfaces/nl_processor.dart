/// Abstract interface for the natural language processing component.
///
/// Converts user text queries (typed or transcribed) into arithmetic
/// expression strings that can be evaluated by [DecimalEngine].
abstract class NLProcessor {
  /// Interprets a natural language [query] and returns an [NLResult].
  ///
  /// First attempts LLM inference if the model is loaded; falls back to
  /// [RegexFallback] if the model is absent or returns an unparseable response.
  ///
  /// Throws [NLParseException] when both LLM and regex fallback fail.
  Future<NLResult> interpret(String query);
}

/// The result of a successful natural language interpretation.
class NLResult {
  /// The arithmetic expression string derived from the query.
  ///
  /// Example: `"5000 * 0.18"` for the query `"What is 18% GST on ₹5000?"`.
  final String expression;

  /// Human-readable text shown to the user for 2 seconds before the result
  /// (Requirement 2.2). Example: `"18% of ₹5000 = 5000 × 0.18"`.
  final String displayText;

  const NLResult({required this.expression, required this.displayText});

  @override
  String toString() => 'NLResult(expression: $expression, displayText: $displayText)';

  @override
  bool operator ==(Object other) =>
      other is NLResult &&
      other.expression == expression &&
      other.displayText == displayText;

  @override
  int get hashCode => Object.hash(expression, displayText);
}

/// Thrown when neither the LLM nor the regex fallback can interpret the query.
class NLParseException implements Exception {
  /// The original query that could not be interpreted.
  final String query;

  /// Human-readable reason for the failure.
  final String reason;

  const NLParseException({required this.query, required this.reason});

  @override
  String toString() => 'NLParseException: Could not interpret "$query" — $reason';
}
