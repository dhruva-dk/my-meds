// medication_provider.dart
import 'package:flutter/material.dart';
import 'package:medication_tracker/data/database/database.dart';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';

class MedicationProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final ProfileProvider _profileProvider;
  List<Medication> _medications = [];
  bool _isLoading = false;

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  MedicationProvider(this._profileProvider) {
    if (_profileProvider.selectedProfile != null) {
      loadMedications();
    }
    _profileProvider.addListener(_onProfileChanged);
  }

  Future<void> loadMedications() async {
    if (_profileProvider.selectedProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _medications = await _db
          .getMedicationsForProfile(_profileProvider.selectedProfile!.id!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedication(Medication medication) async {
    if (_profileProvider.selectedProfile == null) return;

    // Ensure the medication is linked to the current profile
    medication =
        medication.copyWith(profileId: _profileProvider.selectedProfile!.id);

    await _db.insertMedication(medication);
    await loadMedications();
  }

  Future<void> updateMedication(Medication medication) async {
    await _db.updateMedication(medication);
    await loadMedications();
  }

  Future<void> deleteMedication(int id) async {
    await _db.deleteMedication(id);
    await loadMedications();
  }

  void _onProfileChanged() {
    loadMedications();
  }

  @override
  void dispose() {
    _profileProvider.removeListener(_onProfileChanged);
    super.dispose();
  }
}
