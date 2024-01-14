import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DialogUtil {
  static void showPermissionDeniedDialog(
      BuildContext context, String title, String description) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
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
      },
    );
  }
}
