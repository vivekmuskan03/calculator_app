import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexacalc/core/interfaces/history_db.dart';
import 'package:nexacalc/screens/calculator_screen.dart';

class FakeHistoryDB implements HistoryDB {
  const FakeHistoryDB();

  @override
  Future<void> exportToCSV(String filePath) async {}

  @override
  Future<void> insert(HistoryEntry entry) async {}

  @override
  Future<List<HistoryEntry>> queryAll() async => const [];

  @override
  Future<List<HistoryEntry>> search(String query) async => const [];

  @override
  Future<void> updateMemo(int id, String memo) async {}
}

void main() {
  testWidgets('Calculator screen renders and shows buttons', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: CalculatorScreen(historyDb: FakeHistoryDB()))));

    // Expect title and some buttons present
    expect(find.text('NexaCalc'), findsWidgets);
    expect(find.text('1'), findsWidgets);
    expect(find.text('+'), findsWidgets);
    expect(find.text('='), findsWidgets);
  });

  testWidgets('History button opens history screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: CalculatorScreen(historyDb: FakeHistoryDB()))));
    expect(find.byIcon(Icons.history), findsOneWidget);
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Should navigate; HistoryScreen app bar title is 'History'
    expect(find.text('History'), findsOneWidget);
  });
}
