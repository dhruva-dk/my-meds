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
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  List<FDADrug> _processMedications(List<FDADrug> medications) {
    // Remove duplicates
    var uniqueMedications = <String, FDADrug>{};
    for (var medication in medications) {
      uniqueMedications[medication.ndc] = medication;
    }
    return uniqueMedications.values.toList();
  }
}
