import 'package:flutter/material.dart';
import 'package:medication_tracker/database/database.dart';
import 'package:medication_tracker/model/user_profile_model.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  List<UserProfile> _profiles = [];
  UserProfile? _selectedProfile;

  List<UserProfile> get profiles => _profiles;
  UserProfile? get selectedProfile => _selectedProfile;

  ProfileProvider() {
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    _profiles = await _db.getAllProfiles();
    if (_profiles.isNotEmpty && _selectedProfile == null) {
      _selectedProfile = _profiles.first;
    }
    notifyListeners();
  }

  Future<void> selectProfile(int profileId) async {
    _selectedProfile = await _db.getProfile(profileId);
    notifyListeners();
  }

  Future<void> addProfile(UserProfile profile) async {
    await _db.insertProfile(profile);
    await loadProfiles();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _db.updateProfile(profile);
    await loadProfiles();
  }

  Future<void> deleteProfile(int id) async {
    await _db.deleteProfile(id);
    if (_selectedProfile?.id == id) {
      _selectedProfile = _profiles.isNotEmpty ? _profiles.first : null;
    }
    await loadProfiles();
  }
}
