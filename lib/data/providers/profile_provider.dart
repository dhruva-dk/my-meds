import 'package:flutter/material.dart';
import 'package:medication_tracker/data/database/database.dart';
import 'package:medication_tracker/data/model/user_profile_model.dart';

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
    //print all profiles
    for (var profile in _profiles) {
      print(profile);
    }
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
    if (_selectedProfile?.id == profile.id) {
      _selectedProfile = _profiles.firstWhere((p) => p.id == profile.id);
    }
    notifyListeners();
  }

  Future<void> deleteProfile(int id) async {
    await _db.deleteProfile(id);
    if (_selectedProfile?.id == id) {
      _selectedProfile = _profiles.isNotEmpty ? _profiles.first : null;
    }
    await loadProfiles();
  }
}
