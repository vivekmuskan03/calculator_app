/// Stub implementation of llm_llamacpp for NexaCalc.
///
/// The real `llm_llamacpp` package does not exist on pub.dev. This stub
/// provides the same API surface so that [LLMRuntimeImpl] can compile and
/// be tested. Replace with the real package when it becomes available.
///
/// In production, this would wrap the llama.cpp library via FFI to run
/// Phi-3-mini-4k-instruct-Q4_K_M.gguf entirely on-device.
library llm_llamacpp_stub;

/// Stub for the llama.cpp inference context.
///
/// In the real implementation this would manage the GGUF model file,
/// initialise the llama.cpp context, and run token-by-token inference.
class LlamaCpp {
  /// Whether a model has been loaded into the llama.cpp context.
  bool get isLoaded => false;

  /// Loads a GGUF model file from [modelPath].
  ///
  /// [contextSize] controls the KV-cache size (default 4096 tokens).
  Future<void> loadModel(String modelPath, {int contextSize = 4096}) async {
    throw UnimplementedError(
      'LlamaCpp is a stub. Replace with the real llm_llamacpp package.',
    );
  }

  /// Runs inference on [prompt] with the given [systemPrompt].
  ///
  /// Returns the raw model output string. The caller is responsible for
  /// validating that the output is a parseable arithmetic expression.
  Future<String> infer(
    String prompt, {
    String systemPrompt = '',
    int maxTokens = 128,
    double temperature = 0.0,
  }) async {
    throw UnimplementedError(
      'LlamaCpp is a stub. Replace with the real llm_llamacpp package.',
    );
  }

  /// Releases the llama.cpp context and frees native memory.
  void dispose() {
    // No-op in stub.
  }
}
