import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexacalc/core/engine/decimal_engine_impl.dart';
import 'package:nexacalc/core/db/history_db_impl.dart';
import 'package:nexacalc/core/formatter/indian_formatter_impl.dart';
import 'package:nexacalc/core/interfaces/history_db.dart';
import 'package:nexacalc/core/providers/monetization_providers.dart';

class CalculatorState {
  final String expression;
  final String result;
  final bool isLoading;
  final String? error;

  const CalculatorState({
    this.expression = '',
    this.result = '',
    this.isLoading = false,
    this.error,
  });

  CalculatorState copyWith({String? expression, String? result, bool? isLoading, String? error}) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CalculatorNotifier extends ChangeNotifier {
  final Ref _ref;
  final _engine = DecimalEngineImpl();
  final HistoryDB _history = HistoryDBImpl();
  final _formatter = const IndianFormatterImpl();

  CalculatorNotifier(this._ref);

  CalculatorState _state = const CalculatorState();

  CalculatorState get state => _state;

  void append(String s) {
    _state = _state.copyWith(expression: _state.expression + s, error: null);
    notifyListeners();
  }

  /// Replace the full expression with [expr]. UI should call this when
  /// performing caret-aware edits.
  void setExpression(String expr) {
    _state = _state.copyWith(expression: expr, error: null);
    notifyListeners();
  }

  void clear() {
    _state = const CalculatorState();
    notifyListeners();
  }

  Future<void> evaluate() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final res = _engine.evaluate(_state.expression);
    String out;
    if (res is DecimalSuccess) {
      out = _formatter.format(res.value);
      // persist history
      final entry = HistoryEntry(
        expression: _state.expression,
        result: out,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _history.insert(entry);
      // notify ad manager about calculation
      try {
        final ad = _ref.read(adManagerProvider);
        ad.onCalculationCompleted();
      } catch (_) {}
      _state = _state.copyWith(result: out, isLoading: false, error: null);
    } else if (res is DecimalDivisionByZero) {
      out = 'Undefined';
      _state = _state.copyWith(result: out, isLoading: false);
    } else if (res is DecimalComplexResult) {
      out = 'Complex result (i)';
      _state = _state.copyWith(result: out, isLoading: false);
    } else if (res is DecimalSyntaxError) {
      _state = _state.copyWith(result: 'Syntax error', isLoading: false, error: res.message);
    } else {
      _state = _state.copyWith(result: 'Error', isLoading: false);
    }

    notifyListeners();
  }
}

final calculatorProvider = ChangeNotifierProvider<CalculatorNotifier>((ref) => CalculatorNotifier(ref));
