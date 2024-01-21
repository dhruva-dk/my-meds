import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medication_tracker/model/fda_drug_model.dart';

class FDAAPIService {
  final String baseUrl =
      "https://api.fda.gov/drug/ndc.json"; // Update with actual base URL

  Future<List<FDADrug>> searchMedications(String query) async {
    query = query.toLowerCase();
    final url = Uri.parse(
        '$baseUrl?search=brand_name:$query+generic_name:$query&limit=10');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        List<FDADrug> medications = [];

        for (var item in data['results']) {
          medications.add(FDADrug.fromMap(item));
        }
        return _processMedications(medications);
      } else {
        throw Exception('No results found');
      }
    } else {
      throw Exception('No Results Found');
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
