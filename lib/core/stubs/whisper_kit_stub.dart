/// Stub implementation of whisper_kit for NexaCalc.
///
/// The real `whisper_kit` package does not exist on pub.dev. This stub
/// provides the same API surface so that [VoiceInputImpl] can compile and
/// be tested. Replace with the real package when it becomes available.
///
/// In production, this would wrap the native whisper.cpp library via a
/// Flutter platform channel or FFI binding.
library whisper_kit_stub;

/// Stub for the WhisperKit transcription engine.
///
/// In the real implementation this would initialise the whisper.cpp model
/// and expose audio capture + transcription functionality.
class WhisperKit {
  /// Whether the whisper model has been loaded and is ready for transcription.
  bool get isModelLoaded => false;

  /// Loads the whisper model from the app bundle or documents directory.
  Future<void> loadModel() async {
    throw UnimplementedError(
      'WhisperKit is a stub. Replace with the real whisper_kit package.',
    );
  }

  /// Starts audio capture and returns the transcribed text.
  ///
  /// [onNoiseLevel] is called with values in [0.0, 1.0] during capture.
  Future<String> transcribe({
    void Function(double level)? onNoiseLevel,
  }) async {
    throw UnimplementedError(
      'WhisperKit is a stub. Replace with the real whisper_kit package.',
    );
  }

  /// Cancels the current audio capture session.
  Future<void> cancel() async {
    throw UnimplementedError(
      'WhisperKit is a stub. Replace with the real whisper_kit package.',
    );
  }
}
