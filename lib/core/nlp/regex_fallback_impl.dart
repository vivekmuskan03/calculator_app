import 'package:nexacalc/core/interfaces/regex_fallback.dart';

/// Concrete implementation of [RegexFallback] using case-insensitive regex
/// patterns to convert natural language queries into arithmetic expressions.
///
/// All patterns are matched case-insensitively. Trailing punctuation (?, !, .)
/// is stripped before matching. The ₹ symbol is stripped from numeric values
/// before extraction.
///
/// Patterns are evaluated in priority order (Requirement 2.5–2.10):
///   1. "X% of Y"                          → "(X / 100) * Y"
///   2. "add X% [GST] to Y" / "X% GST on [₹]Y" → "Y * (1 + X / 100)"
///   3. "sqrt of X"                         → "sqrt(X)"
///   4. "X plus Y"                          → "X + Y"
///   5. "X minus Y"                         → "X - Y"
///   6. "X times Y" / "X multiplied by Y"   → "X * Y"
///   7. "X divided by Y"                    → "X / Y"
///   8. "N lakh"                            → "N * 100000"
///   9. "N crore"                           → "N * 10000000"
///  10. "₹N" currency extraction            → "N"
class RegexFallbackImpl implements RegexFallback {
  // ---------------------------------------------------------------------------
  // Compiled regex patterns (case-insensitive, compiled once at construction)
  // ---------------------------------------------------------------------------

  /// Matches "X% of Y" — e.g. "15% of 1350", "What is 15% of 1350?"
  static final _percentOfPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s*%\s*of\s*₹?(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );

