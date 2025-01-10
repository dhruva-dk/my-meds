// header_widget.dart
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (showBackButton && Navigator.of(context).canPop())
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                  ),
                Expanded(
                  child: AutoSizeText(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
