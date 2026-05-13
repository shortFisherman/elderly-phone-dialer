import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/services/photo_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PhotoService service;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      },
    );
    service = PhotoService.test();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
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

  test('deletePhoto does nothing for non-existent file', () async {
    await service.deletePhoto('/nonexistent/path/file.jpg');
  });
}
