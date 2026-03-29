import 'package:flutter/material.dart';
import 'package:medication_tracker/data/database/database.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<UserProfile> _profiles = [];
  UserProfile? _selectedProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  ProfileProvider({required DatabaseService databaseService})
      : _databaseService = databaseService {
    loadProfiles();
  }

  List<UserProfile> get profiles => _profiles;
  UserProfile? get selectedProfile => _selectedProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadProfiles() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _profiles = await _databaseService.getAllProfiles();
      // Only auto-select on initial load if nothing is selected
      if (_profiles.isNotEmpty && _selectedProfile == null) {
        _selectedProfile = _profiles.first;
      } else if (_selectedProfile != null) {
        // Refresh the selected profile object from the new list if it still exists
        final index =
            _profiles.indexWhere((p) => p.id == _selectedProfile?.id);
        if (index != -1) {
          _selectedProfile = _profiles[index];
        } else {
          _selectedProfile = null;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load profiles: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProfile(int profileId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedProfile = await _databaseService.getProfile(profileId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.insertProfile(profile);
      await loadProfiles();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateProfile(profile);
      await loadProfiles();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfile(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteProfile(id);
      if (_selectedProfile?.id == id) {
        _selectedProfile = null;
      }
      await loadProfiles();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}
