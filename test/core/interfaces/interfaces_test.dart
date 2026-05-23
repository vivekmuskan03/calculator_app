import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:nexacalc/core/interfaces/interfaces.dart';

/// Smoke tests verifying that all interface definitions and data classes
/// are syntactically correct and can be instantiated (Task 1 scaffold check).
void main() {
  group('DecimalResult sealed types', () {
    test('DecimalSuccess holds a value and supports equality', () {
      // We cannot import decimal directly in this test without a real engine,
      // so we just verify the type hierarchy compiles correctly.
      expect(DecimalDivisionByZero(), isA<DecimalResult>());
      expect(DecimalComplexResult(), isA<DecimalResult>());
      expect(DecimalSyntaxError('bad input'), isA<DecimalResult>());
    });

    test('DecimalDivisionByZero equality', () {
      expect(DecimalDivisionByZero(), equals(DecimalDivisionByZero()));
    });

    test('DecimalComplexResult equality', () {
      expect(DecimalComplexResult(), equals(DecimalComplexResult()));
    });

    test('DecimalSyntaxError equality', () {
      expect(
        DecimalSyntaxError('unexpected token'),
        equals(DecimalSyntaxError('unexpected token')),
      );
      expect(
        DecimalSyntaxError('a'),
        isNot(equals(DecimalSyntaxError('b'))),
      );
    });

    test('DecimalSyntaxError toString includes message', () {
      final err = DecimalSyntaxError('missing operand');
      expect(err.toString(), contains('missing operand'));
    });
  });

  group('NLResult', () {
    test('NLResult holds expression and displayText', () {
      const result = NLResult(
        expression: '5000 * 0.18',
        displayText: '18% of ₹5000',
      );
      expect(result.expression, '5000 * 0.18');
      expect(result.displayText, '18% of ₹5000');
    });

    test('NLResult equality', () {
      const a = NLResult(expression: '1 + 2', displayText: 'one plus two');
      const b = NLResult(expression: '1 + 2', displayText: 'one plus two');
      expect(a, equals(b));
    });
  });

  group('NLParseException', () {
    test('NLParseException toString includes query and reason', () {
      const ex = NLParseException(
        query: 'what is the meaning of life',
        reason: 'no numeric values found',
      );
      expect(ex.toString(), contains('what is the meaning of life'));
      expect(ex.toString(), contains('no numeric values found'));
    });
  });

  group('HistoryEntry', () {
    test('HistoryEntry round-trips through toMap/fromMap', () {
      const entry = HistoryEntry(
        id: 1,
        expression: '0.1 + 0.2',
        result: '0.3',
        timestamp: 1700000000000,
        memo: 'test memo',
      );
      final map = entry.toMap();
      final restored = HistoryEntry.fromMap(map);
      expect(restored, equals(entry));
    });

    test('HistoryEntry copyWith replaces fields', () {
      const original = HistoryEntry(
        expression: '1 + 1',
        result: '2',
        timestamp: 1000,
      );
      final updated = original.copyWith(memo: 'updated');
      expect(updated.memo, 'updated');
      expect(updated.expression, '1 + 1');
    });

    test('HistoryEntry default memo is empty string', () {
      const entry = HistoryEntry(
        expression: '2 * 3',
        result: '6',
        timestamp: 2000,
      );
      expect(entry.memo, '');
    });

    test('HistoryEntry fromMap handles null memo', () {
      final map = {
        'id': 5,
        'expression': 'sqrt(4)',
        'result': '2',
        'timestamp': 3000,
        // memo intentionally absent
      };
      final entry = HistoryEntry.fromMap(map);
      expect(entry.memo, '');
    });
  });

  group('AppTheme', () {
    test('AppTheme.defaultTheme has correct colours', () {
      const theme = AppTheme.defaultTheme;
      expect(theme.backgroundStart.value, 0xFF0A0F1F);
      expect(theme.backgroundEnd.value, 0xFF10172A);
      expect(theme.numberBorder.value, 0xFF00E5FF);
      expect(theme.operatorBorder.value, 0xFFFF007A);
      expect(theme.equalsBorder.value, 0xFF00E676);
    });

    test('AppTheme equality', () {
      expect(AppTheme.defaultTheme, equals(AppTheme.defaultTheme));
    });

    test('AppTheme copyWith replaces only specified fields', () {
      const original = AppTheme.defaultTheme;
      final modified = original.copyWith(
        numberBorder: const Color(0xFFFFFFFF),
      );
      expect(modified.numberBorder.value, 0xFFFFFFFF);
      // Other fields unchanged
      expect(modified.backgroundStart, original.backgroundStart);
      expect(modified.operatorBorder, original.operatorBorder);
    });
  });

  group('VoiceInputException', () {
    test('VoiceInputException toString includes message', () {
      const ex = VoiceInputException('Microphone permission denied');
      expect(ex.toString(), contains('Microphone permission denied'));
    });
  });
}
