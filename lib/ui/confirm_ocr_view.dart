import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/model/ocr_title_model.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:medication_tracker/ui/full_screen_image_view.dart';
import 'package:medication_tracker/widgets/zoomable_image.dart';
import 'package:provider/provider.dart';

class ConfirmOcrView extends StatefulWidget {
  final OCRTitle ocr;

  const ConfirmOcrView({Key? key, required this.ocr}) : super(key: key);

  @override
  State<ConfirmOcrView> createState() => _ConfirmOcrViewState();
}

class _ConfirmOcrViewState extends State<ConfirmOcrView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ocr.title);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  void _accept(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String dosage = _dosageController.text;
      final String additionalInfo = _additionalInfoController.text;

      Medication newMedication = Medication(
          name: name,
          dosage: dosage,
          additionalInfo: additionalInfo,
          imageUrl: widget.ocr.imagePath);

      try {
        await Provider.of<MedicationProvider>(context, listen: false)
            .addMedication(newMedication);
        if (!mounted) return;
        // Navigate back to home screen
        Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error saving medication')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Medication'),
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
                ZoomableImage(imagePath: widget.ocr.imagePath),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Currently no functionality. Add functionality later as needed.
                    _accept(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
