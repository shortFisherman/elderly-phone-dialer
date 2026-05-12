import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/app.dart';

void main() {
  testWidgets('App boots without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ElderlyPhoneApp());
    // On first launch with no contacts, shows loading indicator then auto-enters manage mode
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
