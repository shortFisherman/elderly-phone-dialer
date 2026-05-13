import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/services/photo_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PhotoService service;

  setUp(() {
    service = PhotoService.test();
  });

  test('deletePhoto removes file', () async {
    final dir = Directory.systemTemp.path;
    final testFile = File('$dir/photos/test-delete.jpg');
    await testFile.create(recursive: true);
    await testFile.writeAsString('test');
    expect(await testFile.exists(), true);

    await service.deletePhoto('$dir/photos/test-delete.jpg');
    expect(await testFile.exists(), false);
  });

  test('deletePhoto does nothing for non-existent file', () async {
    await service.deletePhoto('/nonexistent/path/file.jpg');
  });
}
