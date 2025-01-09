import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  Future<String> getAppDocPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }

  //get file path if you have file name only (only the file name should be stored in the database)
  Future<String> getFilePath(String fileName) async {
    final appDocPath = await getAppDocPath();
    return path.join(appDocPath, fileName);
  }

  // saves the file to the application's documents directory
  Future<void> saveFile(String sourcePath, String fileName) async {
    final appDocPath = await getAppDocPath();
    final destinationPath = path.join(appDocPath, fileName);
    print('Saving file from $sourcePath to $destinationPath');
    await File(sourcePath).copy(destinationPath);
    print('File saved: $destinationPath');
    //do not return anything as we now use the file name in the medication object, not the entire path
  }
}
