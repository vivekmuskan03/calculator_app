import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexacalc/screens/calculator_screen.dart';

void main() {
  testWidgets('Calculator screen renders and shows buttons', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: CalculatorScreen())));

    // Expect title and some buttons present
    expect(find.text('NexaCalc'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('+'), findsWidgets);
    expect(find.text('='), findsWidgets);
  });

  testWidgets('History button opens history screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: CalculatorScreen())));
    expect(find.byIcon(Icons.history), findsOneWidget);
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    // Should navigate; HistoryScreen app bar title is 'History'
    expect(find.text('History'), findsOneWidget);
  });
}
