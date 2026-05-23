/// Abstract interface for the SQLite-backed calculation history database.
///
/// Uses sqflite to persist every completed calculation with full-text search
/// support via an FTS5 virtual table (Requirement 5.1).
abstract class HistoryDB {
  /// Inserts a new [entry] into the history table.
  ///
  /// The [entry.id] field is ignored on insert; the database assigns the id.
  /// [entry.timestamp] should be Unix epoch milliseconds (Requirement 5.2).
  Future<void> insert(HistoryEntry entry);

  /// Updates the memo text for the entry with the given [id] (Requirement 5.6).
  Future<void> updateMemo(int id, String memo);

  /// Returns all history entries ordered by timestamp descending.
  Future<List<HistoryEntry>> queryAll();

  /// Returns entries whose expression, result, or memo contains [query]
  /// (case-insensitive). Uses FTS5 for efficient full-text search (Requirement 5.7).
  Future<List<HistoryEntry>> search(String query);

  /// Writes all history entries to a CSV file at [filePath].
  ///
  /// CSV columns: id, expression, result, timestamp, memo (Requirement 10.2).
  /// Throws on storage write failure.
  Future<void> exportToCSV(String filePath);
}

/// A single calculation history record.
///
/// Maps directly to the SQLite `history` table schema (Requirement 5.1):
/// ```sql
/// CREATE TABLE history (
///   id        INTEGER PRIMARY KEY AUTOINCREMENT,
///   expression TEXT    NOT NULL,
///   result     TEXT    NOT NULL,
///   timestamp  INTEGER NOT NULL,
///   memo       TEXT    NOT NULL DEFAULT ''
/// );
/// ```
class HistoryEntry {
  /// Database-assigned primary key. Null before the first insert.
  final int? id;

  /// The arithmetic expression that was evaluated (e.g. `"0.1 + 0.2"`).
  final String expression;

  /// The formatted result string (e.g. `"0.3"`).
  final String result;

  /// Unix epoch milliseconds at the time of the calculation.
  final int timestamp;

  /// Optional user-supplied note attached to this entry. Empty string by default.
  final String memo;

  const HistoryEntry({
    this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.memo = '',
  });

  /// Creates a copy of this entry with the given fields replaced.
  HistoryEntry copyWith({
    int? id,
    String? expression,
    String? result,
    int? timestamp,
    String? memo,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      memo: memo ?? this.memo,
    );
  }

  /// Converts this entry to a map suitable for sqflite insert/update.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'expression': expression,
      'result': result,
      'timestamp': timestamp,
      'memo': memo,
    };
  }

  /// Creates a [HistoryEntry] from a sqflite row map.
  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as int?,
      expression: map['expression'] as String,
      result: map['result'] as String,
      timestamp: map['timestamp'] as int,
      memo: (map['memo'] as String?) ?? '',
    );
  }

  @override
  String toString() =>
      'HistoryEntry(id: $id, expression: $expression, result: $result, '
      'timestamp: $timestamp, memo: $memo)';

  @override
  bool operator ==(Object other) =>
      other is HistoryEntry &&
      other.id == id &&
      other.expression == expression &&
      other.result == result &&
      other.timestamp == timestamp &&
      other.memo == memo;

  @override
  int get hashCode =>
      Object.hash(id, expression, result, timestamp, memo);
}
