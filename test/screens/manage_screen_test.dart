import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/screens/manage_screen.dart';

Widget _buildTestApp(ManageScreen manageScreen) {
  return MaterialApp(
    home: manageScreen,
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
  group('ManageScreen', () {
    // -------------------------------------------------------------------------
    // Contact list rendering
    // -------------------------------------------------------------------------

    testWidgets('displays contact list with names', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('displays phone numbers as subtitles',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      expect(find.text('555-0100'), findsOneWidget);
      expect(find.text('555-0200'), findsOneWidget);
      expect(find.text('555-0300'), findsOneWidget);
    });

    testWidgets('shows CircleAvatar for each contact',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      // Each contact card has a CircleAvatar, plus the list has no other.
      expect(find.byType(CircleAvatar), findsNWidgets(3));
    });

    testWidgets('shows person icon when no photo is set',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      expect(find.byIcon(Icons.person), findsNWidgets(3));
    });

    testWidgets('shows empty state when no contacts', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: const []),
      ));

      expect(find.text('暂无联系人'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Delete
    // -------------------------------------------------------------------------

    testWidgets('delete button removes contact from list',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      // Verify both contacts initially present.
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      // Tap the first delete button (the one for Alice).
      final deleteButtons = find.byIcon(Icons.delete);
      expect(deleteButtons, findsNWidgets(3));
      await tester.tap(deleteButtons.first);
      await tester.pump();

      // Alice should be gone; Bob and Carol should remain.
      expect(find.text('Alice'), findsNothing);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('delete button calls onDelete callback with contact id',
        (WidgetTester tester) async {
      String? deletedId;

      await tester.pumpWidget(_buildTestApp(
        ManageScreen(
          contacts: _contacts,
          onDelete: (id) => deletedId = id,
        ),
      ));

      final deleteButtons = find.byIcon(Icons.delete);
      await tester.tap(deleteButtons.first);
      await tester.pump();

      expect(deletedId, 'c1');
    });

    // -------------------------------------------------------------------------
    // FAB / add contact
    // -------------------------------------------------------------------------

    testWidgets('+ FAB navigates to editor and shows save button text',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      // The FAB shows a + icon.
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      // The editor should be on screen now.
      expect(find.text('保存联系人'), findsOneWidget);
      expect(find.text('添加联系人'), findsOneWidget);
      expect(find.text('选择照片'), findsOneWidget);
    });

    testWidgets('editor has name and phone text fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('电话号码'), findsOneWidget);
    });

    testWidgets('editor shows edit title when editing existing contact',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      // Tap the edit button on the first contact.
      final editButtons = find.byIcon(Icons.edit);
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('编辑联系人'), findsOneWidget);
      expect(find.text('添加联系人'), findsNothing);
    });

    testWidgets('editor saves new contact and pops back to list',
        (WidgetTester tester) async {
      Contact? saved;

      await tester.pumpWidget(_buildTestApp(
        ManageScreen(
          contacts: _contacts,
          onSave: (c) => saved = c,
        ),
      ));

      // Open editor for a new contact.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill in the form.
      await tester.enterText(find.byType(TextField).first, 'Dave');
      await tester.enterText(find.byType(TextField).last, '555-0400');

      // Tap save.
      await tester.tap(find.text('保存联系人'));
      await tester.pumpAndSettle();

      // Should be back on the list screen.
      expect(saved, isNotNull);
      expect(saved!.name, 'Dave');
      expect(saved!.phoneNumber, '555-0400');
      expect(find.text('Dave'), findsOneWidget);
      expect(find.text('保存联系人'), findsNothing);
    });

    testWidgets('save button does nothing when name is empty',
        (WidgetTester tester) async {
      bool saved = false;

      await tester.pumpWidget(_buildTestApp(
        ManageScreen(
          contacts: _contacts,
          onSave: (_) => saved = true,
        ),
      ));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Leave name empty, enter a phone number.
      await tester.enterText(find.byType(TextField).last, '555-0400');

      // Tap save — should be a no-op because name is empty.
      await tester.tap(find.text('保存联系人'));
      await tester.pumpAndSettle();

      // We should still be on the editor page.
      expect(saved, isFalse);
      expect(find.text('保存联系人'), findsOneWidget);
    });

    testWidgets('save button does nothing when phone is empty',
        (WidgetTester tester) async {
      bool saved = false;

      await tester.pumpWidget(_buildTestApp(
        ManageScreen(
          contacts: _contacts,
          onSave: (_) => saved = true,
        ),
      ));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter name but leave phone empty.
      await tester.enterText(find.byType(TextField).first, 'Dave');

      await tester.tap(find.text('保存联系人'));
      await tester.pumpAndSettle();

      expect(saved, isFalse);
      expect(find.text('保存联系人'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 完成 (close) button
    // -------------------------------------------------------------------------

    testWidgets('完成 button calls onClose', (WidgetTester tester) async {
      bool closed = false;

      await tester.pumpWidget(_buildTestApp(
        ManageScreen(
          contacts: _contacts,
          onClose: () => closed = true,
        ),
      ));

      await tester.tap(find.text('完成'));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('完成 button does not throw when onClose is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      // Tapping 完成 with no callback should not crash.
      await tester.tap(find.text('完成'));
      await tester.pump();

      expect(find.text('管理联系人'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // AppBar
    // -------------------------------------------------------------------------

    testWidgets('AppBar shows correct title', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      expect(find.text('管理联系人'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Edit button
    // -------------------------------------------------------------------------

    testWidgets('edit and delete icons appear on each contact card',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      expect(find.byIcon(Icons.edit), findsNWidgets(3));
      expect(find.byIcon(Icons.delete), findsNWidgets(3));
    });

    testWidgets('changing onDelete callback for second delete works',
        (WidgetTester tester) async {
      final deletedIds = <String>[];

      await tester.pumpWidget(_buildTestApp(
        ManageScreen(
          contacts: _contacts,
          onDelete: (id) => deletedIds.add(id),
        ),
      ));

      final deleteButtons = find.byIcon(Icons.delete);

      // Delete Bob (index 1).
      await tester.tap(deleteButtons.at(1));
      await tester.pump();

      expect(deletedIds, ['c2']);
      expect(find.text('Bob'), findsNothing);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });
  });

  // ===========================================================================
  // Widget-level tests for navigation / state
  // ===========================================================================

  group('ManageScreen navigation', () {
    testWidgets('FAB is present and uses + icon', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.child, isA<Icon>());
      expect((fab.child as Icon).icon, Icons.add);
    });

    testWidgets('going back from editor returns to the manage screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(
        ManageScreen(contacts: _contacts),
      ));

      // Open editor.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('保存联系人'), findsOneWidget);

      // Simulate back navigation.
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      // Verify we're back on the manage screen.
      expect(find.text('管理联系人'), findsOneWidget);
      expect(find.text('保存联系人'), findsNothing);
    });
  });
}
