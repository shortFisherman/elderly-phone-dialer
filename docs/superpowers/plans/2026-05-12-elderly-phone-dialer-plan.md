# Elderly Phone Dialer — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter Android app where elderly users long-press contact photo avatars to make phone calls, with auto speakerphone.

**Architecture:** Flutter/Dart app with Platform Channel for native Android phone API. JSON file storage for contacts. Two-mode UI: elderly mode (photo grid, no text) and management mode (contact CRUD).

**Tech Stack:** Flutter 3.x, Dart, Kotlin (Android native), image_picker, url_launcher, path_provider, uuid, permission_handler

---

## Task 1: Project Scaffolding

**Files:**
- Create: `pubspec.yaml`, `lib/main.dart`, `lib/app.dart`
- Create: `android/app/src/main/AndroidManifest.xml` (modify)
- Create: `android/app/src/main/kotlin/.../MainActivity.kt` (modify)

- [ ] **Step 1: Create Flutter project**

Run: `flutter create --org com.elderly --project-name phone_call2 --platforms android .`
Expected: Flutter project created in current directory

- [ ] **Step 2: Add dependencies to pubspec.yaml**

Edit `pubspec.yaml`, add under dependencies:
```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.0.0
  url_launcher: ^6.2.0
  path_provider: ^2.1.0
  uuid: ^4.2.0
  permission_handler: ^11.0.0
```

- [ ] **Step 3: Install dependencies**

Run: `flutter pub get`
Expected: All packages resolved

- [ ] **Step 4: Create directory structure**

Run: `mkdir -p lib/models lib/services lib/screens lib/widgets test/models test/services test/screens test/widgets`

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "chore: scaffold Flutter project with dependencies"
```

---

## Task 2: Contact Data Model

**Files:**
- Create: `lib/models/contact.dart`
- Create: `test/models/contact_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/models/contact_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/models/contact.dart';

