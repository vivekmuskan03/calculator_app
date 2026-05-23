import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexacalc/core/engine/decimal_engine_impl.dart';
import 'package:nexacalc/core/interfaces/decimal_engine.dart';
import 'package:nexacalc/core/nlp/regex_fallback_impl.dart';

void main() {
  late RegexFallbackImpl fallback;
  late DecimalEngineImpl engine;

  setUp(() {
    fallback = RegexFallbackImpl();
    engine = DecimalEngineImpl();
  });

  // Helper: parse query → expression → evaluate → return Decimal value.
  // Fails the test if parse returns null or evaluation is not a success.
  Decimal evalQuery(String query) {
    final expression = fallback.parse(query);
    expect(expression, isNotNull,
        reason: 'RegexFallback.parse("$query") returned null');
    final result = engine.evaluate(expression!);
    expect(result, isA<DecimalSuccess>(),
        reason:
            'DecimalEngine.evaluate("$expression") returned $result for query "$query"');
    return (result as DecimalSuccess).value;
  }

  // ---------------------------------------------------------------------------
  // Pattern 1: "X% of Y" (Requirement 2.5)
  // ---------------------------------------------------------------------------
  group('Pattern 1 — "X% of Y" (Requirement 2.5)', () {
    test('1. "15% of 1350" evaluates to 202.5', () {
      final result = evalQuery('15% of 1350');
      expect(result, equals(Decimal.parse('202.5')));
    });

    test('2. "What is 15% of 1350?" evaluates to 202.5', () {
      final result = evalQuery('What is 15% of 1350?');
      expect(result, equals(Decimal.parse('202.5')));
    });
  });

  // ---------------------------------------------------------------------------
  // Pattern 2: "add X% [GST] to Y" / "X% GST on [₹]Y" (Requirement 2.6, 2.9)
  // ---------------------------------------------------------------------------
  group('Pattern 2 — GST patterns (Requirements 2.6, 2.9)', () {
    test('3. "add 18% to 4500" evaluates to 5310', () {
      final result = evalQuery('add 18% to 4500');
      expect(result, equals(Decimal.parse('5310')));
    });

    test('4. "add 18% GST to 4500" evaluates to 5310', () {
      final result = evalQuery('add 18% GST to 4500');
      expect(result, equals(Decimal.parse('5310')));
    });

    test('5. "18% GST on ₹5000" evaluates to 5900', () {
      final result = evalQuery('18% GST on ₹5000');
      expect(result, equals(Decimal.parse('5900')));
    });

    test('6. "What is 18% GST on ₹5000?" evaluates to 5900', () {
      final result = evalQuery('What is 18% GST on ₹5000?');
      expect(result, equals(Decimal.parse('5900')));
    });
  });

  // ---------------------------------------------------------------------------
  // Pattern 3: "sqrt of X" (Requirement 2.7)
  // ---------------------------------------------------------------------------
  group('Pattern 3 — "sqrt of X" (Requirement 2.7)', () {
    test('7. "sqrt of 9" evaluates to 3', () {
      final result = evalQuery('sqrt of 9');
      expect(result, equals(Decimal.parse('3')));
    });

    test('8. "what is sqrt of 144?" evaluates to 12', () {
      final result = evalQuery('what is sqrt of 144?');
      expect(result, equals(Decimal.parse('12')));
    });
  });

  // ---------------------------------------------------------------------------
  // Pattern 4: "X plus Y" (Requirement 2.8)
  // ---------------------------------------------------------------------------
  group('Pattern 4 — "X plus Y" (Requirement 2.8)', () {
    test('9. "5 plus 3" evaluates to 8', () {
      final result = evalQuery('5 plus 3');
      expect(result, equals(Decimal.parse('8')));
    });

    test('10. "what is 100 plus 200?" evaluates to 300', () {
      final result = evalQuery('what is 100 plus 200?');
      expect(result, equals(Decimal.parse('300')));
    });
  });

  // ---------------------------------------------------------------------------
  // Pattern 5: "X minus Y"
  // ---------------------------------------------------------------------------
  group('Pattern 5 — "X minus Y"', () {
    test('11. "10 minus 3" evaluates to 7', () {
      final result = evalQuery('10 minus 3');
      expect(result, equals(Decimal.parse('7')));
    });
  });

  // ---------------------------------------------------------------------------
  // Pattern 6: "X times Y" / "X multiplied by Y"
  // ---------------------------------------------------------------------------
  group('Pattern 6 — "X times Y" / "X multiplied by Y"', () {
    test('12. "5 times 4" evaluates to 20', () {
      final result = evalQuery('5 times 4');
      expect(result, equals(Decimal.parse('20')));
    });

    test('"10 multiplied by 3" evaluates to 30', () {
      final result = evalQuery('10 multiplied by 3');
      expect(result, equals(Decimal.parse('30')));
    });
  });

  // ---------------------------------------------------------------------------
  // Pattern 7: "X divided by Y"
  // ---------------------------------------------------------------------------
  group('Pattern 7 — "X divided by Y"', () {
    test('13. "10 divided by 2" evaluates to 5', () {
      final result = evalQuery('10 divided by 2');
      expect(result, equals(Decimal.parse('5')));
    });
  });

  // ---------------------------------------------------------------------------
  // Pattern 8: "N lakh" (Requirement 2.10)
  // ---------------------------------------------------------------------------
  group('Pattern 8 — "N lakh" (Requirement 2.10)', () {
    test('14. "5 lakh" evaluates to 500000', () {
      final result = evalQuery('5 lakh');
      expect(result, equals(Decimal.parse('500000')));
    });
  });

  // ---------------------------------------------------------------------------
  // Pattern 9: "N crore" (Requirement 2.10)
  // ---------------------------------------------------------------------------
  group('Pattern 9 — "N crore" (Requirement 2.10)', () {
    test('15. "2 crore" evaluates to 20000000', () {
      final result = evalQuery('2 crore');
      expect(result, equals(Decimal.parse('20000000')));
    });
  });

  // ---------------------------------------------------------------------------
  // Null / no-match cases
  // ---------------------------------------------------------------------------
  group('No-match cases', () {
    test('16. unrecognised query returns null', () {
      expect(fallback.parse('hello world'), isNull);
    });

    test('17. empty string returns null', () {
      expect(fallback.parse(''), isNull);
    });

    test('whitespace-only string returns null', () {
      expect(fallback.parse('   '), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Case-insensitivity
  // ---------------------------------------------------------------------------
  group('Case-insensitivity', () {
    test('"SQRT OF 9" is matched (all caps)', () {
      final result = evalQuery('SQRT OF 9');
      expect(result, equals(Decimal.parse('3')));
    });

    test('"5 PLUS 3" is matched (all caps)', () {
      final result = evalQuery('5 PLUS 3');
      expect(result, equals(Decimal.parse('8')));
    });

    test('"5 Lakh" is matched (mixed case)', () {
      final result = evalQuery('5 Lakh');
      expect(result, equals(Decimal.parse('500000')));
    });
  });

  // ---------------------------------------------------------------------------
  // Trailing punctuation stripping
  // ---------------------------------------------------------------------------
  group('Trailing punctuation stripping', () {
    test('"10 minus 3!" strips exclamation mark', () {
      final result = evalQuery('10 minus 3!');
      expect(result, equals(Decimal.parse('7')));
    });

    test('"5 times 4." strips trailing period', () {
      final result = evalQuery('5 times 4.');
      expect(result, equals(Decimal.parse('20')));
    });
  });

  // ---------------------------------------------------------------------------
  // Decimal number support
  // ---------------------------------------------------------------------------
  group('Decimal number support', () {
    test('"18.5% of 200" evaluates to 37', () {
      final result = evalQuery('18.5% of 200');
      expect(result, equals(Decimal.parse('37')));
    });

    test('"2.5 lakh" evaluates to 250000', () {
      final result = evalQuery('2.5 lakh');
      expect(result, equals(Decimal.parse('250000')));
    });
  });
}
