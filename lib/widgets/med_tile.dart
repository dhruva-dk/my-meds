import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/ui/editmedication.dart';
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
    String medicationText = medication.dosage.isNotEmpty
        ? '${medication.name} - ${medication.dosage}'
        : medication.name;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  medicationText,
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  medication.additionalInfo,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (hasImage) ...[
            const SizedBox(width: 16), // Spacing between text and image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(medication.imageUrl),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red);
                },
              ),
            ),
          ],
          Theme(
            data: Theme.of(context).copyWith(),
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'edit') {
                  _goEditMedication(context, medication);
                } else if (result == 'delete') {
                  _deleteMedication(context, medication.id!);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                // Add Edit menu item
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text('Edit',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        )),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goEditMedication(BuildContext context, Medication medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditMedicationPage(medication: medication)),
    );
  }

  void _deleteMedication(BuildContext context, int id) {
    // Call the delete method from MedicationProvider
    Provider.of<MedicationProvider>(context, listen: false)
        .deleteMedication(id);
  }
}
