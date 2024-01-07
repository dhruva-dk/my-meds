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
        Expanded(
          child: ElevatedButton(
            onPressed: onTakePhoto,
            child: Text(hasImage ? 'Retake Photo' : 'Take Photo',
                style: _buttonTextStyle),
            style: _buttonStyle,
          ),
        ),
        const SizedBox(width: 8), // Spacing between buttons
        Expanded(
          child: ElevatedButton(
            onPressed: onUploadPhoto,
            child: Text('Upload from Gallery', style: _buttonTextStyle),
            style: _buttonStyle,
          ),
        ),
      ],
    );
  }

  final ButtonStyle _buttonStyle = ElevatedButton.styleFrom(
    side: const BorderSide(color: Colors.black),
    backgroundColor: Colors.grey[100],
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16),
  );

  final TextStyle _buttonTextStyle =
      const TextStyle(fontSize: 14, fontFamily: "OpenSans");
}
