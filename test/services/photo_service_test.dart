import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_call2/services/photo_service.dart';

void main() {
  late PhotoService service;

  setUp(() {
    service = PhotoService.test();
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
