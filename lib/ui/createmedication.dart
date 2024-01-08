import 'package:flutter/material.dart';
import 'package:medication_tracker/model/fda_drug.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class CreateMedicationPage extends StatefulWidget {
  final FDADrug? initialDrug;

  const CreateMedicationPage({super.key, this.initialDrug});

  @override
  _CreateMedicationPageState createState() => _CreateMedicationPageState();
}

class _CreateMedicationPageState extends State<CreateMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialDrug != null
          ? "${widget.initialDrug!.brandName} - ${widget.initialDrug!.genericName}"
          : '',
    );
    _dosageController = TextEditingController();
    _additionalInfoController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
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
          imageUrl: "");

      try {
        await Provider.of<MedicationProvider>(context, listen: false)
            .addMedication(newMedication);
        Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error saving medication')));
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Name'),
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
                  decoration: _inputDecoration('Dosage'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a dosage';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _additionalInfoController,
                  decoration: _inputDecoration('Additional Info (optional)'),
                  // No validation needed for additional info as it's optional
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _accept(context),
                  child: const Text('Add Medication'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
