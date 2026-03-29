import 'package:flutter/material.dart';
import 'package:medication_tracker/data/model/fda_drug_model.dart';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/providers/medication_provider.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';
import 'package:medication_tracker/ui/core/header.dart';
import 'package:medication_tracker/ui/core/medication_form.dart';
import 'package:provider/provider.dart';

class CreateMedicationPage extends StatefulWidget {
  final FDADrug? initialDrug;
  final String? imageFileName;
  /// Called after the medication is saved. The shell uses this to switch
  /// to the Home tab. Falls back to popping the route if null.
  final VoidCallback? onAdded;

  const CreateMedicationPage({
    super.key,
    this.initialDrug,
    this.imageFileName,
    this.onAdded,
  });

  @override
  State<CreateMedicationPage> createState() => _CreateMedicationPageState();
}

class _CreateMedicationPageState extends State<CreateMedicationPage> {
  void _accept(BuildContext context, String name, String dosage, String unit, String additionalInfo, String imageFileName) async {
    final String finalDosage = dosage.isEmpty ? '' : '$dosage ${unit == 'N/A' ? '' : unit}';

    final profileId = context.read<ProfileProvider>().selectedProfile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No profile selected. Please select a profile first.')),
      );
      return;
    }

    Medication newMedication = Medication(
      name: name,
      dosage: finalDosage,
      additionalInfo: additionalInfo,
      profileId: profileId,
      imageUrl: imageFileName,
    );

    try {
      await Provider.of<MedicationProvider>(context, listen: false).addMedication(newMedication);

      if (!context.mounted) return;
      // Pop back to the FDASearchPage root within the tab, then let the
      // shell switch to the Home tab via the callback.
      Navigator.of(context).popUntil((route) => route.isFirst);
      widget.onAdded?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add medication: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Deriving initial values based on FDA search or camera routing
    final initialName = widget.initialDrug != null
        ? "Brand: ${widget.initialDrug!.brandName}\nGeneric: ${widget.initialDrug!.genericName}"
        : widget.imageFileName != null ? "Image" : '';
    final initialAdditionalInfo = widget.initialDrug != null ? "Dosage type: ${widget.initialDrug!.dosageForm}" : "";

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Header(
          title: 'Add Medication',
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
                  initialName: initialName,
                  initialDosage: '',
                  initialUnit: 'N/A',
                  initialAdditionalInfo: initialAdditionalInfo,
                  initialImageFileName: widget.imageFileName ?? '',
                  submitLabel: "Add Medication",
                  onSave: (name, dosage, unit, additionalInfo, imageFileName) {
                    _accept(context, name, dosage, unit, additionalInfo, imageFileName);
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
