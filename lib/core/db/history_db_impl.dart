import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nexacalc/core/interfaces/history_db.dart';

class HistoryDBImpl implements HistoryDB {
  static const _dbName = 'nexacalc_history.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: (db, ver) async {
      await db.execute('''
        CREATE TABLE history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          expression TEXT NOT NULL,
          result TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          memo TEXT NOT NULL DEFAULT ''
        )
      ''');

      // Create an FTS5 virtual table for full-text search on expression/result/memo
      await db.execute('''
        CREATE VIRTUAL TABLE history_fts USING fts5(expression, result, memo, content='history', content_rowid='id');
      ''');

      // Trigger to keep FTS in sync
      await db.execute('''
        CREATE TRIGGER history_ai AFTER INSERT ON history BEGIN
          INSERT INTO history_fts(rowid, expression, result, memo) VALUES (new.id, new.expression, new.result, new.memo);
        END;
      ''');

      await db.execute('''
        CREATE TRIGGER history_ad AFTER DELETE ON history BEGIN
          INSERT INTO history_fts(history_fts, rowid, expression, result, memo) VALUES('delete', old.id, old.expression, old.result, old.memo);
        END;
      ''');

      await db.execute('''
        CREATE TRIGGER history_au AFTER UPDATE ON history BEGIN
          INSERT INTO history_fts(history_fts, rowid, expression, result, memo) VALUES('delete', old.id, old.expression, old.result, old.memo);
          INSERT INTO history_fts(rowid, expression, result, memo) VALUES (new.id, new.expression, new.result, new.memo);
        END;
      ''');
    });
  }

  @override
  Future<void> insert(HistoryEntry entry) async {
    final db = await _database;
    await db.insert('history', entry.toMap());
  }

  @override
  Future<void> updateMemo(int id, String memo) async {
    final db = await _database;
    await db.update('history', {'memo': memo}, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<HistoryEntry>> queryAll() async {
    final db = await _database;
    final rows = await db.query('history', orderBy: 'timestamp DESC');
    return rows.map((r) => HistoryEntry.fromMap(r)).toList();
  }

  @override
  Future<List<HistoryEntry>> search(String query) async {
    final db = await _database;
    // Use FTS5 to match against expression, result, memo
    final rows = await db.rawQuery('''
      SELECT h.* FROM history h JOIN history_fts f ON h.id = f.rowid
      WHERE history_fts MATCH ? ORDER BY h.timestamp DESC
    ''', [query]);
    return rows.map((r) => HistoryEntry.fromMap(r)).toList();
  }

  @override
  Future<void> exportToCSV(String filePath) async {
    final entries = await queryAll();
    final file = File(filePath);
    final sink = file.openWrite();
    // CSV header
    sink.writeln('id,expression,result,timestamp,memo');
    for (final e in entries) {
      final escapedExpression = e.expression.replaceAll('"', '""');
      final escapedResult = e.result.replaceAll('"', '""');
      final escapedMemo = e.memo.replaceAll('"', '""');
      sink.writeln('${e.id},"$escapedExpression","$escapedResult",${e.timestamp},"$escapedMemo"');
    }
    await sink.flush();
    await sink.close();
  }
}
