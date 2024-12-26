import 'package:flutter/material.dart';
import 'package:medication_tracker/camera_services/camera_helper.dart';
import 'package:medication_tracker/data/services/database_service.dart';
import 'package:medication_tracker/domain/model/medication_model.dart';

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
      List<Medication> loadedMedications = await _databaseHelper.queryAllRows();

      // Adjust image paths for each medication
      List<Future> imagePathAdjustments = [];
      for (var medication in loadedMedications) {
        if (medication.imageUrl.isNotEmpty) {
          imagePathAdjustments.add(
            CameraHelper.getImagePath(medication.imageUrl).then((path) {
              medication.imageUrl = path ?? medication.imageUrl;
            }),
          );
        }
      }

      // Wait for all image path adjustments to complete
      await Future.wait(imagePathAdjustments);

      _medications = loadedMedications;
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
