import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDeniedDialog extends StatelessWidget {
  final String title;
  final String description;

  const PermissionDeniedDialog({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
        backgroundColor: Colors.white,
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        content: Text(
          description,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              "Cancel",
              textAlign: TextAlign.center,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(
              "Open Settings",
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceEvenly);
  }
}
