import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/medication_form.dart';
import 'package:provider/provider.dart';

class EditMedicationPage extends StatelessWidget {
  final Medication medication;

  const EditMedicationPage({Key? key, required this.medication}) : super(key: key);

  void _saveMedication(BuildContext context, String name, String dosage, String unit, String additionalInfo, String imageFileName) async {
    final String finalDosage = dosage.isEmpty ? '' : '$dosage ${unit == 'N/A' ? '' : unit}';

    Medication updatedMedication = Medication(
      id: medication.id,
      name: name,
      dosage: finalDosage,
      additionalInfo: additionalInfo,
      imageUrl: imageFileName,
      profileId: medication.profileId,
    );

    try {
      await Provider.of<MedicationProvider>(context, listen: false).updateMedication(updatedMedication);

      if (!context.mounted) return;
      Navigator.pop(context); // Go back instead of home reload
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medication: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Safely parse dosage and unit from the legacy single-string DB field
    final dosageParts = medication.dosage.split(' ');
    String initialDosage = medication.dosage;
    String initialUnit = 'N/A';
    
    if (dosageParts.length > 1) {
      final possibleUnit = dosageParts.last;
      final knownUnits = ['N/A', 'mg', 'mL', 'g', 'mcg', 'IU', '%'];
      if (knownUnits.contains(possibleUnit)) {
         initialUnit = possibleUnit;
         initialDosage = dosageParts.sublist(0, dosageParts.length - 1).join(" ");
      }
    }

    // Always fetch the latest image URL from the provider instead of static widget cache
    final currentMedication = Provider.of<MedicationProvider>(context, listen: true)
        .medications
        .firstWhere((med) => med.id == medication.id, orElse: () => medication);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Header(
          title: 'View Medication',
          showBackButton: Navigator.canPop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: MedicationForm(
                  initialName: medication.name,
                  initialDosage: initialDosage,
                  initialUnit: initialUnit,
                  initialAdditionalInfo: medication.additionalInfo ?? '',
                  initialImageFileName: currentMedication.imageUrl,
                  submitLabel: "Update Medication",
                  onSave: (name, dosage, unit, additionalInfo, imageFileName) {
                    _saveMedication(context, name, dosage, unit, additionalInfo, imageFileName);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
