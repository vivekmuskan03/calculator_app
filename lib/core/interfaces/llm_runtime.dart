/// Abstract interface for the on-device LLM inference runtime.
///
/// Wraps the llm_llamacpp stub (the real package does not exist on pub.dev).
/// Manages the lifecycle of the Phi-3-mini-4k-instruct-Q4_K_M.gguf model file:
/// download, load, and inference.
abstract class LLMRuntime {
  /// Whether the model file has been loaded and is ready for inference.
  bool get isModelLoaded;

  /// Downloads the model file to the app documents directory.
  ///
  /// [onProgress] is called with values in [0.0, 1.0] as the download proceeds.
  /// The callback also receives the number of bytes downloaded and total bytes
  /// so the UI can display "X MB / Y MB" (Requirement 3.2).
  ///
  /// Throws on network error or insufficient storage.
  Future<void> downloadModel({
    required void Function(double progress, int downloadedBytes, int totalBytes)
        onProgress,
    /// Optional URL to download the model from. If omitted, the runtime may
    /// use its configured default or throw.
    String? modelUrl,
  });

  /// Loads the model file from disk into the llama.cpp context.
  ///
  /// Must be called after [downloadModel] completes, or on subsequent launches
  /// when the model file is already present (Requirement 3.6).
  Future<void> loadModel();

  /// Runs inference on [prompt] and returns the raw model output string.
  ///
  /// The system prompt instructs the model to return only an arithmetic
  /// expression using numbers and operators (+, -, *, /, %, sqrt).
  Future<String> infer(String prompt);
}
