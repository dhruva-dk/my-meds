import 'package:flutter/material.dart';
import 'package:medication_tracker/database/database.dart';
import 'package:medication_tracker/model/medication_model.dart';

class MedicationProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Medication> _medications = [];
  bool _isLoading = false;

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  MedicationProvider() {
    loadMedications();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loadMedications() async {
    setLoading(true);
    try {
      _medications = await _databaseHelper.queryAllRows();
    } finally {
      setLoading(false);
      notifyListeners();
    }
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
