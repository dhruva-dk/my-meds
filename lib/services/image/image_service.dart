import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:medication_tracker/services/permission/check_permission_service.dart';
import 'package:medication_tracker/services/storage/local_storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker;
  final CheckPermissionService _permissionService;
  final LocalStorageService _storage;

  ImageService({
    required ImagePicker picker,
    required CheckPermissionService permissionService,
    required LocalStorageService storage,
  })  : _picker = picker,
        _permissionService = permissionService,
        _storage = storage;

  Future<String> takePhoto() async {
    await _permissionService.checkPermission(Permission.camera);
    return _captureImage(ImageSource.camera);
  }

  Future<String> pickFromGallery() async {
    await _permissionService.checkPermission(Permission.photos);
    return _captureImage(ImageSource.gallery);
  }

  Future<String> _captureImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) {
      throw Exception('No image selected');
    }

    final file = File(image.path);
    if (await file.exists()) {
      await _storage.saveFile(image.path, path.basename(image.path));
      return path.basename(image
          .path); //return only the image's file name. The UI layer joins this image file name with the documents directory. The base file name wouldn't change regardless of its path.
    } else {
      throw Exception('File does not exist: ${image.path}');
    }
  }
}
