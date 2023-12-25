import 'package:flutter/material.dart';
import 'package:medication_tracker/api/fda_api_service.dart';
import 'package:medication_tracker/model/fda_drug.dart';

class FDAAPIServiceProvider with ChangeNotifier {
  final FDAAPIService _apiService = FDAAPIService();

  List<FDADrug> _searchResults = [];

  List<FDADrug> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> searchMedications(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchMedications(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle exceptions
      _isLoading = false;
      //throw exception
      throw Exception('Failed to load medications from FDA');
    }
  }
}
