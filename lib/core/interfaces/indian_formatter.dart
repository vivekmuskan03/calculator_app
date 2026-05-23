import 'package:decimal/decimal.dart';

/// Abstract interface for Indian lakh/crore number formatting.
///
/// Formats [Decimal] values using the Indian numbering system where the
/// rightmost group has 3 digits and all subsequent groups have 2 digits,
/// separated by commas (Requirement 1.5).
///
/// Examples:
/// - `1000` → `"1,000"`
/// - `100000` → `"1,00,000"` (one lakh)
/// - `10000000` → `"1,00,00,000"` (one crore)
abstract class IndianFormatter {
  /// Formats [value] with Indian lakh/crore grouping separators.
  ///
  /// Handles negative numbers and decimal fractions correctly.
  /// The decimal part (if any) is formatted without grouping separators.
  String format(Decimal value);
}
