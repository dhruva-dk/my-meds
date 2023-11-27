import 'package:flutter/material.dart';

// Custom Black Button Widget
class BlackButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BlackButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.black, // Button color
        onPrimary: Colors.white, // Text color
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20), // Adjust radius to match your design
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16), // Adjust padding to match your design
      ),
      child: Text(text),
    );
  }
}

// Custom White Button Widget
class WhiteButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const WhiteButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.white, // Button color
        onPrimary: Colors.black, // Text color
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20), // Adjust radius to match your design
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16), // Adjust padding to match your design
      ),
      child: Text(text),
    );
  }
}
