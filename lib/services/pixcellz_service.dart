import 'dart:convert';
import 'package:http/http.dart' as http;

class PixCellZService {
  Future<http.Response> createPixCellZ(
      String token, Map<String, dynamic> data) async {
    String api = "http://localhost:5001";
    Uri apiUrl = Uri.parse('$api/api/pixcells/');
    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw "Erreur lors de la création du PixCellZ";
    }

    return response;
  }
}
