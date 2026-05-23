import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:nexacalc/core/interfaces/llm_runtime.dart';
import 'package:nexacalc/core/stubs/llm_llamacpp_stub.dart';

/// Simple on-device LLM runtime implementation using the `llm_llamacpp` stub.
///
/// Responsibilities:
/// - Download model file to app documents directory with progress callback
/// - Load model into llama.cpp context
/// - Run inference via the stub
class LLMRuntimeImpl implements LLMRuntime {
  final LlamaCpp _llama = LlamaCpp();
  String? _modelPath;

  @override
  bool get isModelLoaded => _llama.isLoaded;

  /// Downloads [modelUrl] to the app documents directory and reports
  /// progress via [onProgress] (0.0–1.0 plus bytes counts).
  @override
  Future<void> downloadModel({required void Function(double progress, int downloadedBytes, int totalBytes) onProgress, String? modelUrl}) async {
    // If a modelUrl is provided, download it into the app documents directory.
    final dir = await getApplicationDocumentsDirectory();
    final defaultName = 'phi-3-mini-4k-instruct-Q4_K_M.gguf';
    final targetPath = p.join(dir.path, modelUrl != null ? p.basename(modelUrl) : defaultName);

    if (modelUrl == null) {
      throw ArgumentError('modelUrl is required for download in this implementation');
    }

    final uri = Uri.parse(modelUrl);
    await _downloadToFile(uri, targetPath, onProgress);
    _modelPath = targetPath;
  }

  /// Helper to download a file from [url] into [targetPath]. Reports progress.
  Future<void> _downloadToFile(Uri url, String targetPath, void Function(double, int, int) onProgress) async {
    final client = http.Client();
    final req = http.Request('GET', url);
    final streamed = await client.send(req);
    final total = streamed.contentLength ?? -1;
    final file = File(targetPath);
    final sink = file.openWrite();
    int downloaded = 0;

    await for (final chunk in streamed.stream) {
      downloaded += chunk.length;
      sink.add(chunk);
      if (total > 0) {
        onProgress(downloaded / total, downloaded, total);
      } else {
        onProgress(0.0, downloaded, total);
      }
    }

    await sink.flush();
    await sink.close();
    client.close();
  }

  /// Loads a model file previously downloaded into the llama.cpp context.
  ///
  /// Looks for `modelPath` in the app documents directory if not explicitly set.
  @override
  Future<void> loadModel() async {
    final dir = await getApplicationDocumentsDirectory();
    // Default model filename used by the app (caller may change this behavior).
    final defaultName = 'phi-3-mini-4k-instruct-Q4_K_M.gguf';
    final modelPath = _modelPath ?? p.join(dir.path, defaultName);

    final file = File(modelPath);
    if (!await file.exists()) {
      throw FileSystemException('Model file not found', modelPath);
    }

    await _llama.loadModel(modelPath);
    _modelPath = modelPath;
  }

  /// Runs inference using the underlying llama.cpp stub.
  @override
  Future<String> infer(String prompt) async {
    if (!_llama.isLoaded) {
      throw StateError('Model not loaded');
    }
    // Use a conservative system prompt in production; here we forward prompt.
    return await _llama.infer(prompt, systemPrompt: 'Return only an arithmetic expression');
  }
}