void main() {
  group('Contact', () {
    test('toJson and fromJson round-trip', () {
      final contact = Contact(
        id: 'id-1',
        name: 'Son',
        phoneNumber: '13900002222',
        photoPath: '/photos/son.jpg',
        colorIndex: 0,
      );
      final json = contact.toJson();
      final restored = Contact.fromJson(json);
      expect(restored.id, contact.id);
      expect(restored.name, contact.name);
      expect(restored.phoneNumber, contact.phoneNumber);
      expect(restored.photoPath, contact.photoPath);
      expect(restored.colorIndex, contact.colorIndex);
    });

    test('copyWith returns new instance with updated fields', () {
      final contact = Contact(
        id: 'id-3',
        name: 'Dad',
        phoneNumber: '13600004444',
        photoPath: '/photos/dad.jpg',
        colorIndex: 1,
      );
      final updated = contact.copyWith(name: 'NewDad');
      expect(updated.id, contact.id);
      expect(updated.name, 'NewDad');
      expect(updated.phoneNumber, contact.phoneNumber);
      expect(updated.photoPath, contact.photoPath);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/models/contact_test.dart`
Expected: FAIL — Contact class not defined

- [ ] **Step 3: Write Contact model**

Create `lib/models/contact.dart`:
```dart
class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final String photoPath;
  final int colorIndex;

  const Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.photoPath,
    required this.colorIndex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'photoPath': photoPath,
        'colorIndex': colorIndex,
      };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id'] as String,
        name: json['name'] as String,
        phoneNumber: json['phoneNumber'] as String,
        photoPath: json['photoPath'] as String,
        colorIndex: json['colorIndex'] as int,
      );

  Contact copyWith({
    String? name,
    String? phoneNumber,
    String? photoPath,
    int? colorIndex,
  }) =>
      Contact(
        id: id,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        photoPath: photoPath ?? this.photoPath,
        colorIndex: colorIndex ?? this.colorIndex,
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/models/contact_test.dart`
Expected: All 2 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/models/contact.dart test/models/contact_test.dart
git commit -m "feat: add Contact data model with JSON serialization"
```

---
## Task 3: Contact Service (CRUD + JSON Persistence)

**Files:**
- Create: `lib/services/contact_service.dart`
- Create: `test/services/contact_service_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/services/contact_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/contact_service.dart';

void main() {
  late ContactService service;

  setUp(() {
    service = ContactService.test();
  });

  test('getAll returns empty list initially', () {
    expect(service.getAll(), isEmpty);
  });

  test('add inserts contact and assigns color', () {
    final contact = Contact(id: '', name: 'Test', phoneNumber: '123', photoPath: '/p.jpg', colorIndex: 0);
    final added = service.add(contact);
    expect(added.id, isNotEmpty);
    expect(added.colorIndex, 0);
    expect(service.getAll().length, 1);
  });

  test('add increments colorIndex for subsequent contacts', () {
    service.add(Contact(id: '', name: 'A', phoneNumber: '1', photoPath: '/a.jpg', colorIndex: 0));
    final second = service.add(Contact(id: '', name: 'B', phoneNumber: '2', photoPath: '/b.jpg', colorIndex: 0));
    expect(second.colorIndex, 1);
  });

  test('update modifies existing contact', () {
    final added = service.add(Contact(id: '', name: 'Old', phoneNumber: '1', photoPath: '/a.jpg', colorIndex: 0));
    final updated = service.update(added.copyWith(name: 'New'));
    expect(updated.name, 'New');
    expect(service.getAll().first.name, 'New');
  });

  test('delete removes contact', () {
    final added = service.add(Contact(id: '', name: 'X', phoneNumber: '1', photoPath: '/a.jpg', colorIndex: 0));
    service.delete(added.id);
    expect(service.getAll(), isEmpty);
  });

  test('max 30 contacts enforced', () {
    for (int i = 0; i < 30; i++) {
      service.add(Contact(id: '', name: 'C$i', phoneNumber: '$i', photoPath: '/p.jpg', colorIndex: 0));
    }
    expect(() => service.add(Contact(id: '', name: 'Extra', phoneNumber: '99', photoPath: '/p.jpg', colorIndex: 0)),
        throwsA(isA<StateError>()));
  });
}
```

- [ ] **Step 2: Run test (fails)**

Run: `flutter test test/services/contact_service_test.dart`
Expected: FAIL

- [ ] **Step 3: Write ContactService**

Create `lib/services/contact_service.dart`:
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:phone_call2/models/contact.dart';

class ContactService extends ChangeNotifier {
  final List<Contact> _contacts = [];
  final Uuid _uuid = const Uuid();
  int _nextColorIndex = 0;
  static const int _colorCount = 10;
  static const int maxContacts = 30;

  ContactService() {
    _load();
  }

  ContactService.test() {
    // In-memory only, skip file load
  }

  List<Contact> getAll() => List.unmodifiable(_contacts);

  Contact add(Contact contact) {
    if (_contacts.length >= maxContacts) {
      throw StateError('Maximum of $maxContacts contacts reached');
    }
    final newContact = Contact(
      id: _uuid.v4(),
      name: contact.name,
      phoneNumber: contact.phoneNumber,
      photoPath: contact.photoPath,
      colorIndex: _nextColorIndex % _colorCount,
    );
    _nextColorIndex++;
    _contacts.add(newContact);
    notifyListeners();
    _save();
    return newContact;
  }

  Contact update(Contact contact) {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index == -1) throw StateError('Contact not found');
    _contacts[index] = contact;
    notifyListeners();
    _save();
    return contact;
  }

  void delete(String id) {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/contacts.json');
    final json = _contacts.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }

  Future<void> _load() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/contacts.json');
    if (await file.exists()) {
      final json = jsonDecode(await file.readAsString()) as List<dynamic>;
      _contacts.clear();
      _contacts.addAll(json.map((j) => Contact.fromJson(j as Map<String, dynamic>)));
      if (_contacts.isNotEmpty) {
        _nextColorIndex = _contacts.last.colorIndex + 1;
      }
    }
  }
}
```

- [ ] **Step 4: Run test (passes)**

Run: `flutter test test/services/contact_service_test.dart`
Expected: All 6 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/contact_service.dart test/services/contact_service_test.dart
git commit -m "feat: add ContactService with JSON persistence"
```

---
## Task 4: Phone Service (Platform Channel for Dial + Speakerphone)

**Files:**
- Create: `lib/services/phone_service.dart`
- Create: `test/services/phone_service_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/services/phone_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/services/phone_service.dart';

void main() {
  late PhoneService service;

  setUp(() {
    service = PhoneService.test();
  });

  test('call returns true for valid phone number', () async {
    final result = await service.call('13800001111');
    expect(result, true);
  });

  test('call throws ArgumentError for empty phone number', () async {
    expect(() => service.call(''), throwsA(isA<ArgumentError>()));
  });

  test('call strips non-digit characters', () async {
    final result = await service.call('138-0000-1111');
    expect(result, true);
  });
}
```

- [ ] **Step 2: Run test (fails)**

Run: `flutter test test/services/phone_service_test.dart`
Expected: FAIL — PhoneService not defined

- [ ] **Step 3: Write PhoneService**

Create `lib/services/phone_service.dart`:
```dart
import 'package:flutter/services.dart';

class PhoneService {
  static const _channel = MethodChannel('com.elderly.phone_call2/phone');

  const PhoneService();

  factory PhoneService.test() => const PhoneService();

  Future<bool> call(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }
    try {
      final result = await _channel.invokeMethod<bool>('call', {
        'phoneNumber': cleaned,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
```

- [ ] **Step 4: Run test (passes)**

Run: `flutter test test/services/phone_service_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/phone_service.dart test/services/phone_service_test.dart
git commit -m "feat: add PhoneService with platform channel"
```

---
## Task 5: Photo Service (Gallery Pick + Local Copy)

**Files:**
- Create: `lib/services/photo_service.dart`
- Create: `test/services/photo_service_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/services/photo_service_test.dart`:
```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_call2/services/photo_service.dart';

void main() {
  late PhotoService service;

  setUp(() {
    service = PhotoService.test();
  });

  test('pickAndSave returns path for test mode', () async {
    final path = await service.pickAndSave();
    expect(path, isNotEmpty);
    expect(path, contains('photos'));
    expect(path, endsWith('.jpg'));
  });

  test('deletePhoto removes file', () async {
    final dir = await getApplicationDocumentsDirectory();
    final testFile = File('${dir.path}/photos/test-delete.jpg');
    await testFile.create(recursive: true);
    await testFile.writeAsString('test');
    expect(await testFile.exists(), true);

    await service.deletePhoto('${dir.path}/photos/test-delete.jpg');
    expect(await testFile.exists(), false);
  });
}
```

- [ ] **Step 2: Run test (fails)**

Run: `flutter test test/services/photo_service_test.dart`
Expected: FAIL

- [ ] **Step 3: Write PhotoService**

Create `lib/services/photo_service.dart`:
```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PhotoService {
  final ImagePicker _picker;
  final Uuid _uuid;

  const PhotoService({
    required ImagePicker picker,
    required Uuid uuid,
  })  : _picker = picker,
       _uuid = uuid;

  factory PhotoService() => PhotoService(
        picker: ImagePicker(),
        uuid: const Uuid(),
      );

  factory PhotoService.test() => PhotoService(
        picker: ImagePicker(),
        uuid: const Uuid(),
      );

  Future<String> pickAndSave() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (xFile == null) return '';

    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${dir.path}/photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final newPath = '${photosDir.path}/${_uuid.v4()}.jpg';
    await File(xFile.path).copy(newPath);
    return newPath;
  }

  Future<void> deletePhoto(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
```

- [ ] **Step 4: Run test (passes)**

Run: `flutter test test/services/photo_service_test.dart`
Expected: All 2 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/photo_service.dart test/services/photo_service_test.dart
git commit -m "feat: add PhotoService with gallery picker"
```

---
## Task 6: Color Palette Constants

**Files:**
- Create: `lib/services/colors.dart`
- Create: `test/services/colors_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/services/colors_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/services/colors.dart';

void main() {
  test('contactColors has 10 entries', () {
    expect(contactColors.length, 10);
  });

  test('getContactColor wraps around', () {
    expect(getContactColor(0), contactColors[0]);
    expect(getContactColor(10), contactColors[0]);
    expect(getContactColor(15), contactColors[5]);
  });
}
```

- [ ] **Step 2: Run test (fails)**

Run: `flutter test test/services/colors_test.dart`
Expected: FAIL

- [ ] **Step 3: Write color constants**

Create `lib/services/colors.dart`:
```dart
import 'package:flutter/material.dart';

const contactColors = [
  Color(0xFFFF6B6B),
  Color(0xFF4ECDC4),
  Color(0xFF45B7D1),
  Color(0xFF96CEB4),
  Color(0xFFDDA0DD),
  Color(0xFFFFEAA7),
  Color(0xFF74B9FF),
  Color(0xFFF8B500),
  Color(0xFFA29BFE),
  Color(0xFFFF8A80),
];

Color getContactColor(int index) => contactColors[index % contactColors.length];
```

- [ ] **Step 4: Run test (passes)**

Run: `flutter test test/services/colors_test.dart`
Expected: 2 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/colors.dart test/services/colors_test.dart
git commit -m "feat: add contact color palette constants"
```

---
## Task 7: Contact Avatar Widget

**Files:**
- Create: `lib/widgets/contact_avatar.dart`
- Create: `test/widgets/contact_avatar_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/widgets/contact_avatar_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/colors.dart';
import 'package:phone_call2/widgets/contact_avatar.dart';

void main() {
  final testContact = Contact(
    id: '1', name: 'Test', phoneNumber: '123',
    photoPath: '', colorIndex: 0,
  );

  testWidgets('renders circle with background color', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ContactAvatar(contact: testContact, size: 88)),
    ));
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('shows photo placeholder when no photo', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ContactAvatar(contact: testContact, size: 88)),
    ));
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundColor, contactColors[0]);
  });

  testWidgets('triggers onLongPress callback', (tester) async {
    bool called = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ContactAvatar(
          contact: testContact,
          size: 88,
          onLongPress: () => called = true,
        ),
      ),
    ));
    await tester.longPress(find.byType(CircleAvatar));
    expect(called, true);
  });

  testWidgets('scales up during long press', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ContactAvatar(contact: testContact, size: 88)),
    ));
    final gesture = await tester.startGesture(find.byType(CircleAvatar));
    await tester.pump(const Duration(milliseconds: 500));
    // Avatar should scale up
    final scaled = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scaled.scale, greaterThan(1.0));
    await gesture.up();
  });
}
```

- [ ] **Step 2: Run test (fails)**

Run: `flutter test test/widgets/contact_avatar_test.dart`
Expected: FAIL

- [ ] **Step 3: Write ContactAvatar widget**

Create `lib/widgets/contact_avatar.dart`:
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/colors.dart';

class ContactAvatar extends StatefulWidget {
  final Contact contact;
  final double size;
  final VoidCallback? onLongPress;

  const ContactAvatar({
    super.key,
    required this.contact,
    required this.size,
    this.onLongPress,
  });

  @override
  State<ContactAvatar> createState() => _ContactAvatarState();
}

class _ContactAvatarState extends State<ContactAvatar> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() => _pressing = true);
      },
      onLongPressEnd: (_) {
        setState(() => _pressing = false);
      },
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressing ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 400),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _pressing
                ? [BoxShadow(color: Colors.black26, blurRadius: 12, spreadRadius: 2)]
                : [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: getContactColor(widget.contact.colorIndex),
            backgroundImage: widget.contact.photoPath.isNotEmpty &&
                    File(widget.contact.photoPath).existsSync()
                ? FileImage(File(widget.contact.photoPath))
                : null,
            child: widget.contact.photoPath.isEmpty ||
                    !File(widget.contact.photoPath).existsSync()
                ? Icon(Icons.person, size: widget.size * 0.5, color: Colors.white70)
                : null,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test (passes)**

Run: `flutter test test/widgets/contact_avatar_test.dart`
Expected: All 4 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/contact_avatar.dart test/widgets/contact_avatar_test.dart
git commit -m "feat: add ContactAvatar widget with long-press animation"
```

---
## Task 8: Home Screen (Elderly Mode — Photo Grid)

**Files:**
- Create: `lib/screens/home_screen.dart`
- Create: `test/screens/home_screen_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/screens/home_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/screens/home_screen.dart';

void main() {
  final contacts = List.generate(9, (i) => Contact(
    id: '$i', name: 'C$i', phoneNumber: '1380000000$i',
    photoPath: '', colorIndex: i,
  ));

  testWidgets('renders grid with all contacts', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(contacts: contacts, onManageTap: () {}),
    ));
    expect(find.byType(CircleAvatar), findsNWidgets(9));
  });

  testWidgets('shows empty state when no contacts', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(contacts: [], onManageTap: () {}),
    ));
    expect(find.textContaining('添加'), findsOneWidget);
  });

  testWidgets('plus button triggers onManageTap after 5 taps', (tester) async {
    bool called = false;
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(contacts: contacts, onManageTap: () => called = true),
    ));
    final plusFinder = find.byKey(const Key('manage_plus'));
    for (int i = 0; i < 5; i++) {
      await tester.tap(plusFinder);
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(called, true);
  });
}
```

- [ ] **Step 2: Run test (fails)**

Run: `flutter test test/screens/home_screen_test.dart`
Expected: FAIL

- [ ] **Step 3: Write HomeScreen**

Create `lib/screens/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/phone_service.dart';
import 'package:phone_call2/widgets/contact_avatar.dart';

