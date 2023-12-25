import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medication_tracker/model/fda_drug.dart';

class FDAAPIService {
  final String baseUrl =
      "https://api.fda.gov/drug/ndc.json"; // Update with actual base URL

  Future<List<FDADrug>> searchMedications(String query) async {
    query = query.toLowerCase();
    final url =
        Uri.parse('$baseUrl?search=brand_name:$query OR generic_name:$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<FDADrug> medications = [];

      for (var item in data['results']) {
        medications.add(FDADrug.fromJson(item));
      }
      return medications;
    } else {
      // Handle network error or invalid response
      throw Exception('Failed to load medications from FDA');
    }
  }
}
