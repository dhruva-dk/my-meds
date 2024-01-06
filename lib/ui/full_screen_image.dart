import 'dart:io';

import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //Add an AppBar for a better user experience
          backgroundColor: Colors.transparent,
          toolbarTextStyle: TextStyle(color: Colors.white),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white)),
      backgroundColor: Colors.black, // To highlight the image
      body: Center(
        child: InteractiveViewer(
          // Allows pinch-to-zoom
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
