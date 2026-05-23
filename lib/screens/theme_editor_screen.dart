import 'package:flutter/material.dart';
import 'package:nexacalc/core/theme/theme_editor_impl.dart';
import 'package:nexacalc/core/interfaces/theme_editor.dart';

class ThemeEditorScreen extends StatefulWidget {
  final ThemeEditorImpl themeEditor;
  const ThemeEditorScreen({super.key, required this.themeEditor});

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  late AppTheme _theme;

  @override
  void initState() {
    super.initState();
    _theme = widget.themeEditor.currentTheme;
  }

  void _pickColor(String field) async {
    // Present a simple dialog with preset colours for simplicity.
    final colors = [
      Colors.tealAccent.shade200,
      Colors.cyanAccent.shade200,
      Colors.pinkAccent.shade200,
      Colors.greenAccent.shade200,
      Colors.deepOrangeAccent.shade200,
      Colors.white,
      Colors.grey,
    ];
    final picked = await showDialog<Color?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pick colour'),
        children: colors
            .map((c) => SimpleDialogOption(
                  child: Container(height: 32, color: c),
                  onPressed: () => Navigator.of(context).pop(c),
                ))
            .toList(),
      ),
    );
    if (picked == null) return;
    setState(() {
      switch (field) {
        case 'bgStart':
          _theme = _theme.copyWith(backgroundStart: picked);
          break;
        case 'bgEnd':
          _theme = _theme.copyWith(backgroundEnd: picked);
          break;
        case 'num':
          _theme = _theme.copyWith(numberBorder: picked);
          break;
        case 'op':
          _theme = _theme.copyWith(operatorBorder: picked);
          break;
        case 'eq':
          _theme = _theme.copyWith(equalsBorder: picked);
          break;
      }
    });
  }

  Future<void> _save() async {
    await widget.themeEditor.saveTheme(_theme);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme saved')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Editor'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Background Start'),
              trailing: GestureDetector(
                onTap: () => _pickColor('bgStart'),
                child: Container(width: 48, height: 32, color: _theme.backgroundStart),
              ),
            ),
            ListTile(
              title: const Text('Background End'),
              trailing: GestureDetector(
                onTap: () => _pickColor('bgEnd'),
                child: Container(width: 48, height: 32, color: _theme.backgroundEnd),
              ),
            ),
            ListTile(
              title: const Text('Number Border'),
              trailing: GestureDetector(
                onTap: () => _pickColor('num'),
                child: Container(width: 48, height: 32, color: _theme.numberBorder),
              ),
            ),
            ListTile(
              title: const Text('Operator Border'),
              trailing: GestureDetector(
                onTap: () => _pickColor('op'),
                child: Container(width: 48, height: 32, color: _theme.operatorBorder),
              ),
            ),
            ListTile(
              title: const Text('Equals Border'),
              trailing: GestureDetector(
                onTap: () => _pickColor('eq'),
                child: Container(width: 48, height: 32, color: _theme.equalsBorder),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Save Theme')),
          ],
        ),
      ),
    );
  }
}
