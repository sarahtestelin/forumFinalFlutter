import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class AuthService {
  static const String baseUrl = "https://s3-4684.nuage-peda.fr/forumFinal/api";

  final SecureStorage secureStorage = SecureStorage();

  /// Connexion de l'utilisateur
  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/authentication_token");
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': email, // ✅ Utilise "email" au lieu de "username"
      'password': password,
    });

    final response = await http.post(url, headers: headers, body: body);
    print("🔹 Réponse API : ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      await secureStorage.saveCredentials(email, password);
      await secureStorage.saveToken(responseData['token']);
      return true; // Connexion réussie
    } else {
      throw Exception("Échec de connexion : ${response.body}");
    }
  }

  /// Déconnexion : supprime les infos stockées
  Future<void> logout() async {
    await secureStorage.deleteCredentials();
  }
}