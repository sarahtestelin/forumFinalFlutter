import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class AuthProvider with ChangeNotifier {
  static const String _baseUrl = "https://s3-4684.nuage-peda.fr/forumFinal/api";
  String? _token;
  final SecureStorage _secureStorage = SecureStorage();

  /// Vérifie si l'utilisateur est connecté
  bool get isAuthenticated => _token != null;

  /// 🔹 Connexion utilisateur
  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$_baseUrl/authentication_token");
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("📡 Réponse API Connexion : ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token']; // Stocke le token
        await _secureStorage.saveToken(_token!);
        notifyListeners();
        return true; // ✅ Connexion réussie
      } else {
        print("⚠️ Échec de connexion : ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Erreur connexion : $e");
      return false;
    }
  }

  /// 🔹 Inscription utilisateur
  Future<bool> register(String firstName, String lastName, String email, String password) async {
    final url = Uri.parse("$_baseUrl/users");
    final headers = {
      'Accept': 'application/ld+json',
      'Content-Type': 'application/ld+json',
    };
    final body = jsonEncode({
      'prenom': firstName,
      'nom': lastName,
      'email': email,
      'password': password,
      'dateInscription': DateTime.now().toIso8601String(), // ✅ Ajoute la date actuelle
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("📡 Réponse API Inscription : ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Inscription réussie !");
        return true; // ✅ Succès
      } else {
        print("⚠️ Échec de l'inscription : ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Erreur Inscription : $e");
      return false;
    }
  }

  /// 🔹 Déconnexion de l'utilisateur
  Future<void> logout() async {
    _token = null;
    await _secureStorage.deleteCredentials();
    notifyListeners();
  }

  /// 🔹 Chargement du token au démarrage de l'application
  Future<void> loadToken() async {
    _token = await _secureStorage.readToken();
    notifyListeners();
  }
}
