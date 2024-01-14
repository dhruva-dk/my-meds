import 'package:flutter/material.dart';
import 'package:medication_tracker/database/profile_database.dart';
import 'package:medication_tracker/model/user_profile_model.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileDatabaseHelper _dbHelper = ProfileDatabaseHelper.instance;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  ProfileProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    List<UserProfile> profiles = await _dbHelper.queryAllRows();
    if (profiles.isNotEmpty) {
      _userProfile = profiles.first;
    }
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _dbHelper.deleteAllProfiles();
    await _dbHelper.insert(profile);
    await loadProfile();
  }

  Future<void> deleteProfile(int id) async {
    await _dbHelper.delete(id);
    _userProfile = null;
    notifyListeners();
  }
}
