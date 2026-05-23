import 'package:flutter/material.dart';
import 'package:nexacalc/core/engine/decimal_engine_impl.dart';
import 'package:nexacalc/core/formatter/indian_formatter_impl.dart';
import 'package:nexacalc/core/interfaces/decimal_engine.dart';

/// A lightweight calculator demo that avoids platform plugins.
class DemoCalculatorScreen extends StatefulWidget {
  const DemoCalculatorScreen({super.key});

  @override
  State<DemoCalculatorScreen> createState() => _DemoCalculatorScreenState();
}

class _DemoCalculatorScreenState extends State<DemoCalculatorScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _engine = DecimalEngineImpl();
  final _formatter = const IndianFormatterImpl();
  String _result = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int _selectionStart() {
    final selection = _controller.selection;
    if (!selection.isValid || selection.start < 0) {
      return _controller.text.length;
    }
    return selection.start;
  }

  void _append(String text) {
    final selectionStart = _selectionStart();
    final selectionEnd = _controller.selection.isValid && _controller.selection.end >= 0
        ? _controller.selection.end
        : selectionStart;
    final current = _controller.text;
    final updated = current.replaceRange(selectionStart, selectionEnd, text);
    _controller.text = updated;
    _controller.selection = TextSelection.collapsed(offset: selectionStart + text.length);
    setState(() {});
  }

  void _backspace() {
    final selection = _controller.selection;
    if (selection.isValid && selection.start >= 0 && selection.start != selection.end) {
      final updated = _controller.text.replaceRange(selection.start, selection.end, '');
      _controller.text = updated;
      _controller.selection = TextSelection.collapsed(offset: selection.start);
      setState(() {});
      return;
    }
    final start = _selectionStart();
    if (start == 0) return;
    final updated = _controller.text.replaceRange(start - 1, start, '');
    _controller.text = updated;
    _controller.selection = TextSelection.collapsed(offset: start - 1);
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _result = '';
    setState(() {});
  }

  void _evaluate() {
    final expression = _controller.text;
    final evaluation = _engine.evaluate(expression);
    setState(() {
      if (evaluation is DecimalSuccess) {
        _result = _formatter.format(evaluation.value);
      } else if (evaluation is DecimalDivisionByZero) {
        _result = 'Undefined';
      } else if (evaluation is DecimalComplexResult) {
        _result = 'Complex result (i)';
      } else if (evaluation is DecimalSyntaxError) {
        _result = 'Syntax error';
      } else {
        _result = 'Error';
      }
    });
  }

  Widget _key(String label, {Color? color, VoidCallback? onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          onPressed: onPressed ?? () => _append(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.white12,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('NexaCalc Demo')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.none,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.displayLarge,
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(_result, style: theme.textTheme.displayMedium),
                      ),
                      const SizedBox(height: 24),
                      Row(children: [
                        _key('7'),
                        _key('8'),
                        _key('9'),
                        _key('/', color: theme.colorScheme.secondary),
                      ]),
                      Row(children: [
                        _key('4'),
                        _key('5'),
                        _key('6'),
                        _key('*', color: theme.colorScheme.secondary),
                      ]),
                      Row(children: [
                        _key('1'),
                        _key('2'),
                        _key('3'),
                        _key('-', color: theme.colorScheme.secondary),
                      ]),
                      Row(children: [
                        _key('0'),
                        _key('.'),
                        _key('⌫', onPressed: _backspace),
                        _key('+', color: theme.colorScheme.secondary),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        _key('C', color: Colors.redAccent, onPressed: _clear),
                        _key('=', color: theme.colorScheme.tertiary, onPressed: _evaluate),
                      ]),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