  /// Matches "add X% [GST] to Y" — e.g. "add 18% to 4500", "add 18% GST to 4500"
  static final _addPercentToPattern = RegExp(
    r'add\s+(\d+(?:\.\d+)?)\s*%(?:\s*gst)?\s+to\s+₹?(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );

  /// Matches "X% GST on [₹]Y" — e.g. "18% GST on ₹5000", "18% GST on 5000"
  static final _gstOnPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s*%\s*gst\s+on\s+₹?(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );

  /// Matches "sqrt of X" — e.g. "sqrt of 9", "what is sqrt of 144?"
  static final _sqrtOfPattern = RegExp(
    r'sqrt\s+of\s+(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );

  /// Matches "X plus Y" — e.g. "5 plus 3", "what is 100 plus 200?"
  static final _plusPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s+plus\s+(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );

  /// Matches "X minus Y" — e.g. "10 minus 3"
  static final _minusPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s+minus\s+(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );

  /// Matches "X times Y" or "X multiplied by Y" — e.g. "5 times 4"
  static final _timesPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s+(?:times|multiplied\s+by)\s+(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );

  /// Matches "X divided by Y" — e.g. "10 divided by 2"
  static final _dividedByPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s+divided\s+by\s+(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );

  /// Matches "N lakh" — e.g. "5 lakh"
  static final _lakhPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s+lakh',
    caseSensitive: false,
  );

  /// Matches "N crore" — e.g. "2 crore"
  static final _crorePattern = RegExp(
    r'(\d+(?:\.\d+)?)\s+crore',
    caseSensitive: false,
  );

  /// Matches a bare "₹N" currency value — e.g. "₹5000"
  static final _currencyPattern = RegExp(
    r'^₹(\d+(?:\.\d+)?)$',
    caseSensitive: false,
  );

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  @override
  String? parse(String query) {
    // Strip leading/trailing whitespace and trailing punctuation (?, !, .)
    final cleaned = _clean(query);
    if (cleaned.isEmpty) return null;

    // Priority 1: "X% of Y"
    final percentOf = _matchPercentOf(cleaned);
    if (percentOf != null) return percentOf;

    // Priority 2: "add X% [GST] to Y" and "X% GST on [₹]Y"
    final gst = _matchGst(cleaned);
    if (gst != null) return gst;

    // Priority 3: "sqrt of X"
    final sqrtOf = _matchSqrtOf(cleaned);
    if (sqrtOf != null) return sqrtOf;

    // Priority 4: "X plus Y"
    final plus = _matchPlus(cleaned);
    if (plus != null) return plus;

    // Priority 5: "X minus Y"
    final minus = _matchMinus(cleaned);
    if (minus != null) return minus;

    // Priority 6: "X times Y" / "X multiplied by Y"
    final times = _matchTimes(cleaned);
    if (times != null) return times;

    // Priority 7: "X divided by Y"
    final divided = _matchDividedBy(cleaned);
    if (divided != null) return divided;

    // Priority 8: "N lakh"
    final lakh = _matchLakh(cleaned);
    if (lakh != null) return lakh;

    // Priority 9: "N crore"
    final crore = _matchCrore(cleaned);
    if (crore != null) return crore;

    // Priority 10: "₹N" bare currency extraction
    final currency = _matchCurrency(cleaned);
    if (currency != null) return currency;

    return null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Strips leading/trailing whitespace and trailing punctuation (?, !, .).
  String _clean(String query) {
    return query.trim().replaceAll(RegExp(r'[?!.]+$'), '').trim();
  }

  /// Pattern 1: "X% of Y" → "(X / 100) * Y"
  String? _matchPercentOf(String query) {
    final match = _percentOfPattern.firstMatch(query);
    if (match == null) return null;
    final x = match.group(1)!;
    final y = match.group(2)!;
    return '($x / 100) * $y';
  }

  /// Pattern 2: "add X% [GST] to Y" or "X% GST on [₹]Y" → "Y * (1 + X / 100)"
  String? _matchGst(String query) {
    // Try "add X% [GST] to Y" first
    final addMatch = _addPercentToPattern.firstMatch(query);
    if (addMatch != null) {
      final x = addMatch.group(1)!;
      final y = addMatch.group(2)!;
      return '$y * (1 + $x / 100)';
    }

    // Try "X% GST on [₹]Y"
    final gstMatch = _gstOnPattern.firstMatch(query);
    if (gstMatch != null) {
      final x = gstMatch.group(1)!;
      final y = gstMatch.group(2)!;
      return '$y * (1 + $x / 100)';
    }

    return null;
  }

  /// Pattern 3: "sqrt of X" → "sqrt(X)"
  String? _matchSqrtOf(String query) {
    final match = _sqrtOfPattern.firstMatch(query);
    if (match == null) return null;
    final x = match.group(1)!;
    return 'sqrt($x)';
  }

  /// Pattern 4: "X plus Y" → "X + Y"
  String? _matchPlus(String query) {
    final match = _plusPattern.firstMatch(query);
    if (match == null) return null;
    final x = match.group(1)!;
    final y = match.group(2)!;
    return '$x + $y';
  }

  /// Pattern 5: "X minus Y" → "X - Y"
  String? _matchMinus(String query) {
    final match = _minusPattern.firstMatch(query);
    if (match == null) return null;
    final x = match.group(1)!;
    final y = match.group(2)!;
    return '$x - $y';
  }

  /// Pattern 6: "X times Y" / "X multiplied by Y" → "X * Y"
  String? _matchTimes(String query) {
    final match = _timesPattern.firstMatch(query);
    if (match == null) return null;
    final x = match.group(1)!;
    final y = match.group(2)!;
    return '$x * $y';
  }

  /// Pattern 7: "X divided by Y" → "X / Y"
  String? _matchDividedBy(String query) {
    final match = _dividedByPattern.firstMatch(query);
    if (match == null) return null;
    final x = match.group(1)!;
    final y = match.group(2)!;
    return '$x / $y';
  }

  /// Pattern 8: "N lakh" → "N * 100000"
  String? _matchLakh(String query) {
    final match = _lakhPattern.firstMatch(query);
    if (match == null) return null;
    final n = match.group(1)!;
    return '$n * 100000';
  }

  /// Pattern 9: "N crore" → "N * 10000000"
  String? _matchCrore(String query) {
    final match = _crorePattern.firstMatch(query);
    if (match == null) return null;
    final n = match.group(1)!;
    return '$n * 10000000';
  }

  /// Pattern 10: "₹N" bare currency extraction → "N"
  String? _matchCurrency(String query) {
    final match = _currencyPattern.firstMatch(query);
    if (match == null) return null;
    return match.group(1)!;
  }
}
