import 'package:flutter/material.dart';
import 'package:medication_tracker/ui/core/secondary_button.dart';

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
      icon: const Icon(
        Icons.camera_alt,
        size: 20,
      ),
      onTap: () => _showPhotoSourceDialog(context),
    );
  }

  void _showPhotoSourceDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text(
            'Upload Photo',
            style: theme.dialogTheme.titleTextStyle,
          ),
          content: Text(
            'Choose a photo source',
            style: theme.dialogTheme.contentTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                onTakePhoto(); // Trigger camera action
              },
              child: Text(
                'Camera',
                style: theme.dialogTheme.contentTextStyle,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                onUploadPhoto(); // Trigger gallery action
              },
              child: Text(
                'Gallery',
                style: theme.dialogTheme.contentTextStyle,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }
}
