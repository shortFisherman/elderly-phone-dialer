import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const PhoneCallApp());
    expect(find.text('Phone Call 2.0'), findsOneWidget);
  });
}
