import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medication_tracker/local_service/image_service.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/ui/full_screen_image.dart';
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

  Widget _buildPhotoButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
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
        title: const Text('Edit Medication'),
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
                  const SizedBox(height: 16),
                  Consumer<MedicationProvider>(
                    builder: (context, provider, child) {
                      Medication updatedMedication = provider.medications
                          .firstWhere((medication) =>
                              medication.id == widget.medication.id);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                imagePath: updatedMedication
                                    .imageUrl, // no need to check for null as the image is already known to exist.
                              ),
                            ),
                          );
                        },
                        child: Image.file(
                          File(updatedMedication.imageUrl ?? ''),
                          // Rest of your image properties...
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 300,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tap on image to increase size and zoom.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPhotoButton('Take a Picture', () async {
                      _handleTakePhoto();
                      /*ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Successfully added photo.'),
                        ),
                      );*/
                    }),
                    const SizedBox(width: 8), // Spacing between buttons
                    _buildPhotoButton('Upload from Gallery', () async {
                      _handleUploadFromGallery();
                      //don't navigate back
                      /* ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Successfully added photo.'),
                        ),
                      );*/
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _saveMedication(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Update Medication'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
