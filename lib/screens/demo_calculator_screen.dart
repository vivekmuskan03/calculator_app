import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:nexacalc/core/engine/decimal_engine_impl.dart';
import 'package:nexacalc/core/formatter/indian_formatter_impl.dart';
import 'package:nexacalc/core/interfaces/decimal_engine.dart';

/// A polished, plugin-free calculator demo for web and desktop.
class DemoCalculatorScreen extends StatefulWidget {
  const DemoCalculatorScreen({super.key});

  @override
  State<DemoCalculatorScreen> createState() => _DemoCalculatorScreenState();
}

class _DemoCalculatorScreenState extends State<DemoCalculatorScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final DecimalEngine _engine = DecimalEngineImpl();
  final IndianFormatterImpl _formatter = const IndianFormatterImpl();

  String _result = '';
  String _status = 'Exact decimal math';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int _safeSelectionStart() {
    final selection = _controller.selection;
    if (!selection.isValid || selection.start < 0) {
      return _controller.text.length;
    }
    return selection.start;
  }

  int _safeSelectionEnd(int start) {
    final selection = _controller.selection;
    if (!selection.isValid || selection.end < 0) {
      return start;
    }
    return selection.end;
  }

  void _insert(String text) {
    final start = _safeSelectionStart();
    final end = _safeSelectionEnd(start);
    final updated = _controller.text.replaceRange(start, end, text);
    _controller.text = updated;
    _controller.selection = TextSelection.collapsed(offset: start + text.length);
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

    final start = _safeSelectionStart();
    if (start == 0) return;
    final updated = _controller.text.replaceRange(start - 1, start, '');
    _controller.text = updated;
    _controller.selection = TextSelection.collapsed(offset: start - 1);
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _result = '';
    _status = 'Ready';
    setState(() {});
  }

  void _applyExample(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    _evaluate();
  }

  void _evaluate() {
    final evaluation = _engine.evaluate(_controller.text);
    setState(() {
      if (evaluation is DecimalSuccess) {
        _result = _formatter.format(evaluation.value);
        _status = 'Exact decimal result';
      } else if (evaluation is DecimalDivisionByZero) {
        _result = 'Undefined';
        _status = 'Division by zero';
      } else if (evaluation is DecimalComplexResult) {
        _result = 'Complex result (i)';
        _status = 'Negative square root';
      } else if (evaluation is DecimalSyntaxError) {
        _result = 'Syntax error';
        _status = 'Check the expression';
      } else {
        _result = 'Error';
        _status = 'Unexpected error';
      }
    });
  }

  Widget _chip(String label, VoidCallback onTap, {Color? fill, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: fill ?? const Color(0xFFE9ECFF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD7DBFF)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor ?? const Color(0xFF26324A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _key(
    String label, {
    VoidCallback? onPressed,
    Color? background,
    Color? foreground,
    double flex = 1,
  }) {
    return Expanded(
      flex: flex.round(),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AnimatedScale(
          scale: 1,
          duration: const Duration(milliseconds: 120),
          child: ElevatedButton(
            onPressed: onPressed ?? () => _insert(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: background ?? Colors.white,
              foregroundColor: foreground ?? const Color(0xFF0F172A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _heroPanel(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF2F4FF)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x1A334155), blurRadius: 40, offset: Offset(0, 18)),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'NexaCalc Demo',
              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5C4DFF)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Exact decimal math for Indian users.',
            style: theme.textTheme.displayLarge,
          ),
          const SizedBox(height: 14),
          Text(
            'Fast calculations, Indian grouping, and clean results - shown in a bright, browser-friendly demo.',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 18),
          Wrap(
            children: [
              _chip('1,00,000 grouping', () => _applyExample('100000')),
              _chip('24 × 64', () => _applyExample('24*64')),
              _chip('What % of 24 is 64', () => _applyExample('64*100/24')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expression', style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.none,
                        textAlign: TextAlign.left,
                        style: theme.textTheme.displayMedium?.copyWith(fontSize: 26),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 180,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5C4DFF), Color(0xFFFF4D8D)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 12)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Result', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(_result.isEmpty ? '—' : _result, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(_status, style: const TextStyle(color: Colors.white70, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calculatorPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x140F172A), blurRadius: 32, offset: Offset(0, 16)),
        ],
      ),
      child: Column(
        children: [
          Row(children: [_key('7'), _key('8'), _key('9'), _key('/', background: const Color(0xFFFF4D8D), foreground: Colors.white)]),
          Row(children: [_key('4'), _key('5'), _key('6'), _key('*', background: const Color(0xFFFF4D8D), foreground: Colors.white)]),
          Row(children: [_key('1'), _key('2'), _key('3'), _key('-', background: const Color(0xFFFF4D8D), foreground: Colors.white)]),
          Row(children: [_key('0'), _key('.'), _key('⌫', onPressed: _backspace, background: const Color(0xFFEDEBFF), foreground: const Color(0xFF5C4DFF)), _key('+', background: const Color(0xFFFF4D8D), foreground: Colors.white)]),
          const SizedBox(height: 10),
          Row(children: [_key('C', onPressed: _clear, background: const Color(0xFFFFE4E6), foreground: const Color(0xFFBE123C)), _key('=', onPressed: _evaluate, background: const Color(0xFF10B981), foreground: Colors.white)]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _DemoBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 940;
                      final hero = _heroPanel(context);
                      final calc = _calculatorPanel(context);
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: hero),
                            const SizedBox(width: 20),
                            Expanded(flex: 5, child: calc),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          hero,
                          const SizedBox(height: 20),
                          calc,
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoBackground extends StatelessWidget {
  const _DemoBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F9FF), Color(0xFFEFF2FF), Color(0xFFFFF5FB)],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -80,
            left: -40,
            child: _Blob(color: Color(0x336B5BFF), size: 260),
          ),
          Positioned(
            top: 120,
            right: -50,
            child: _Blob(color: Color(0x33FF4D8D), size: 220),
          ),
          Positioned(
            bottom: -70,
            right: 120,
            child: _Blob(color: Color(0x3310B981), size: 240),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 70, spreadRadius: 15)],
      ),
    );
  }
}
