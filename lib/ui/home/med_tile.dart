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

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<String>(
                future: Provider.of<LocalStorageService>(context, listen: false)
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
          ],
          if (hasImage) ...[
            const SizedBox(width: 16),
          ],

          // Middle - Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (medication.dosage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    medication.dosage,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (medication.additionalInfo.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    medication.additionalInfo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Right side - Menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey[400],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (String result) {
              if (result == 'edit') {
                _goEditMedication(context, medication);
              } else if (result == 'delete') {
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

  void _deleteMedication(BuildContext context, int id) {
    Provider.of<MedicationProvider>(context, listen: false)
        .deleteMedication(id);
  }
}
