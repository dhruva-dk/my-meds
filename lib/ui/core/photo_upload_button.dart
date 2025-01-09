import 'package:flutter/material.dart';
import 'package:medication_tracker/ui/core/outline_button.dart';

class PhotoUploadButton extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onUploadPhoto;
  final bool hasImage;

  const PhotoUploadButton({
    Key? key,
    required this.onTakePhoto,
    required this.onUploadPhoto,
    this.hasImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      title: hasImage ? 'Change Photo' : 'Upload Photo',
      icon: const Icon(Icons.camera_alt, size: 20),
      onTap: () => _showPhotoSourceDialog(context),
    );
  }

  void _showPhotoSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('Upload Photo'),
          content: const Text('Choose a photo source'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                onTakePhoto(); // Trigger camera action
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                onUploadPhoto(); // Trigger gallery action
              },
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );
  }
}
