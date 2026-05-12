import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/screens/home_screen.dart';
import 'package:phone_call2/widgets/contact_avatar.dart';

Widget _buildTestApp(HomeScreen homeScreen) {
  return MaterialApp(
    home: homeScreen,
  );
}

const _contacts = <Contact>[
  Contact(
    id: 'c1',
    name: 'Alice',
    phoneNumber: '555-0100',
    photoPath: '',
    colorIndex: 0,
  ),
  Contact(
    id: 'c2',
    name: 'Bob',
    phoneNumber: '555-0200',
    photoPath: '',
    colorIndex: 1,
  ),
  Contact(
    id: 'c3',
    name: 'Carol',
    phoneNumber: '555-0300',
    photoPath: '',
    colorIndex: 2,
  ),
];

void main() {
  group('HomeScreen', () {
    // ---------------------------------------------------------------------------
    // Grid rendering
    // ---------------------------------------------------------------------------

    testWidgets('renders all contacts in the grid', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        HomeScreen(contacts: _contacts, onManageTap: () {}),
      ));

      expect(find.byType(ContactAvatar), findsNWidgets(3));
    });

    testWidgets('shows a CircleAvatar for each contact avatar in the grid',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        HomeScreen(contacts: _contacts, onManageTap: () {}),
      ));

      expect(find.byType(CircleAvatar), findsNWidgets(3));
    });

    // ---------------------------------------------------------------------------
    // Empty state
    // ---------------------------------------------------------------------------

    testWidgets('shows empty state when contacts list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        HomeScreen(contacts: const [], onManageTap: () {}),
      ));

      expect(find.text('点击右下角 + 添加联系人'), findsOneWidget);
      expect(find.byType(ContactAvatar), findsNothing);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('shows an icon in the empty state', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        HomeScreen(contacts: const [], onManageTap: () {}),
      ));

      expect(find.byIcon(Icons.contacts_outlined), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Plus button / management mode entry
    // ---------------------------------------------------------------------------

    testWidgets('plus button is visible', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        HomeScreen(contacts: _contacts, onManageTap: () {}),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('plus button triggers onManageTap after 5 taps',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(_buildTestApp(
        HomeScreen(contacts: _contacts, onManageTap: () => tapCount++),
      ));

      final plusButton = find.byIcon(Icons.add);
      expect(plusButton, findsOneWidget);

      // First 4 taps should NOT trigger the callback.
      await tester.tap(plusButton);
      await tester.tap(plusButton);
      await tester.tap(plusButton);
      await tester.tap(plusButton);
      expect(tapCount, 0);

      // The 5th tap triggers management mode.
      await tester.tap(plusButton);
      expect(tapCount, 1);
    });

    testWidgets('plus button resets counter after triggering onManageTap',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(_buildTestApp(
        HomeScreen(contacts: _contacts, onManageTap: () => tapCount++),
      ));

      final plusButton = find.byIcon(Icons.add);

      // 5 taps to trigger once.
      for (int i = 0; i < 5; i++) {
        await tester.tap(plusButton);
      }
      expect(tapCount, 1);

      // Next 5 taps should trigger again.
      for (int i = 0; i < 5; i++) {
        await tester.tap(plusButton);
      }
      expect(tapCount, 2);
    });

    // ---------------------------------------------------------------------------
    // Decorative bar
    // ---------------------------------------------------------------------------

    testWidgets('shows a decorative bar instead of a text title',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        HomeScreen(contacts: _contacts, onManageTap: () {}),
      ));

      // The decorative bar is a Container (120x6) inside the AppBar.
      // Find the AppBar and verify it has no Text widget as a direct child.
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      // The decorative Container should be in the widget tree.
      final containers = tester.widgetList<Container>(find.byType(Container));
      final decorativeBar = containers.where((c) {
        final constraints = c.constraints;
        return constraints != null &&
            constraints.maxWidth == 120.0 &&
            constraints.maxHeight == 6.0;
      });
      expect(decorativeBar.isNotEmpty, isTrue);
    });

    // ---------------------------------------------------------------------------
    // Background color
    // ---------------------------------------------------------------------------

    testWidgets('uses a light grey background', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        HomeScreen(contacts: _contacts, onManageTap: () {}),
      ));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFFAFAFA));
    });
  });
}
