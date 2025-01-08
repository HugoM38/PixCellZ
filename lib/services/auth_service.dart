import 'dart:convert';
import 'package:http/http.dart';
import 'package:pixcellz/utils/shared_prefs_manager.dart';

class AuthService {
  Future<Response> login(String email, String password) async {
    //TODO: Uncomment this code when api is ready
    // String api = "http://localhost:3000";
    // Uri apiUrl = Uri.parse('$api/login');
    // final response = await http.post(
    //   apiUrl,
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode({
    //     'email': email,
    //     'password': password,
    //   }),
    // );

    final response = Response('''{
  "session_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNWYzZjQwZjQwZjQwZjQwZjQwZjQwZjQwIiwic2Vzc2lvbl90b2tlbiI6IjE2Mjg4NzYwNzIwNzIiLCJpYXQiOjE2Mjg4NzYwNzJ9.1",
  "user_id": "5f3f40f40f40f40f40f40f40"
}''', 200);

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final String sessionToken = responseData['session_token'];
      final String userId = responseData['user_id'];
      await SharedPreferencesManager.loginUser(userId, sessionToken);
    } else {
      if (response.statusCode == 401) {
        throw "Email ou mot de passe incorrect";
      }
    }

    return response;
  }

  Future<Response> signup(String username, String email, String password) async {
    //TODO: Uncomment this code when api is ready
    // String api = "http://localhost:3000";
    // Uri apiUrl = Uri.parse('$api/signup');
    // final response = await http.post(
    //   apiUrl,
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode({
    //     'username': username,
    //     'email': email,
    //     'password': password,
    //   }),
    // );

    final response = Response('''{
  "session_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNWYzZjQwZjQwZjQwZjQwZjQwZjQwZjQwIiwic2Vzc2lvbl90b2tlbiI6IjE2Mjg4NzYwNzIwNzIiLCJpYXQiOjE2Mjg4NzYwNzJ9.1",
  "user_id": "5f3f40f40f40f40f40f40f40"
}''', 201);

    final responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      final String sessionToken = responseData['session_token'];
      final String userId = responseData['user_id'];
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