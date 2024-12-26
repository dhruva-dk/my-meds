// a file to handle all image picker concerns. We are trying to minimize repeat code of taking photos so that a button to redo
// a medication's photo can easily be implemented anywhere.

//split this folder into view, viewmodel, repository, and service

// image_service.dart
import 'package:flutter/material.dart';

import 'package:medication_tracker/data/repositories/image_repository.dart';
import 'package:medication_tracker/domain/model/medication_model.dart';
import 'package:medication_tracker/data/repositories/medication_provider.dart';
import 'package:medication_tracker/ui/core/ui/permission_denied_dialog.dart';
import 'package:provider/provider.dart';

class ImageService {
  static Future<void> handleTakePhoto(BuildContext context,
      {Medication? medication}) async {
    try {
      String? imagePath = await ImagePermissionService.takePhoto();
      if (context.mounted && imagePath != null) {
        _processImage(context, imagePath, medication);
      }
    } on PermissionDeniedException {
      if (context.mounted) {
        _showPermissionDeniedDialog(context);
      }
    } on ImageSaveException catch (e) {
      if (context.mounted) {
        _showSnackbar(context, e.message);
      }
    }
  }

  static Future<void> handlePickFromGallery(BuildContext context,
      {Medication? medication}) async {
    try {
      String? imagePath = await ImagePermissionService.pickFromGallery();
      if (context.mounted && imagePath != null) {
        _processImage(context, imagePath, medication);
      }
    } on PermissionDeniedException {
      if (context.mounted) {
        _showGalleryPermissionDeniedDialog(context);
      }
    } on ImageSaveException catch (e) {
      if (context.mounted) {
        _showSnackbar(context, e.message);
      }
    }
  }

  static void _processImage(
      BuildContext context, String imagePath, Medication? medication) {
    if (medication != null) {
      _updateMedication(context, medication, imagePath);
    } else {
      _createAndSaveMedication(context, imagePath);
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
  }

  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PermissionDeniedDialog(
          title: "Camera Permission Needed",
          description:
              "Camera access is required to take pictures of medications. Please enable camera access in your device settings.",
        );
      },
    );
  }

  static void _showGalleryPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PermissionDeniedDialog(
          title: "Gallery Permission Needed",
          description:
              "Gallery access is needed to upload photos. Please enable gallery access in your device settings.",
        );
      },
    );
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
