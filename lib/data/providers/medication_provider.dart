import 'package:flutter/material.dart';
import 'package:medication_tracker/data/database/database.dart';
import 'package:medication_tracker/data/model/medication_model.dart';
import 'package:medication_tracker/data/providers/profile_provider.dart';

class MedicationProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  final ProfileProvider _profileProvider;
  List<Medication> _medications = [];
  bool _isLoading = false;
  String _errorMessage = '';

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
  String get errorMessage => _errorMessage;

  Future<void> loadMedications() async {
    if (_profileProvider.selectedProfile == null) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _medications = await _databaseService
          .getMedicationsForProfile(_profileProvider.selectedProfile!.id!);
    } catch (e) {
      _errorMessage = 'Failed to load medications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedication(Medication medication) async {
    if (_profileProvider.selectedProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      medication =
          medication.copyWith(profileId: _profileProvider.selectedProfile!.id);
      await _databaseService.insertMedication(medication);
      await loadMedications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMedication(Medication medication) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateMedication(medication);
      await loadMedications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedication(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteMedication(id);
      await loadMedications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
