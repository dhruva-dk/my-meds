import 'package:flutter/material.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:medication_tracker/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class TestStoragePage extends StatefulWidget {
  const TestStoragePage({super.key});

  @override
  _TestStoragePageState createState() => _TestStoragePageState();
}

class _TestStoragePageState extends State<TestStoragePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  void _cancel() {
    Navigator.pop(context);
  }

  void _accept(BuildContext context) async {
    final String name = _nameController.text;
    final String dosage = _dosageController.text;
    final String additionalInfo = _additionalInfoController.text;

    // Create a Medication object
    Medication newMedication = Medication(
      name: name,
      dosage: dosage,
      additionalInfo: additionalInfo,
    );

    // Save the medication using MedicationProvider
    try {
      await Provider.of<MedicationProvider>(context, listen: false)
          .addMedication(newMedication);
      Navigator.pop(context); // Go back to the previous screen after saving
    } catch (e) {
      // Handle errors, e.g., show a Snackbar
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error saving medication')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Local Storage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Medication Name'),
            ),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosage'),
            ),
            TextField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(labelText: 'Additional Info'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => _accept(context), child: const Text('Accept')),
            TextButton(onPressed: _cancel, child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}
