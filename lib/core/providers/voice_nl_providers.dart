import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexacalc/core/voice/voice_input_impl.dart';
import 'package:nexacalc/core/nlp/nl_processor_impl.dart';
import 'package:nexacalc/core/stubs/llm_llamacpp_stub.dart';
import 'package:nexacalc/core/nlp/regex_fallback_impl.dart';
import 'package:nexacalc/core/engine/decimal_engine_impl.dart';
import 'package:nexacalc/core/llm/llm_runtime_impl.dart';

final voiceInputProvider = Provider.autoDispose((ref) => VoiceInputImpl());

final llmRuntimeProvider = Provider((ref) => LLMRuntimeImpl());

final regexFallbackProvider = Provider((ref) => RegexFallbackImpl());

final nlProcessorProvider = Provider((ref) {
  final llm = ref.read(llmRuntimeProvider);
  final fallback = ref.read(regexFallbackProvider);
  final engine = DecimalEngineImpl();
  return NLProcessorImpl(llm: llm, fallback: fallback, engine: engine);
});
