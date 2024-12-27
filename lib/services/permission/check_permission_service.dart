import 'package:permission_handler/permission_handler.dart';

class CheckPermissionService {
  Future<void> checkPermission(Permission permission) async {
    final status = await permission.status;
    if (!status.isGranted) {
      final result = await permission.request();
      if (!result.isGranted) {
        throw Exception('Access denied for ${permission.toString()}');
      }
    }
  }
}
