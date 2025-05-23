import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'http://localhost:8000/api/absen'; // Ganti sesuai IP + port server Laravel kamu

Future<void> kirimAbsensi({
  required int userId,
  String? jam,          // optional, format "HH:mm"
  String? keterangan,   // optional, terutama untuk izin/sakit
}) async {
  final url = Uri.parse('$baseUrl/api/absen');

  final body = {
    'user_id': userId,
    if (jam != null) 'jam': jam,
    if (keterangan != null) 'keterangan': keterangan,
  };

  try {
    print('POST to URL: $url');  // debug URL
    print('Request body: $body'); // debug body data

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      print('Absen berhasil: ${response.body}');
    } else {
      print('Gagal absen: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Error kirimAbsensi: $e');
  }
}
