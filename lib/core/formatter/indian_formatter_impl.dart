import 'package:decimal/decimal.dart';
import 'package:nexacalc/core/interfaces/indian_formatter.dart';

/// Concrete implementation of [IndianFormatter] using Indian lakh/crore grouping.
///
/// Grouping rules:
/// - Rightmost group: 3 digits
/// - All groups to the left: 2 digits each
/// - Groups separated by commas
///
/// Examples:
/// - 1000       → "1,000"
/// - 100000     → "1,00,000"   (one lakh)
/// - 10000000   → "1,00,00,000" (one crore)
///
/// Negative numbers are handled by formatting the absolute value and prepending "-".
/// Decimal fractions are preserved unchanged; only the integer part is grouped.
class IndianFormatterImpl implements IndianFormatter {
  const IndianFormatterImpl();

  @override
  String format(Decimal value) {
    // Convert to string using the decimal package's own toString, which
    // produces a canonical decimal representation (e.g. "1234567.89", "-5", "0.5").
    final raw = value.toString();

    // Separate sign, integer part, and fractional part.
    final isNegative = raw.startsWith('-');
    final unsigned = isNegative ? raw.substring(1) : raw;

    final dotIndex = unsigned.indexOf('.');
    final String integerPart;
    final String fractionalSuffix; // includes the leading "." if present

    if (dotIndex == -1) {
      integerPart = unsigned;
      fractionalSuffix = '';
    } else {
      integerPart = unsigned.substring(0, dotIndex);
      fractionalSuffix = unsigned.substring(dotIndex); // e.g. ".89"
    }

    // Apply Indian grouping to the integer part.
    final grouped = _applyIndianGrouping(integerPart);

    // Reassemble the formatted string.
    final sign = isNegative ? '-' : '';
    return '$sign$grouped$fractionalSuffix';
  }

  /// Inserts commas into [digits] (a non-empty string of ASCII digit characters)
  /// following Indian lakh/crore grouping:
  ///   - rightmost group: 3 digits
  ///   - every group to the left: 2 digits
  ///
  /// If [digits] has 3 or fewer characters no comma is inserted.
  String _applyIndianGrouping(String digits) {
    if (digits.length <= 3) return digits;

    final buffer = StringBuffer();

    // The rightmost 3 digits form the first (rightmost) group.
    final rightGroup = digits.substring(digits.length - 3);
    final remaining = digits.substring(0, digits.length - 3);

    // Walk the remaining digits from right to left, taking 2 at a time.
    // We build the groups in reverse order, then reverse at the end.
    final leftGroups = <String>[];
    var i = remaining.length;
    while (i > 0) {
      final start = (i - 2).clamp(0, i);
      leftGroups.add(remaining.substring(start, i));
      i = start;
    }

    // leftGroups is in reverse order (rightmost first); reverse to get
    // left-to-right order.
    for (final group in leftGroups.reversed) {
      buffer.write(group);
      buffer.write(',');
    }

    buffer.write(rightGroup);
    return buffer.toString();
  }
}
