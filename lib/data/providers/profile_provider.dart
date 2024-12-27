import 'package:flutter/material.dart';
import 'package:medication_tracker/data/database/database.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<UserProfile> _profiles = [];
  UserProfile? _selectedProfile;

  ProfileProvider({required DatabaseService databaseService})
      : _databaseService = databaseService {
    loadProfiles();
  }

  List<UserProfile> get profiles => _profiles;
  UserProfile? get selectedProfile => _selectedProfile;

  Future<void> loadProfiles() async {
    _profiles = await _databaseService.getAllProfiles();
    if (_profiles.isNotEmpty && _selectedProfile == null) {
      _selectedProfile = _profiles.first;
    }
    notifyListeners();
  }

  Future<void> selectProfile(int profileId) async {
    _selectedProfile = await _databaseService.getProfile(profileId);
    notifyListeners();
  }

  Future<void> addProfile(UserProfile profile) async {
    await _databaseService.insertProfile(profile);
    await loadProfiles();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _databaseService.updateProfile(profile);
    await loadProfiles();
    if (_selectedProfile?.id == profile.id) {
      _selectedProfile = _profiles.firstWhere((p) => p.id == profile.id);
    }
    notifyListeners();
  }

  Future<void> deleteProfile(int id) async {
    await _databaseService.deleteProfile(id);
    if (_selectedProfile?.id == id) {
      _selectedProfile = _profiles.isNotEmpty ? _profiles.first : null;
    }
    await loadProfiles();
  }
}