class HomeScreen extends StatefulWidget {
  final List<Contact> contacts;
  final VoidCallback onManageTap;

  const HomeScreen({
    super.key,
    required this.contacts,
    required this.onManageTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _phoneService = PhoneService();
  int _plusTapCount = 0;

  Future<void> _onLongPress(Contact contact) async {
    await _phoneService.call(contact.phoneNumber);
  }

  void _onPlusTap() {
    _plusTapCount++;
    if (_plusTapCount >= 5) {
      _plusTapCount = 0;
      widget.onManageTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.contacts.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.contacts, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('点击右下角 + 添加联系人',
                  style: TextStyle(fontSize: 18, color: Colors.grey[500])),
            ],
          ),
        ),
        floatingActionButton: _buildPlusButton(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 120, height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: widget.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = widget.contacts[index];
                    return ContactAvatar(
                      contact: contact,
                      size: 88,
                      onLongPress: () => _onLongPress(contact),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildPlusButton(),
    );
  }

  Widget _buildPlusButton() {
    return GestureDetector(
      onTap: _onPlusTap,
      child: Container(
        key: const Key('manage_plus'),
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x14000000),
          border: Border.all(color: const Color(0xFFCCCCCC), style: BorderStyle.solid),
        ),
        child: const Icon(Icons.add, size: 18, color: Color(0xFF999999)),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test (passes)**

Run: `flutter test test/screens/home_screen_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/home_screen.dart test/screens/home_screen_test.dart
git commit -m "feat: add HomeScreen with 3-column photo grid"
```

---
## Task 9: Manage Screen (Contact List + Add/Edit)

**Files:**
- Create: `lib/screens/manage_screen.dart`
- Create: `test/screens/manage_screen_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/screens/manage_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/screens/manage_screen.dart';

void main() {
  final contacts = [
    Contact(id: '1', name: 'Daughter', phoneNumber: '13800001111', photoPath: '', colorIndex: 0),
    Contact(id: '2', name: 'Son', phoneNumber: '13900002222', photoPath: '', colorIndex: 1),
  ];

  testWidgets('displays contact list', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ManageScreen(contacts: contacts)));
    expect(find.text('Daughter'), findsOneWidget);
    expect(find.text('Son'), findsOneWidget);
  });

  testWidgets('delete button removes contact', (tester) async {
    List<Contact> updatedContacts = List.from(contacts);
    await tester.pumpWidget(MaterialApp(
      home: ManageScreen(
        contacts: updatedContacts,
        onDelete: (id) => updatedContacts.removeWhere((c) => c.id == id),
      ),
    ));
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    expect(find.text('Daughter'), findsNothing);
  });

  testWidgets('add button navigates to editor', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ManageScreen(contacts: List.from(contacts))));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('保存联系人'), findsOneWidget);
  });

  testWidgets('done button calls onClose', (tester) async {
    bool closed = false;
    await tester.pumpWidget(MaterialApp(
      home: ManageScreen(contacts: List.from(contacts), onClose: () => closed = true),
    ));
    await tester.tap(find.text('完成'));
    expect(closed, true);
  });
}
```

- [ ] **Step 2: Run test (fails)**

Run: `flutter test test/screens/manage_screen_test.dart`
Expected: FAIL

- [ ] **Step 3: Write ManageScreen**

Create `lib/screens/manage_screen.dart`:
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/colors.dart';
import 'package:phone_call2/services/photo_service.dart';

class ManageScreen extends StatefulWidget {
  final List<Contact> contacts;
  final void Function(Contact)? onSave;
  final void Function(String)? onDelete;
  final VoidCallback? onClose;

  const ManageScreen({
    super.key,
    required this.contacts,
    this.onSave,
    this.onDelete,
    this.onClose,
  });

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final _photoService = PhotoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('管理联系人', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: widget.onClose,
            child: const Text('完成', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.contacts.length,
        itemBuilder: (context, index) {
          final contact = widget.contacts[index];
          return _ContactListTile(
            contact: contact,
            onEdit: () => _openEditor(contact),
            onDelete: () => widget.onDelete?.call(contact.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openEditor(Contact? contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ContactEditor(
          contact: contact,
          photoService: _photoService,
          onSave: (c) => widget.onSave?.call(c),
        ),
      ),
    );
  }
}

class _ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactListTile({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: getContactColor(contact.colorIndex),
          backgroundImage: contact.photoPath.isNotEmpty && File(contact.photoPath).existsSync()
              ? FileImage(File(contact.photoPath))
              : null,
          child: (contact.photoPath.isEmpty || !File(contact.photoPath).existsSync())
              ? const Icon(Icons.person, color: Colors.white70)
              : null,
        ),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(contact.phoneNumber, style: const TextStyle(color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _ContactEditor extends StatefulWidget {
  final Contact? contact;
  final PhotoService photoService;
  final void Function(Contact) onSave;

  const _ContactEditor({
    this.contact,
    required this.photoService,
    required this.onSave,
  });

  @override
  State<_ContactEditor> createState() => _ContactEditorState();
}

class _ContactEditorState extends State<_ContactEditor> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String _photoPath = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber ?? '');
    _photoPath = widget.contact?.photoPath ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final path = await widget.photoService.pickAndSave();
    if (path.isNotEmpty) {
      setState(() => _photoPath = path);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('存储空间不足，请清理后重试')),
        );
      }
    }
  }

  void _save() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;
    final updated = Contact(
      id: widget.contact?.id ?? '',
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      photoPath: _photoPath,
      colorIndex: widget.contact?.colorIndex ?? 0,
    );
    widget.onSave(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contact == null ? '添加联系人' : '编辑联系人')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _photoPath.isNotEmpty && File(_photoPath).existsSync()
                    ? FileImage(File(_photoPath))
                    : null,
                child: _photoPath.isEmpty || !File(_photoPath).existsSync()
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _pickPhoto, child: const Text('选择照片')),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '姓名', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: '电话号码', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('保存联系人', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test (passes)**

Run: `flutter test test/screens/manage_screen_test.dart`
Expected: All 4 tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/manage_screen.dart test/screens/manage_screen_test.dart
git commit -m "feat: add ManageScreen with add/edit/delete contacts"
```

---
## Task 10: App Entry Point + Android Configuration

**Files:**
- Create: `lib/main.dart`
- Create: `lib/app.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/src/main/kotlin/.../MainActivity.kt`

- [ ] **Step 1: Write main.dart**

Create `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ElderlyPhoneApp());
}
```

- [ ] **Step 2: Write app.dart**

Create `lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/contact_service.dart';
import 'package:phone_call2/screens/home_screen.dart';
import 'package:phone_call2/screens/manage_screen.dart';

class ElderlyPhoneApp extends StatelessWidget {
  const ElderlyPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '亲情电话',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final ContactService _contactService = ContactService();
  bool _inManageMode = false;

  @override
  void initState() {
    super.initState();
    _contactService.addListener(_onContactsChanged);
  }

  @override
  void dispose() {
    _contactService.removeListener(_onContactsChanged);
    super.dispose();
  }

  void _onContactsChanged() {
    if (mounted) setState(() {});
  }

  void _enterManageMode() {
    setState(() => _inManageMode = true);
  }

  void _exitManageMode() {
    setState(() => _inManageMode = false);
    if (_contactService.getAll().isEmpty) {
      // Stay in manage mode until at least one contact exists
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_inManageMode) {
      return ManageScreen(
        contacts: List.from(_contactService.getAll()),
        onSave: (contact) {
          if (contact.id.isEmpty) {
            _contactService.add(contact);
          } else {
            _contactService.update(contact);
          }
        },
        onDelete: (id) => _contactService.delete(id),
        onClose: _exitManageMode,
      );
    }

    final contacts = _contactService.getAll();

    // First launch with no contacts: auto-enter manage mode
    if (contacts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _enterManageMode());
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return HomeScreen(
      contacts: contacts,
      onManageTap: _enterManageMode,
    );
  }
}
```

- [ ] **Step 3: Configure Android permissions**

Modify `android/app/src/main/AndroidManifest.xml`, add inside `<manifest>` before `<application>`:
```xml
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

- [ ] **Step 4: Configure MainActivity for Platform Channel**

Modify `android/app/src/main/kotlin/com/elderly/phone_call2/MainActivity.kt`:
```kotlin
package com.elderly.phone_call2

import android.content.Intent
import android.net.Uri
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.elderly.phone_call2/phone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "call") {
                    val phoneNumber = call.argument<String>("phoneNumber") ?: ""
                    if (phoneNumber.isEmpty()) {
                        result.error("INVALID_NUMBER", "Phone number is empty", null)
                        return@setMethodCallHandler
                    }

                    try {
                        // Enable speakerphone
                        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                        audioManager.mode = AudioManager.MODE_IN_CALL
                        audioManager.isSpeakerphoneOn = true

                        // Place the call
                        val intent = Intent(Intent.ACTION_CALL)
                        intent.data = Uri.parse("tel:$phoneNumber")
                        startActivity(intent)

                        result.success(true)
                    } catch (e: SecurityException) {
                        result.error("PERMISSION_DENIED", "CALL_PHONE permission not granted", null)
                    } catch (e: Exception) {
                        result.error("CALL_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
```

- [ ] **Step 5: Run app to verify build**

Run: `flutter build apk --debug`
Expected: Build succeeds without errors

- [ ] **Step 6: Commit**

```bash
git add lib/main.dart lib/app.dart android/app/src/main/AndroidManifest.xml android/app/src/main/kotlin/
git commit -m "feat: wire up app entry, platform channel, and Android config"
```

---
