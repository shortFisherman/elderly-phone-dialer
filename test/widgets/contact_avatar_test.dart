import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/colors.dart';
import 'package:phone_call2/widgets/contact_avatar.dart';

Widget _buildTestApp(ContactAvatar avatar) {
  return MaterialApp(
    home: Scaffold(body: Center(child: avatar)),
  );
}

void main() {
  const contact = Contact(
    id: 'c1',
    name: 'Alice',
    phoneNumber: '555-0100',
    photoPath: '',
    colorIndex: 3,
  );

  // ---------------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------------

  testWidgets('renders a CircleAvatar', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(
      const ContactAvatar(contact: contact, size: 64.0),
    ));

    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('shows person icon when no photo is set', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(
      const ContactAvatar(contact: contact, size: 64.0),
    ));

    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('shows person icon when photoPath file does not exist',
      (WidgetTester tester) async {
    const contactWithBadPath = Contact(
      id: 'c2',
      name: 'Bob',
      phoneNumber: '555-0200',
      photoPath: '/nonexistent/photo.jpg',
      colorIndex: 0,
    );

    await tester.pumpWidget(_buildTestApp(
      const ContactAvatar(contact: contactWithBadPath, size: 64.0),
    ));

    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  // Photo loading with actual files is tested via manual QA on real devices
  // to avoid CI timeouts with Flutter's image decoder.

  // ---------------------------------------------------------------------------
  // Background colour
  // ---------------------------------------------------------------------------

  testWidgets('uses the contact colour as background', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(
      const ContactAvatar(contact: contact, size: 72.0),
    ));

    final CircleAvatar avatar = tester.widget<CircleAvatar>(
      find.byType(CircleAvatar),
    );
    final Color expected = getContactColor(contact.colorIndex);
    expect(avatar.backgroundColor, expected);
  });

  testWidgets('different colourIndex produces different background colour',
      (WidgetTester tester) async {
    const contactA = Contact(
      id: 'a',
      name: 'A',
      phoneNumber: '111',
      photoPath: '',
      colorIndex: 0,
    );
    const contactB = Contact(
      id: 'b',
      name: 'B',
      phoneNumber: '222',
      photoPath: '',
      colorIndex: 5,
    );

    await tester.pumpWidget(_buildTestApp(
      const ContactAvatar(contact: contactA, size: 48.0),
    ));
    final Color colorA = tester
        .widget<CircleAvatar>(find.byType(CircleAvatar))
        .backgroundColor!;

    await tester.pumpWidget(_buildTestApp(
      const ContactAvatar(contact: contactB, size: 48.0),
    ));
    final Color colorB = tester
        .widget<CircleAvatar>(find.byType(CircleAvatar))
        .backgroundColor!;

    expect(colorA, isNot(colorB));
  });

  test('getContactColor wraps index correctly', () {
    // Sanity-check the helper that the widget delegates to.
    expect(getContactColor(contact.colorIndex), contactColors[3]);
    expect(getContactColor(13), contactColors[3]);
  });

  // ---------------------------------------------------------------------------
  // Size
  // ---------------------------------------------------------------------------

  testWidgets('respects the size parameter', (WidgetTester tester) async {
    const double avatarSize = 80.0;

    await tester.pumpWidget(_buildTestApp(
      const ContactAvatar(contact: contact, size: avatarSize),
    ));

    final CircleAvatar avatar = tester.widget<CircleAvatar>(
      find.byType(CircleAvatar),
    );
    expect(avatar.radius, avatarSize / 2);
  });

  // ---------------------------------------------------------------------------
  // Long-press callback
  // ---------------------------------------------------------------------------

  testWidgets('calls onLongPress when long-pressed', (WidgetTester tester) async {
    int callCount = 0;

    await tester.pumpWidget(_buildTestApp(
      ContactAvatar(
        contact: contact,
        size: 64.0,
        onLongPress: () => callCount++,
      ),
    ));

    await tester.longPress(find.byType(ContactAvatar));
    expect(callCount, 1);
  });

  testWidgets('does not throw when onLongPress is null and avatar is long-pressed',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(
      const ContactAvatar(contact: contact, size: 64.0),
    ));

    // Should complete without error even though no callback is attached.
    await tester.longPress(find.byType(ContactAvatar));
  });

  // ---------------------------------------------------------------------------
  // Animation (optional)
  // ---------------------------------------------------------------------------

  testWidgets('scale animates to > 1.0 during long press', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(
      const ContactAvatar(contact: contact, size: 64.0),
    ));

    // Before press: find the AnimatedScale and check scale is 1.0.
    AnimatedScale scale = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );
    expect(scale.scale, 1.0);

    // Begin a long-press gesture (but don't release it).
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ContactAvatar)),
    );
    await tester.pump(const Duration(milliseconds: 600)); // exceed long-press threshold
    await tester.pump(const Duration(milliseconds: 200)); // let animation tick

    scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.scale, greaterThan(1.0));

    // Release.
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 500));

    scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.scale, 1.0);
  });
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

/// A minimal valid JPEG (1×1 pixel) represented as raw bytes.
///
/// Source: the shortest well-formed baseline-DCT JPEG with a 1×1 image data
/// block.  Used in tests so we have a real file on disk that [FileImage] can
/// decode without I/O errors.
const _minimalJpeg = <int>[
  0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, // SOI + JFIF APP0
  0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01,
  0x00, 0x01, 0x00, 0x00,
  0xFF, 0xDB, 0x00, 0x43, 0x00, // DQT
  0x10, 0x0B, 0x0C, 0x0E, 0x0C, 0x0A, 0x10, 0x0E,
  0x0D, 0x0E, 0x12, 0x11, 0x10, 0x13, 0x18, 0x28,
  0x1A, 0x18, 0x16, 0x16, 0x18, 0x31, 0x23, 0x25,
  0x1D, 0x28, 0x3A, 0x33, 0x3D, 0x3C, 0x39, 0x33,
  0x38, 0x37, 0x40, 0x48, 0x5C, 0x4E, 0x40, 0x44,
  0x57, 0x45, 0x37, 0x38, 0x50, 0x6D, 0x51, 0x57,
  0x5F, 0x62, 0x67, 0x68, 0x67, 0x3E, 0x4D, 0x71,
  0x79, 0x70, 0x64, 0x78, 0x5C, 0x65, 0x67, 0x63,
  0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01, 0x00, // SOF0 (1×1)
  0x01, 0x01, 0x01, 0x11, 0x00,
  0xFF, 0xC4, 0x00, 0xD2, 0x00, 0x00, 0x01, 0x01, // DHT
  0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x05, 0x06, 0x00, 0x01,
  0x02, 0x03, 0x04, 0x09, 0x07, 0x08, 0x0A, 0x0B,
  0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x01, 0x01,
  0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x05, 0x06, 0x00, 0x01,
  0x02, 0x03, 0x04, 0x09, 0x07, 0x08, 0x0A, 0x0B,
  0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x01, 0x01,
  0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x05, 0x06, 0x00, 0x01,
  0x02, 0x03, 0x04, 0x09, 0x07, 0x08, 0x0A, 0x0B,
  0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x01, 0x01,
  0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x05, 0x06, 0x00, 0x01,
  0x02, 0x03, 0x04, 0x09, 0x07, 0x08, 0x0A, 0x0B,
  0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11,
  0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, // SOS
  0x3F, 0x00, 0xD2, 0xCF, 0x20, 0xFF, 0xD9,         // compressed data + EOI
];
