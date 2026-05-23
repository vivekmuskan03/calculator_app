import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexacalc/screens/history_screen.dart';
import 'package:nexacalc/core/interfaces/history_db.dart';

class FakeHistoryDB implements HistoryDB {
  final List<HistoryEntry> _entries;
  FakeHistoryDB([this._entries = const []]);

  @override
  Future<void> insert(HistoryEntry entry) async {}

  @override
  Future<void> updateMemo(int id, String memo) async {}

  @override
  Future<List<HistoryEntry>> queryAll() async => _entries;

  @override
  Future<List<HistoryEntry>> search(String query) async => [];

  @override
  Future<void> exportToCSV(String filePath) async {}
}

void main() {
  testWidgets('History screen renders empty list', (tester) async {
    await tester.pumpWidget(MaterialApp(home: HistoryScreen(historyDb: FakeHistoryDB())));
    await tester.pumpAndSettle();
    // No list tiles
    expect(find.byType(ListTile), findsNothing);
    expect(find.text('History'), findsOneWidget);
  });
}
