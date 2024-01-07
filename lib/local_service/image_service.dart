// a file to handle all image picker concerns. We are trying to minimize repeat code of taking photos so that a button to redo
// a medication's photo can easily be implemented anywhere.

// image_service.dart
import 'package:flutter/material.dart';
import 'package:medication_tracker/local_service/camera_helper.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ImageService {
  static Future<void> handleTakePhoto(
    BuildContext context, {
    Medication? medication,
  }) async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
// what is mounted

    if (status.isGranted) {
      String? imagePath = await CameraHelper.captureAndSaveImage();
      if (imagePath != null) {
        if (medication != null) {
          if (context.mounted) {
            _updateMedication(context, medication, imagePath);
          }
        } else {
          if (context.mounted) _createAndSaveMedication(context, imagePath);
        }
      } else {
        if (context.mounted) _showSnackbar(context, 'Error capturing image');
      }
    } else {
      if (context.mounted) _showPermissionDeniedDialog(context);
    }
  }

  static Future<void> handlePickFromGallery(
    BuildContext context, {
    Medication? medication,
  }) async {
    var status = await Permission
        .photos.status; // Use Permission.photos for gallery access
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      // Gallery picking logic
      String? imagePath = await CameraHelper.pickImageFromGallery();
      if (imagePath != null) {
        if (medication != null) {
          if (context.mounted) {
            _updateMedication(context, medication, imagePath);
          }
        } else {
          if (context.mounted) _createAndSaveMedication(context, imagePath);
        }
      } else {
        if (context.mounted) _showSnackbar(context, 'Error saving image');
      }
    } else {
      if (context.mounted) _showGalleryPermissionDeniedDialog(context);
    }
  }

  static void _createAndSaveMedication(BuildContext context, String imagePath) {
    Medication newMedication = Medication(
      name: "Photo",
      dosage: "",
      additionalInfo: "",
      imageUrl: imagePath,
    );

    Provider.of<MedicationProvider>(context, listen: false)
        .addMedication(newMedication);

    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
  }

  static void _updateMedication(
      BuildContext context, Medication medication, String imagePath) {
    Medication updatedMedication = medication.copyWith(
        imageUrl: imagePath); // Assuming copyWith method is implemented
    Provider.of<MedicationProvider>(context, listen: false)
        .updateMedication(updatedMedication);
    //Navigator.pop(context); // don't pop if updating image, as we want to stay on the page.
  }

  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Camera Permission Needed"),
          content: const Text(
              "Camera access is required to take pictures of medications. Please enable camera access in your device settings."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void _showGalleryPermissionDeniedDialog(BuildContext context) {
    // Similar dialog logic for permission denied as in the camera method
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Gallery Permission Needed"),
          content: const Text(
              "Gallery access is needed to upload photos. Please enable camera access in your device settings."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
