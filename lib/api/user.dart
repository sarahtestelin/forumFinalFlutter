import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://s3-4684.nuage-peda.fr/forumFinal/api/authentication_token'; // Remplace par ton URL d'API

  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Échec de connexion : ${response.reasonPhrase}');
    }
  }
}
