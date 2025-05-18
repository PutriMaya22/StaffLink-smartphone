import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportProvider {
  final String baseUrl = 'http://localhost:8000/api/report'; // Ganti dengan IP komputer kamu

  Future<List<dynamic>> getReports() async {
    final url = Uri.parse(baseUrl);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : [data];
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Future<bool> sendReport(Map<String, dynamic> reportData) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reportData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to send report');
    }
  }
}
