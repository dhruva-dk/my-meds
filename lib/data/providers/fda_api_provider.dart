import 'package:flutter/material.dart';
import 'package:medication_tracker/data/api/fda_api_service.dart';
import 'package:medication_tracker/data/model/fda_drug_model.dart';

class FDAAPIServiceProvider with ChangeNotifier {
  final FDAAPIService _apiService = FDAAPIService();

  List<FDADrug> _searchResults = [];

  List<FDADrug> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> searchMedications(String query) async {
    _isLoading = true;
    _errorMessage = '';

    notifyListeners();

    try {
      _searchResults = await _apiService.searchMedications(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle exceptions
      _isLoading = false;
      //throw exception
      _errorMessage = '$e';
      notifyListeners();
    }
  }
}
