import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<String> getAppDocPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }

  Future<String> saveFile(String sourcePath, String fileName) async {
    final appDocPath = await getAppDocPath();
    final destinationPath = path.join(appDocPath, fileName);
    await File(sourcePath).copy(destinationPath);
    return fileName;
  }
}
