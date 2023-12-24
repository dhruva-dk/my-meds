import 'package:flutter/material.dart';
import 'package:medication_tracker/database/database.dart';
import 'package:medication_tracker/model/medication_model.dart';
import 'package:provider/provider.dart';

class MedicationProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Medication> _medications = [];

  List<Medication> get medications => _medications;

  MedicationProvider() {
    loadMedications();
  }

  Future<void> loadMedications() async {
    _medications = await _databaseHelper.queryAllRows();
    notifyListeners();
  }

  Future<void> addMedication(Medication medication) async {
    await _databaseHelper.insert(medication);
    await loadMedications();
  }

  Future<void> updateMedication(Medication medication) async {
    await _databaseHelper.update(medication);
    await loadMedications();
  }

  Future<void> deleteMedication(int id) async {
    await _databaseHelper.delete(id);
    await loadMedications();
  }
}
