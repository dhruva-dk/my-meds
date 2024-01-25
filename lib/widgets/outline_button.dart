import 'package:flutter/material.dart';

class WhiteOutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const WhiteOutlineButton({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black, // Text Color
        side: const BorderSide(color: Colors.black, width: 2.0), // Border Color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onTap,
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontFamily: "OpenSans"),
      ),
    );
  }
}
