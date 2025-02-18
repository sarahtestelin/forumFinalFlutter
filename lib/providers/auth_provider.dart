import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class AuthProvider with ChangeNotifier {
  static const String _baseUrl = "https://s3-4684.nuage-peda.fr/forumFinal/api";
  String? _token;
  Map<String, dynamic>? _user;
  final SecureStorage _secureStorage = SecureStorage();

  /// ✅ Vérifie si l'utilisateur est connecté
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  /// 🔹 Connexion utilisateur
  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$_baseUrl/authentication_token");
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("📡 Réponse API Connexion : ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token'];

        final data = responseData['data'];
        final userId = data['id'];

        // Sauvegarde du token
        await _secureStorage.saveToken(_token!);

        // Sauvegarde du userId
        await _secureStorage.saveUserId(userId.toString());

        // Récupération des infos utilisateur après connexion
        await fetchUserProfile();

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
      'dateInscription': DateTime.now().toIso8601String(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("📡 Réponse API Inscription : ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Inscription réussie !");
        return true;
      } else {
        print("⚠️ Échec de l'inscription : ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Erreur Inscription : $e");
      return false;
    }
  }

  /// 🔹 Récupérer les informations utilisateur après connexion
  Future<void> fetchUserProfile() async {
    if (_token == null) return;

    final url = Uri.parse("$_baseUrl/me");
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _user = jsonDecode(response.body);
        print("👤 Profil utilisateur récupéré : $_user");

        // Sauvegarde des informations utilisateur localement
        await _secureStorage.saveUserInfo(_user!['nom'], _user!['prenom']);
      } else {
        print("⚠️ Impossible de récupérer le profil : ${response.body}");
      }
    } catch (e) {
      print("❌ Erreur récupération profil : $e");
    }

    notifyListeners();
  }

  /// 🔹 Déconnexion de l'utilisateur
  Future<void> logout() async {
    _token = null;
    _user = null;
    await _secureStorage.deleteCredentials();
    await _secureStorage.deleteUserInfo();
    notifyListeners();
  }

  /// 🔹 Chargement du token et du profil au démarrage de l'application
  Future<void> loadSession() async {
    _token = await _secureStorage.readToken();
    if (_token != null) {
      await fetchUserProfile();
    }
    notifyListeners();
  }
}
