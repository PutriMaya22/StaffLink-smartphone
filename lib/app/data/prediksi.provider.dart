import 'package:http/http.dart' as http;
import 'dart:convert';

class PromotionProvider {
  final String baseUrl = 'http://localhost:8000/api/predict'; // Ganti kalau API bukan di localhost

  /// Kirim data ke API dan dapat response berupa Map JSON
  Future<Map<String, dynamic>> predictPromotion(Map<String, dynamic> inputData) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(inputData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to predict promotion: ${response.statusCode}');
    }
  }
}
