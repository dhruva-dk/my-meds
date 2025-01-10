import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DialogUtil {
  static void showPermissionDeniedDialog(
      BuildContext context, String title, String description) {
    final theme = Theme.of(context);

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          backgroundColor: Colors.white,
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                "Open Settings",
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }
}
