/// Abstract interface for the offline voice input component.
///
/// Wraps the whisper_kit stub (the real package does not exist on pub.dev).
/// Manages microphone permission, audio capture, and on-device transcription.
/// All processing is offline — no internet connection required (Requirement 4.1).
abstract class VoiceInput {
  /// Stream of ambient noise level values in the range [0.0, 1.0].
  ///
  /// Emitted continuously while audio capture is active. Used by the UI to
  /// drive the real-time noise level visual indicator (Requirement 4.3).
  Stream<double> get noiseLevelStream;

  /// Requests RECORD_AUDIO permission (if not already granted), starts audio
  /// capture, and returns the transcribed text when the user stops speaking.
  ///
  /// Throws a [VoiceInputException] if:
  /// - The RECORD_AUDIO permission is denied
  /// - Audio capture fails due to a hardware error
  /// - Transcription times out
  Future<String> transcribe();

  /// Stops the current audio capture session without returning a transcription.
  Future<void> cancel();
}

/// Thrown by [VoiceInput.transcribe] when capture or transcription fails.
class VoiceInputException implements Exception {
  /// Human-readable description of the failure, shown to the user.
  final String message;

  /// The underlying cause, if available.
  final Object? cause;

  const VoiceInputException(this.message, {this.cause});

  @override
  String toString() => 'VoiceInputException: $message';
}
