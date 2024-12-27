import 'package:image_picker/image_picker.dart';
import 'package:medication_tracker/services/permission/check_permission_service.dart';
import 'package:medication_tracker/services/storage/local_storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker;
  final CheckPermissionService _permissionService;
  final LocalStorageService _storage;

  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal({
    ImagePicker? picker,
    CheckPermissionService? permissionService,
    LocalStorageService? storage,
  })  : _picker = picker ?? ImagePicker(),
        _permissionService = permissionService ?? CheckPermissionService(),
        _storage = storage ?? LocalStorageService();

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
    if (image == null) throw Exception('No image selected');

    return _storage.saveFile(image.path, path.basename(image.path));
  }
}
