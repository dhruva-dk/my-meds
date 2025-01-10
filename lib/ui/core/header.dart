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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8.0,
          left: 20.0,
          right: 20.0,
          bottom: 32.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (showBackButton && Navigator.of(context).canPop())
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white, width: 1), // White border
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: theme.colorScheme.onSecondary,
                          size: 32,
                        ),
                        onPressed:
                            onBackPressed ?? () => Navigator.of(context).pop(),
                      ),
                    ),
                  const SizedBox(width: 16), // Space between icon and text
                  Expanded(
                    child: AutoSizeText(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSecondary,
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
      ),
    );
  }
}
