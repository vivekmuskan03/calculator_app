import 'package:nexacalc/core/interfaces/nl_processor.dart';
import 'package:nexacalc/core/interfaces/llm_runtime.dart';
import 'package:nexacalc/core/interfaces/regex_fallback.dart';
import 'package:nexacalc/core/interfaces/decimal_engine.dart';

/// Orchestrates LLM inference and regex fallback.
class NLProcessorImpl implements NLProcessor {
  final LLMRuntime llm;
  final RegexFallback fallback;
  final DecimalEngine engine;

  NLProcessorImpl({required this.llm, required this.fallback, required this.engine});

  @override
  Future<NLResult> interpret(String query) async {
    // 1) If model loaded, try LLM inference
    if (llm.isModelLoaded) {
      try {
        final raw = await llm.infer(query);
        final trimmed = raw.trim();
        // Validate by attempting to parse with engine
        final eval = engine.evaluate(trimmed);
        if (eval is DecimalSuccess) {
          return NLResult(expression: trimmed, displayText: '$query → $trimmed');
        }
        // Otherwise, fall through to regex
      } catch (e) {
        // Fall back to regex on any LLM error
      }
    }

    // 2) Regex fallback
    final parsed = fallback.parse(query);
    if (parsed != null) {
      return NLResult(expression: parsed, displayText: '$query → $parsed');
    }

    // 3) Nothing worked
    throw NLParseException(query: query, reason: 'LLM and regex fallback both failed');
  }
}
