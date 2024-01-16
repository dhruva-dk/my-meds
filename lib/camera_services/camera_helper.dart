// camera_helper.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraHelper {
  static Future<String?> captureAndSaveImage() async {
    //returns path of camera image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      return _saveImagePermanently(image);
    }
    return null;
  }

  static Future<String?> pickImageFromGallery() async {
    // returns path of gallery image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return _saveImagePermanently(image);
    }
    return null;
  }

  static Future<String> _saveImagePermanently(XFile image) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final String fileName = path.basename(image.path);
    final String localPath = path.join(appDocPath, fileName);

    print("Saving image to $localPath");

    await File(image.path).copy(
        localPath); //copy image to doc directory, but only return file name (must relationally join file to doc directory
    //as ios changes app name on each build)
    return fileName;
  }

  // a method which takes the an image path and returns the documents directory path to the image
  static Future<String> getImagePath(String imagePath) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final String fileName = path.basename(imagePath);
    final String localPath = path.join(appDocPath, fileName);
    return localPath;
  }
}
