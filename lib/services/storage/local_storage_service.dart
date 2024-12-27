import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  Future<String> getAppDocPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    print('Application documents directory: ${appDocDir.path}');
    return appDocDir.path;
  }

  Future<String> saveFile(String sourcePath, String fileName) async {
    final appDocPath = await getAppDocPath();
    final destinationPath = path.join(appDocPath, fileName);
    print('Saving file from $sourcePath to $destinationPath');
    await File(sourcePath).copy(destinationPath);
    print('File saved: $destinationPath');
    return destinationPath;
  }
}
