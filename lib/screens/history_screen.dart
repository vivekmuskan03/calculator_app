import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nexacalc/core/db/history_db_impl.dart';
import 'package:nexacalc/core/interfaces/history_db.dart';
import 'package:cross_file/cross_file.dart';

/// History screen showing recent calculations. Accepts an optional
/// [historyDb] for dependency injection in tests; defaults to
/// `HistoryDBImpl()` in production.
class HistoryScreen extends StatefulWidget {
  final HistoryDB? historyDb;

  const HistoryScreen({super.key, this.historyDb});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryDB _db;
  List<HistoryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _db = widget.historyDb ?? HistoryDBImpl();
    _load();
  }

  Future<void> _load() async {
    final rows = await _db.queryAll();
    setState(() {
      _entries = rows;
      _loading = false;
    });
  }

  Future<void> _exportCsv() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/nexacalc_history_export.csv';
    await _db.exportToCSV(path);
    try {
      await Share.shareXFiles([XFile(path)], text: 'NexaCalc history export');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to $path')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: _exportCsv)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final e = _entries[index];
                return ListTile(
                  title: Text(e.expression),
                  subtitle: Text(e.result),
                  trailing: e.memo.isNotEmpty ? const Icon(Icons.note) : null,
                  onTap: () => Navigator.of(context).pop(e.expression),
                );
              },
            ),
    );
  }
}
