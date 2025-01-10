import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Header extends StatelessWidget {
  final String title;
  final Widget? rightWidget;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const Header({
    Key? key,
    required this.title,
    this.rightWidget,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      color: theme.colorScheme.primary, // Use primary color from theme
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (showBackButton && Navigator.of(context).canPop())
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: theme.colorScheme
                          .onPrimary, // Use onPrimary color from theme
                      size: 32,
                    ),
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                  ),
                Expanded(
                  child: AutoSizeText(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme
                          .onPrimary, // Use onPrimary color from theme
                    ),
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 18,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          if (rightWidget != null) rightWidget!,
        ],
      ),
    );
  }
}
