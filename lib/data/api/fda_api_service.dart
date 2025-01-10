import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medication_tracker/data/model/fda_drug_model.dart';

class FDAAPIService {
  final String baseUrl = "https://api.fda.gov/drug/ndc.json";

  Future<List<FDADrug>> searchMedications(String query) async {
    query = query.toLowerCase();
    final url = Uri.parse(
        '$baseUrl?search=brand_name:$query+generic_name:$query&limit=10');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['results']?.isNotEmpty ?? false) {
          return _processMedications(data['results']
              .map<FDADrug>((item) => FDADrug.fromMap(item))
              .toList());
        }
      }
      throw Exception('No results found');
    } catch (e) {
      rethrow;
    }
  }

  List<FDADrug> _processMedications(List<FDADrug> medications) {
    // Helper function to convert a string to title case
    String toTitleCase(String str) {
      return str.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    // Remove duplicates and convert fields to title case
    var uniqueMedications = <String, FDADrug>{};
    for (var medication in medications) {
      uniqueMedications[medication.ndc] = FDADrug(
        brandName: toTitleCase(medication.brandName),
        genericName: toTitleCase(medication.genericName),
        dosageForm: toTitleCase(medication.dosageForm),
        ndc: medication.ndc,
      );
    }
    return uniqueMedications.values.toList();
  }
}
