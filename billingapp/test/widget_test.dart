import 'package:billingapp/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const BillingApp());
    expect(find.text('DHINADTS Billing'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
