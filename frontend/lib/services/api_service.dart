import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService({String? baseUrl})
      : baseUrl = baseUrl ??
            const String.fromEnvironment('BARLY_API',
                defaultValue: 'http://localhost:3001');
  final String baseUrl;

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<String?> get token async =>
      (await SharedPreferences.getInstance()).getString('token');

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers(null),
        body: jsonEncode({'email': email, 'password': password}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await saveToken(data['token']);
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Login échoué: ${res.body}');
  }

  Future<Map<String, dynamic>> register(String firstName, String email,
      String password, Map<String, List<String>> preferences) async {
    final res = await http.post(Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers(null),
        body: jsonEncode({
          'firstName': firstName,
          'email': email,
          'password': password,
          'preferences': preferences
        }));
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      await saveToken(data['token']);
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Register échoué: ${res.body}');
  }

  Future<List<dynamic>> getBars() async {
    final res = await http.get(Uri.parse('$baseUrl/api/bars'),
        headers: _headers(await token));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur bars');
  }

  Future<List<dynamic>> getEvents() async {
    final res = await http.get(Uri.parse('$baseUrl/api/events'),
        headers: _headers(await token));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur events');
  }

  Future<void> joinEvent(String id) async {
    final res = await http.post(Uri.parse('$baseUrl/api/events/$id/join'),
        headers: _headers(await token));
    if (res.statusCode >= 400) throw Exception('Join échoué');
  }

  Future<Map<String, dynamic>?> getMe() async {
    final res = await http.get(Uri.parse('$baseUrl/api/users/me'),
        headers: _headers(await token));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }
}
