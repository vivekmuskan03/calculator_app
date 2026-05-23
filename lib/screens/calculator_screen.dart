import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexacalc/core/providers/calculator_notifier.dart';
import 'package:nexacalc/widgets/ad_banner.dart';
import 'package:nexacalc/screens/history_screen.dart';
import 'package:nexacalc/core/providers/voice_nl_providers.dart';
import 'package:flutter/services.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _append(CalculatorNotifier notifier, String s) {
    final sel = _controller.selection;
    final text = _controller.text;
    final newText = text.replaceRange(sel.start, sel.end, s);
    final newPos = sel.start + s.length;
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: newPos);
    notifier.setExpression(newText);
  }

  void _backspace(CalculatorNotifier notifier) {
    final sel = _controller.selection;
    final text = _controller.text;
    if (sel.start != sel.end) {
      // delete selection
      final newText = text.replaceRange(sel.start, sel.end, '');
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: sel.start);
      notifier.setExpression(newText);
      return;
    }
    if (sel.start == 0) return;
    final newStart = sel.start - 1;
    final newText = text.replaceRange(newStart, sel.start, '');
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: newStart);
    notifier.setExpression(newText);
  }

  void _clear(CalculatorNotifier notifier) {
    _controller.clear();
    notifier.clear();
  }

  void _evaluate(CalculatorNotifier notifier) {
    // Ensure provider has latest expression
    notifier.setExpression(_controller.text);
    notifier.evaluate();
  }

  Widget _buildButton(String label, {Color? color, VoidCallback? onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Tooltip(
          message: 'Press $label',
          child: Semantics(
            button: true,
            label: 'Key $label',
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color ?? Colors.white12,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: onPressed ?? () {},
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('NexaCalc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () async {
              final expr = await Navigator.of(context).push<String?>(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
              if (expr != null) {
                final notifier = ref.read(calculatorProvider);
                _controller.text = expr;
                _controller.selection = TextSelection.collapsed(offset: expr.length);
                notifier.setExpression(expr);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0F1F), Color(0xFF10172A)],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('NexaCalc', style: theme.textTheme.displayLarge),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Consumer(builder: (context, ref, _) {
                            final expression = ref.watch(calculatorProvider.select((c) => c.state.expression));
                            // Keep controller synced when provider expression changes (external updates)
                            if (_controller.text != expression) {
                              _controller.text = expression;
                              _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                            }
                            return TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: theme.textTheme.displayLarge,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(border: InputBorder.none),
                              keyboardType: TextInputType.none,
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Consumer(builder: (context, ref, _) {
                          final result = ref.watch(calculatorProvider.select((c) => c.state.result));
                          return GestureDetector(
                            onTap: () async {
                              final data = result;
                              if (data.isEmpty) return;
                              await Clipboard.setData(ClipboardData(text: data));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                            },
                            child: Text(result, style: theme.textTheme.displayMedium),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Consumer(builder: (context, ref, _) {
                      final notifier = ref.read(calculatorProvider);
                      return Row(children: [
                        _buildButton('7', onPressed: () => _append(notifier, '7')),
                        _buildButton('8', onPressed: () => _append(notifier, '8')),
                        _buildButton('9', onPressed: () => _append(notifier, '9')),
                        _buildButton('/', color: theme.colorScheme.secondary, onPressed: () => _append(notifier, '/')),
                      ]);
                    }),
                    Consumer(builder: (context, ref, _) {
                      final notifier = ref.read(calculatorProvider);
                      return Row(children: [
                        _buildButton('4', onPressed: () => _append(notifier, '4')),
                        _buildButton('5', onPressed: () => _append(notifier, '5')),
                        _buildButton('6', onPressed: () => _append(notifier, '6')),
                        _buildButton('*', color: theme.colorScheme.secondary, onPressed: () => _append(notifier, '*')),
                      ]);
                    }),
                    Consumer(builder: (context, ref, _) {
                      final notifier = ref.read(calculatorProvider);
                      return Row(children: [
                        _buildButton('1', onPressed: () => _append(notifier, '1')),
                        _buildButton('2', onPressed: () => _append(notifier, '2')),
                        _buildButton('3', onPressed: () => _append(notifier, '3')),
                        _buildButton('-', color: theme.colorScheme.secondary, onPressed: () => _append(notifier, '-')),
                      ]);
                    }),
                    Consumer(builder: (context, ref, _) {
                      final notifier = ref.read(calculatorProvider);
                      return Row(children: [
                        _buildButton('0', onPressed: () => _append(notifier, '0')),
                        _buildButton('.', onPressed: () => _append(notifier, '.')),
                        // Microphone button
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Tooltip(
                              message: 'Voice input',
                              child: Semantics(
                                button: true,
                                label: 'Start voice input',
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, padding: const EdgeInsets.symmetric(vertical: 18)),
                                  onPressed: () async {
                                final voice = ref.read(voiceInputProvider);
                                final nl = ref.read(nlProcessorProvider);
                                try {
                                  // Start transcription
                                  final text = await voice.transcribe();
                                  // Interpret NL
                                  final result = await nl.interpret(text);
                                  // Show interpreted text briefly and set expression
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.displayText), duration: const Duration(seconds: 2)));
                                  _controller.text = result.expression;
                                  _controller.selection = TextSelection.collapsed(offset: result.expression.length);
                                  final notifier = ref.read(calculatorProvider);
                                  notifier.setExpression(result.expression);
                                  await notifier.evaluate();
                                } on UnimplementedError catch (_) {
                                  // Fallback for development when whisper stub isn't implemented.
                                  final manual = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) {
                                      final c = TextEditingController();
                                      return AlertDialog(
                                        title: const Text('Manual transcription (dev)'),
                                        content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Type what you said')),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                                          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(c.text), child: const Text('OK')),
                                        ],
                                      );
                                    },
                                  );
                                  if (manual != null && manual.trim().isNotEmpty) {
                                    try {
                                      final result = await nl.interpret(manual.trim());
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.displayText), duration: const Duration(seconds: 2)));
                                      _controller.text = result.expression;
                                      _controller.selection = TextSelection.collapsed(offset: result.expression.length);
                                      final notifier = ref.read(calculatorProvider);
                                      notifier.setExpression(result.expression);
                                      await notifier.evaluate();
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('NL parse failed: $e')));
                                    }
                                  }
                                } on Exception catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voice error: $e')));
                                }
                              },
                                  child: const Icon(Icons.mic),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildButton('+', color: theme.colorScheme.secondary, onPressed: () => _append(notifier, '+')),
                      ]);
                    }),
                    Consumer(builder: (context, ref, _) {
                      final notifier = ref.read(calculatorProvider);
                      return Row(children: [
                        _buildButton('C', color: Colors.redAccent, onPressed: () => _clear(notifier)),
                        _buildButton('=', color: theme.colorScheme.tertiary, onPressed: () => _evaluate(notifier)),
                      ]);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: AdBanner(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
