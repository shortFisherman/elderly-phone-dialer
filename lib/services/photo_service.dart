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
