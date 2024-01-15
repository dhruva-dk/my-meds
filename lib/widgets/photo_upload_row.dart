import 'package:flutter/material.dart';

class PhotoUploadRow extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onUploadPhoto;
  final bool hasImage;

  PhotoUploadRow({
    Key? key,
    required this.onTakePhoto,
    required this.onUploadPhoto,
    this.hasImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _iconButton(
          iconData: Icons.camera_alt,
          label: hasImage ? 'Camera' : 'Camera',
          onPressed: onTakePhoto,
        ),
        const SizedBox(width: 8), // Spacing between buttons
        _iconButton(
          iconData: Icons.photo_library,
          label: 'Gallery',
          onPressed: onUploadPhoto,
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData iconData,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, color: Colors.black),
                Text(
                  label,
                  style: _buttonTextStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final TextStyle _buttonTextStyle =
      const TextStyle(fontSize: 14, fontFamily: "OpenSans");
}
