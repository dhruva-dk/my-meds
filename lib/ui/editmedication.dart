import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medication_tracker/local_service/image_service.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
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
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  void _saveMedication(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String dosage = _dosageController.text;
      final String additionalInfo = _additionalInfoController.text;

      Medication updatedMedication = Medication(
        id: widget.medication.id,
        name: name,
        dosage: dosage,
        additionalInfo: additionalInfo,
        imageUrl: widget.medication.imageUrl,
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
        title: Text('Edit Medication'),
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
                SizedBox(height: 8),
                TextFormField(
                  controller: _dosageController,
                  decoration: _inputDecoration('Dosage'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a dosage';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _additionalInfoController,
                  decoration: _inputDecoration('Additional Info'),
                  // No validation for Additional Info as it's optional
                ),
                if (hasImage) const SizedBox(height: 16),
                if (hasImage)
                  ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Consumer<MedicationProvider>(
                        builder: (context, provider, child) {
                          Medication updatedMedication = provider.medications
                              .firstWhere((medication) =>
                                  medication.id == widget.medication.id);
                          return Image.file(
                            File(updatedMedication.imageUrl ?? ''),
                            // Rest of your image properties...
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: 300,
                          );
                        },
                      )),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _handleTakePhoto(); // take photo and display snackbar to successfully update
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully added photo.'),
                      ),
                    );
                    //rebuild widget
                  },
                  child: Text(hasImage ? 'Retake Photo' : 'Add Photo'),
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.black),
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _saveMedication(context),
                  child: Text('Save Medication'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
