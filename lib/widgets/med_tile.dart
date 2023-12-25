import 'package:flutter/material.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class MedicationTile extends StatelessWidget {
  final Medication medication;

  MedicationTile({
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 1),
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
                  '${medication.name} - ${medication.dosage}',
                  style: TextStyle(
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
          Theme(
            data: Theme.of(context).copyWith(),
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'delete') {
                  _deleteMedication(context, medication.id!);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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

  void _deleteMedication(BuildContext context, int id) {
    // Call the delete method from MedicationProvider
    Provider.of<MedicationProvider>(context, listen: false)
        .deleteMedication(id);
  }
}
