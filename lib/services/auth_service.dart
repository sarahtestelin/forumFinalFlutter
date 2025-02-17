import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class AuthService {
  static const String baseUrl = "https://s3-4684.nuage-peda.fr/forumFinal/api";

  final SecureStorage secureStorage = SecureStorage();

  /// 🔐 Connexion de l'utilisateur
  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/authentication_token");
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final response = await http.post(url, headers: headers, body: body);
    print("🔹 Réponse API : ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // ✅ Sauvegarde du token et de l'ID utilisateur
      await secureStorage.saveCredentials(email, password);
      await secureStorage.saveToken(responseData['token']);
      String? savedToken = await secureStorage.readToken();
      print("🟢 Token après stockage : $savedToken");

      if (responseData.containsKey('data') && responseData['data'].containsKey('id')) {
        String userId = responseData['data']['id'].toString();
        await secureStorage.saveUserId(userId);
        String? savedUserId = await secureStorage.readUserId();
        print("🟢 ID utilisateur après stockage : $savedUserId");
        print("✅ Connexion réussie - ID utilisateur enregistré : $userId");
      } else {
        print("⚠️ Erreur : Impossible de récupérer l'ID utilisateur.");
        throw Exception("Échec de récupération de l'ID utilisateur");
      }

      return true; // Connexion réussie
    } else {
      throw Exception("Échec de connexion : ${response.body}");
    }
  }

  /// 🔐 Récupérer les informations de l'utilisateur connecté
  Future<Map<String, String>?> getUserInfo() async {
    String? token = await secureStorage.readToken();
    print("🔑 Token stocké récupéré : $token");

    if (token == null) return null;

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    print("📡 Envoi de la requête GET à $baseUrl/me avec headers : {'Authorization': 'Bearer $token'}");
    final response = await http.get(Uri.parse("$baseUrl/me"), headers: headers);
    print("📡 Réponse API user info : Code ${response.statusCode}, Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Utilisateur récupéré : ID ${data["id"]}, Nom ${data["nom"]}, Prénom ${data["prenom"]}");
      return {
        "id": data["id"].toString(),
        "prenom": data["prenom"] ?? "",
        "nom": data["nom"] ?? ""
      };
    } else {
      print("⚠️ Erreur récupération user info : ${response.body}");
      return null;
    }
  }

  /// 🔐 Récupérer l'ID utilisateur stocké
  Future<String?> getUserId() async {
    String? userId = await secureStorage.readUserId();
    print("🧐 ID utilisateur stocké : $userId");
    return userId;
  }

  /// 🔐 Vérifier si un ID utilisateur est stocké
  Future<void> checkStoredUserId() async {
    String? userId = await secureStorage.readUserId();
    if (userId != null) {
      print("🧐 ID utilisateur récupéré : $userId");
    } else {
      print("⚠️ Aucun ID utilisateur trouvé.");
    }
  }

  /// 🔐 Déconnexion : supprime les infos stockées
  Future<void> logout() async {
    await secureStorage.deleteCredentials();
    await secureStorage.deleteUserId();
    print("👋 Déconnexion réussie - Données supprimées.");
  }
}
