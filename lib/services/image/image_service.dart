import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService({ImagePicker? picker}) {
    _instance._picker = picker ?? ImagePicker();
    return _instance;
  }
  ImageService._internal();

  late final ImagePicker _picker;

  Future<String> takePhoto() async {
    await _checkPermission(Permission.camera);
    return await _captureImage(ImageSource.camera);
  }

  Future<String> pickFromGallery() async {
    await _checkPermission(Permission.photos);
    return await _captureImage(ImageSource.gallery);
  }

  Future<String> getImagePath(String imagePath) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return path.join(appDocDir.path, path.basename(imagePath));
  }

  Future<void> _checkPermission(Permission permission) async {
    final status = await permission.status;
    if (!status.isGranted) {
      final result = await permission.request();
      if (!result.isGranted) {
        throw Exception('Access denied for ${permission.toString()}');
      }
    }
  }

  Future<String> _captureImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) {
      throw Exception('No image selected');
    }
    return _saveImagePermanently(image);
  }

  Future<String> _saveImagePermanently(XFile image) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final localPath = path.join(appDocDir.path, fileName);

    await File(image.path).copy(localPath);
    return fileName;
  }
}
