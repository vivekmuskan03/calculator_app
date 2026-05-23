import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexacalc/core/formatter/indian_formatter_impl.dart';

void main() {
  const formatter = IndianFormatterImpl();

  // Helper to parse a string into a Decimal and format it.
  String fmt(String value) => formatter.format(Decimal.parse(value));

  // ---------------------------------------------------------------------------
  // Indian grouping — positive integers (Requirement 1.5)
  // ---------------------------------------------------------------------------
  group('Indian grouping — positive integers', () {
    test('1000 → "1,000"', () {
      expect(fmt('1000'), equals('1,000'));
    });

    test('10000 → "10,000"', () {
      expect(fmt('10000'), equals('10,000'));
    });

    test('100000 → "1,00,000" (one lakh)', () {
      expect(fmt('100000'), equals('1,00,000'));
    });

    test('1000000 → "10,00,000"', () {
      expect(fmt('1000000'), equals('10,00,000'));
    });

    test('10000000 → "1,00,00,000" (one crore)', () {
      expect(fmt('10000000'), equals('1,00,00,000'));
    });

    test('100000000 → "10,00,00,000"', () {
      expect(fmt('100000000'), equals('10,00,00,000'));
    });

    test('1000000000 → "1,00,00,00,000"', () {
      expect(fmt('1000000000'), equals('1,00,00,00,000'));
    });
  });

  // ---------------------------------------------------------------------------
  // Small values — no comma needed (Requirement 1.5)
  // ---------------------------------------------------------------------------
  group('Small values — no comma needed', () {
    test('0 → "0"', () {
      expect(fmt('0'), equals('0'));
    });

    test('50 → "50"', () {
      expect(fmt('50'), equals('50'));
    });

    test('500 → "500"', () {
      expect(fmt('500'), equals('500'));
    });

    test('999 → "999" (exactly 3 digits, no comma)', () {
      expect(fmt('999'), equals('999'));
    });
  });

  // ---------------------------------------------------------------------------
  // Negative numbers (Requirement 1.5)
  // ---------------------------------------------------------------------------
  group('Negative numbers', () {
    test('-100000 → "-1,00,000"', () {
      expect(fmt('-100000'), equals('-1,00,000'));
    });

    test('-1000 → "-1,000"', () {
      expect(fmt('-1000'), equals('-1,000'));
    });

    test('-999 → "-999" (no comma for 3 or fewer digits)', () {
      expect(fmt('-999'), equals('-999'));
    });
  });

  // ---------------------------------------------------------------------------
  // Decimal fractions — integer part grouped, fraction unchanged (Requirement 1.5)
  // ---------------------------------------------------------------------------
  group('Decimal fractions', () {
    test('1234567.89 → "12,34,567.89"', () {
      expect(fmt('1234567.89'), equals('12,34,567.89'));
    });

    test('0.5 → "0.5" (less than 1, no grouping needed)', () {
      expect(fmt('0.5'), equals('0.5'));
    });

    // Behaviour: Decimal.parse('1.0').toString() produces "1.0" in the decimal
    // package, so the formatter preserves the trailing zero.
    // Document: 1.0 → "1.0" (trailing zero preserved from Decimal representation)
    test('1.0 → "1.0" (trailing zero preserved from Decimal representation)', () {
      expect(fmt('1.0'), equals('1.0'));
    });

    test('100000.5 → "1,00,000.5"', () {
      expect(fmt('100000.5'), equals('1,00,000.5'));
    });
  });
}
