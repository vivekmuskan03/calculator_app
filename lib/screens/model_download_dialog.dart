import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexacalc/core/providers/voice_nl_providers.dart';

class ModelDownloadDialog extends ConsumerStatefulWidget {
  const ModelDownloadDialog({super.key});

  @override
  ConsumerState<ModelDownloadDialog> createState() => _ModelDownloadDialogState();
}

class _ModelDownloadDialogState extends ConsumerState<ModelDownloadDialog> {
  final _controller = TextEditingController();
  double _progress = 0.0;
  String _status = '';
  bool _downloading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _downloading = true;
      _status = 'Starting...';
    });
    final runtime = ref.read(llmRuntimeProvider);
    try {
      await runtime.downloadModel(
        modelUrl: url,
        onProgress: (progress, downloaded, total) {
          setState(() {
            _progress = progress;
            _status = 'Downloaded ${downloaded} / ${total == -1 ? 'unknown' : total} bytes';
          });
        },
      );
      setState(() {
        _status = 'Download complete';
        _downloading = false;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _status = 'Download failed: $e';
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download LLM model'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Model file URL', labelText: 'Model URL'),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          Semantics(label: 'Download progress', value: '${(_progress * 100).toStringAsFixed(0)} percent'),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: _downloading ? _progress : null),
          const SizedBox(height: 8),
          Text(_status),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ElevatedButton(onPressed: _downloading ? null : _start, child: const Text('Download')),
      ],
    );
  }
}
