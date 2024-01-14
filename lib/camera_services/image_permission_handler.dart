import 'package:permission_handler/permission_handler.dart';
import 'package:medication_tracker/camera_services/camera_helper.dart';

class ImagePermissionService {
  static Future<String?> takePhoto() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      String? imagePath = await CameraHelper.captureAndSaveImage();
      if (imagePath == null) {
        throw ImageSaveException('Error capturing image');
      }
      return imagePath;
    } else {
      throw PermissionDeniedException('Camera access denied');
    }
  }

  static Future<String?> pickFromGallery() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    if (status.isGranted) {
      String? imagePath = await CameraHelper.pickImageFromGallery();
      if (imagePath == null) {
        throw ImageSaveException('Error saving image');
      }
      return imagePath;
    } else {
      throw PermissionDeniedException('Gallery access denied');
    }
  }
}

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);
}

class ImageSaveException implements Exception {
  final String message;
  ImageSaveException(this.message);
}
