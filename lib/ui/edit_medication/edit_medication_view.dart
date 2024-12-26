import 'package:flutter/material.dart';
import 'package:medication_tracker/utils/image_ui_handler.dart';
import 'package:medication_tracker/domain/model/medication_model.dart';
import 'package:medication_tracker/data/repositories/medication_provider.dart';
import 'package:medication_tracker/ui/core/ui/black_button.dart';
import 'package:medication_tracker/ui/core/ui/photo_upload_row.dart';
import 'package:medication_tracker/ui/edit_medication/zoomable_image.dart';
import 'package:provider/provider.dart';

class EditMedicationPage extends StatefulWidget {
  final Medication medication;

  const EditMedicationPage({Key? key, required this.medication})
      : super(key: key);

  @override
  _EditMedicationPageState createState() => _EditMedicationPageState();
}

class _EditMedicationPageState extends State<EditMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _dosageController = TextEditingController(text: widget.medication.dosage);
    _additionalInfoController =
        TextEditingController(text: widget.medication.additionalInfo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      //hintText: label,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  void _saveMedication(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String dosage = _dosageController.text;
      final String additionalInfo = _additionalInfoController.text;
      // for imageurl, get imageurl from provider to avoid issues where the
      // imageurl was not first defined when the user tapped on the medication to edit

      final String imageUrl =
          Provider.of<MedicationProvider>(context, listen: false)
              .medications
              .firstWhere((medication) => medication.id == widget.medication.id)
              .imageUrl;

      Medication updatedMedication = Medication(
        id: widget.medication.id,
        name: name,
        dosage: dosage,
        additionalInfo: additionalInfo,
        imageUrl: imageUrl,
      );

      Provider.of<MedicationProvider>(context, listen: false)
          .updateMedication(updatedMedication);

      Navigator.pop(context);
    }
  }

  void _handleTakePhoto() async {
    await ImageService.handleTakePhoto(context,
        medication: widget.medication); //don't navigate back
  }

  void _handleUploadFromGallery() async {
    await ImageService.handlePickFromGallery(context,
        medication: widget.medication); //don't navigate back
  }

  @override
  Widget build(BuildContext context) {
    //first medication with same id as widget.medication in provider
    bool hasImage = Provider.of<MedicationProvider>(context)
        .medications
        .firstWhere((medication) => medication.id == widget.medication.id)
        .imageUrl
        .isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Medication Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a medication name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dosageController,
                  decoration: _inputDecoration('Dosage (optional)'),
                  //no validation for dosage as it's optional
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _additionalInfoController,
                  decoration: _inputDecoration('Additional Info (optional)'),
                  // No validation for Additional Info as it's optional
                ),
                if (hasImage) ...[
                  Consumer<MedicationProvider>(
                      builder: (context, provider, child) {
                    Medication updatedMedication = provider.medications
                        .firstWhere((medication) =>
                            medication.id == widget.medication.id);
                    return ZoomableImage(imagePath: updatedMedication.imageUrl);
                  }),
                ],
                const SizedBox(height: 16),
                PhotoUploadRow(
                  onTakePhoto: _handleTakePhoto,
                  onUploadPhoto: _handleUploadFromGallery,
                  hasImage: hasImage,
                ),
                const SizedBox(height: 8),
                BlackButton(
                    title: "Update Medication",
                    onTap: () => _saveMedication(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
