// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:balance_sheet_ledger/main.dart';

void main() {
  testWidgets('renders dashboard and generated ledger route',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(const BalanceSheetLedgerApp());

    expect(find.text('Bharat Manufacturing Co.'), findsOneWidget);
    expect(find.text('CURRENT CASH / BANK'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Quick Dashboard Action'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Entry'));
    await tester.pumpAndSettle();
    expect(find.text('Add Ledger Entry'), findsOneWidget);

    await tester.tap(find.text('Save Draft'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ledger'));
    await tester.pumpAndSettle();

    expect(find.text('Bharat Manufacturing Co.'), findsOneWidget);
    expect(find.text('CASH BALANCE'), findsOneWidget);
  });
}
