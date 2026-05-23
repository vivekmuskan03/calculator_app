/// Abstract interface for the regex-based natural language fallback parser.
///
/// Used when the LLM model is absent or returns an unparseable response
/// (Requirement 2.4). Stateless — no model loading required.
abstract class RegexFallback {
  /// Attempts to parse [query] using case-insensitive regex patterns.
  ///
  /// Returns an arithmetic expression string on success, or `null` when no
  /// supported pattern matches the query.
  ///
  /// Supported patterns (Requirement 2.5–2.10):
  /// - `"X% of Y"` → `"(X / 100) * Y"`
  /// - `"add X% to Y"` / `"add X% GST to Y"` → `"Y * (1 + X / 100)"`
  /// - `"sqrt of X"` → `"sqrt(X)"`
  /// - `"X plus Y"` → `"X + Y"`
  /// - `"₹N"` currency extraction → extracts N as numeric value
  /// - `"N lakh"` → `"N * 100000"`
  /// - `"N crore"` → `"N * 10000000"`
  String? parse(String query);
}
