import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/services/storage/local_storage_service.dart';
import 'package:medication_tracker/ui/edit_medication/edit_medication_view.dart';
import 'package:provider/provider.dart';

class MedicationTile extends StatelessWidget {
  final Medication medication;

  const MedicationTile({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = medication.imageUrl.isNotEmpty;
    const double imageSize = 64.0;

    return GestureDetector(
      onTap: () {
        _goEditMedication(context, medication);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.3),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image (if available)
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FutureBuilder<String>(
                  future:
                      Provider.of<LocalStorageService>(context, listen: false)
                          .getFilePath(medication.imageUrl),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.file(
                        File(snapshot.data!),
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, color: Colors.red);
                        },
                      );
                    }
                    return const SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
            ],

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medication Name
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Dosage
                  if (medication.dosage.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.medical_services,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          medication.dosage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Additional Info
                  if (medication.additionalInfo.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          medication.additionalInfo,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Menu Button
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (String result) {
                if (result == 'delete') {
                  _deleteMedication(context, medication.id!);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _goEditMedication(BuildContext context, Medication medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicationPage(medication: medication),
      ),
    );
  }

  void _deleteMedication(BuildContext context, int id) async {
    try {
      await Provider.of<MedicationProvider>(context, listen: false)
          .deleteMedication(id);

      if (!context.mounted) {
        return;
      }
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medication deleted successfully.'),
        ),
      );
    } catch (e) {
      // Show an error message if the deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete medication: $e'),
        ),
      );
    }
  }
}
