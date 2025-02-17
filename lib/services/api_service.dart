import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../utils/secure_storage.dart';

class ApiService {
  static const String baseUrl = "https://s3-4684.nuage-peda.fr/forumFinal/api/messages";
  final SecureStorage secureStorage = SecureStorage();

  /// 🔹 Récupérer tous les messages
  Future<List<Message>> fetchMessages() async {
    try {
      final headers = {
        'Accept': 'application/ld+json',
        'Content-Type': 'application/json',
      };

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      print("🔹 Status Code: ${response.statusCode}");
      print("🔹 Réponse brute: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey("member")) {
          List<dynamic> messagesJson = jsonResponse["member"];
          List<Message> messages = messagesJson.map((item) => Message.fromJson(item)).toList();

          print("✅ ${messages.length} messages récupérés !");
          return messages;
        } else {
          throw Exception("❌ Format inattendu : ${response.body}");
        }
      } else {
        throw Exception("⚠️ Erreur API (${response.statusCode})");
      }
    } catch (e) {
      print("❌ Exception: $e");
      throw Exception("Erreur réseau : ${e.toString()}");
    }
  }

  /// 🔹 Récupérer les réponses d'un message parent via `/api/messages/parent/{parentId}`
  Future<List<Message>> fetchReplies(int parentId) async {
    try {
      final headers = {
        'Accept': 'application/ld+json',
        'Content-Type': 'application/json',
      };

      final url = "$baseUrl/parent/$parentId"; // ✅ Utilisation correcte de la route
      final response = await http.get(Uri.parse(url), headers: headers);

      print("🔹 Réponses récupérées pour message ID $parentId : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((item) => Message.fromJson(item)).toList();
      } else {
        throw Exception("⚠️ Erreur API fetchReplies (${response.statusCode})");
      }
    } catch (e) {
      print("❌ Exception fetchReplies: $e");
      throw Exception("Erreur réseau : ${e.toString()}");
    }
  }

  /// 🔹 Envoyer un message ou une réponse
  Future<void> sendMessage(String message, {int? parentId}) async {
    try {
      String? userId = await secureStorage.readUserId();

      if (userId == null) {
        throw Exception("Utilisateur non connecté !");
      }

      final headers = {
        'Accept': 'application/ld+json',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "contenu": message,
        "userId": userId,
        if (parentId != null) "parent": "/forumFinal/api/messages/$parentId", // ✅ Correction du format de parentId
      });

      final response = await http.post(Uri.parse(baseUrl), headers: headers, body: body);

      print("🔹 Réponse API sendMessage : ${response.body}");

      if (response.statusCode != 201) {
        throw Exception("❌ Erreur lors de l'envoi du message (${response.statusCode})");
      }

      print("✅ Message envoyé avec succès !");
    } catch (e) {
      print("❌ Exception sendMessage: $e");
      throw Exception("Erreur réseau : ${e.toString()}");
    }
  }
}
