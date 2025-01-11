import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:pixcellz/utils/shared_prefs_manager.dart';

class AuthService {
  Future<Response> login(String email, String password) async {
    String api = "http://localhost:5001";
    Uri apiUrl = Uri.parse('$api/api/auth/signin');
    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final String sessionToken = responseData['token'];
      final String userId = responseData["user"]['_id'];
      await SharedPreferencesManager.loginUser(userId, sessionToken);
    } else {
      if (response.statusCode == 401) {
        throw "Email ou mot de passe incorrect";
      }
    }

    return response;
  }

  Future<Response> signup(String username, String email, String password) async {
    String api = "http://localhost:5001";
    Uri apiUrl = Uri.parse('$api/api/auth/signup');
    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      final String sessionToken = responseData['token'];
      final String userId = responseData['user']['_id'];
      await SharedPreferencesManager.loginUser(userId, sessionToken);
    } else {
      if (response.statusCode == 409) {
        throw "Un compte existe déjà avec cet email";
      } else if (response.statusCode == 400) {
        throw "Données invalides";
      }
    }

    return response;
  }
}