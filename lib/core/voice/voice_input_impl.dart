import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:nexacalc/core/interfaces/voice_input.dart';
import 'package:nexacalc/core/stubs/whisper_kit_stub.dart';

class VoiceInputImpl implements VoiceInput {
  final _whisper = WhisperKit();
  final _noiseController = StreamController<double>.broadcast();

  @override
  Stream<double> get noiseLevelStream => _noiseController.stream;

  @override
  Future<String> transcribe() async {
    // Request RECORD_AUDIO permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw VoiceInputException('Microphone permission denied');
    }

    try {
      // Forward noise levels (stub will not call this in practice)
      final result = await _whisper.transcribe(onNoiseLevel: (level) {
        _noiseController.add(level.clamp(0.0, 1.0));
      });
      return result;
    } catch (e) {
      throw VoiceInputException('Transcription failed', cause: e);
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _whisper.cancel();
    } catch (_) {}
  }
}
