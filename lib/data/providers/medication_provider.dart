// medication_provider.dart
import 'package:flutter/material.dart';
import 'package:medication_tracker/data/database/database.dart';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';

class MedicationProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final ProfileProvider _profileProvider;
  List<Medication> _medications = [];
  bool _isLoading = false;

  MedicationProvider(this._profileProvider,
      {required DatabaseService databaseService})
      : _databaseService = databaseService {
    if (_profileProvider.selectedProfile != null) {
      loadMedications();
    }
    _profileProvider.addListener(_onProfileChanged);
  }

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  Future<void> loadMedications() async {
    if (_profileProvider.selectedProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _medications = await _databaseService
          .getMedicationsForProfile(_profileProvider.selectedProfile!.id!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedication(Medication medication) async {
    if (_profileProvider.selectedProfile == null) return;

    medication =
        medication.copyWith(profileId: _profileProvider.selectedProfile!.id);
    await _databaseService.insertMedication(medication);
    await loadMedications();
  }

  Future<void> updateMedication(Medication medication) async {
    await _databaseService.updateMedication(medication);
    await loadMedications();
  }

  Future<void> deleteMedication(int id) async {
    await _databaseService.deleteMedication(id);
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
