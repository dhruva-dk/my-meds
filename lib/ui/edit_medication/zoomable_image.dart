import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medication_tracker/ui/edit_medication/full_screen_image_view.dart'; // Make sure this path is correct

class ZoomableImage extends StatelessWidget {
  final String imagePath;

  const ZoomableImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _openFullScreenImage(context),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150,
          ),
        ),
      ],
    );
  }

  void _openFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imagePath: imagePath),
      ),
    );
  }
}
