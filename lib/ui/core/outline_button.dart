import 'package:flutter/material.dart';

class OutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Icon? icon; // Add icon parameter

  const OutlineButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Text Color
        side: const BorderSide(color: Colors.black, width: 1), // Border Color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
