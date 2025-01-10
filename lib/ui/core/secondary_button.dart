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
    final theme = Theme.of(context);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor:
            theme.colorScheme.secondaryContainer, // Background color
        foregroundColor: theme.colorScheme.onSecondaryContainer, // Text color
        side: BorderSide.none, // Remove the border
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24), // Same border radius as PrimaryButton
        ),
        minimumSize:
            const Size(double.infinity, 50), // Same size as PrimaryButton
        padding: const EdgeInsets.symmetric(
            vertical: 16), // Same padding as PrimaryButton
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
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSecondaryContainer, // Match text style
            ),
          ),
        ],
      ),
    );
  }
}
