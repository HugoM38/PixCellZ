import 'dart:convert';
import 'package:http/http.dart' as http;

class PixCellZService {
  final String api = "http://localhost:5001";

  Future<http.Response> createPixCellZ(
    String token, 
    Map<String, dynamic> data,
  ) async {
    final apiUrl = Uri.parse('$api/api/pixcells/');
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

  Future<http.Response> updatePixCellZ(
    String pixCellZId, 
    String token, 
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$api/api/pixcells/$pixCellZId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw "Erreur lors de la mise à jour du PixCellZ";
    }

    return response;
  }

Future<List<dynamic>> fetchAllPixCellZ(String token) async {
  final apiUrl = Uri.parse('http://localhost:5001/api/pixcells/all');

  final response = await http.get(
    apiUrl,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body)['pixcells'];
  } else {
    throw "Erreur lors de la récupération de tous les PixCellZ : ${response.statusCode}";
  }
}
}
