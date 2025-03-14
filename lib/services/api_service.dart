import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../utils/secure_storage.dart';

class ApiService {
  static const String baseUrl = "https://s3-4684.nuage-peda.fr/forumFinal/api/messages";
  final SecureStorage secureStorage = SecureStorage();

  /// Récupérer uniquement les messages sans parent_id (pour MessageScreen)
  Future<List<Message>> fetchMessages() async {
    try {
      final headers = {
        'Accept': 'application/ld+json',
        'Content-Type': 'application/json',
      };

      List<Message> allMessages = [];
      String url = baseUrl; // URL de base pour récupérer les messages

      bool hasNextPage = true;
      while (hasNextPage) {
        final response = await http.get(Uri.parse(url), headers: headers);

        print("🔹 Status Code: ${response.statusCode}");
        print("🔹 Réponse brute: ${response.body}");

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);

          if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey("member")) {
            List<dynamic> messagesJson = jsonResponse["member"];
            // Filtrer les messages sans parent_id
            List<Message> messages = messagesJson
                .where((item) => item['parent'] == null)  // Filtrer les messages sans parent_id
                .map((item) => Message.fromJson(item))
                .toList();

            // Ajouter les messages récupérés à la liste
            allMessages.addAll(messages);

            // Vérifier s'il y a une page suivante (avec le champ 'next')
            String? nextPage = jsonResponse["view"]?["next"];
            if (nextPage != null) {
              // Compléter l'URL de la page suivante avec le baseUrl
              url = "https://s3-4684.nuage-peda.fr" + nextPage;  // Ajouter la base de l'URL
            } else {
              hasNextPage = false;  // Aucune page suivante, fin de la récupération
            }
          } else {
            throw Exception("❌ Format inattendu : ${response.body}");
          }
        } else {
          throw Exception("⚠️ Erreur API (${response.statusCode})");
        }
      }

      print("✅ ${allMessages.length} messages récupérés !");
      return allMessages;
    } catch (e) {
      print("❌ Exception: $e");
      throw Exception("Erreur réseau : ${e.toString()}");
    }
  }


  /// Récupérer les réponses d'un message parent avec parent_id (pour MessageDetailScreen)
  Future<List<Message>> fetchReplies(int parentId) async {
    try {
      final headers = {
        'Accept': 'application/ld+json',
        'Content-Type': 'application/json',
      };

      // URL pour récupérer les réponses d'un message parent spécifique
      final url = "$baseUrl/parent/$parentId";  // Exemple d'URL à ajuster selon ton API
      final response = await http.get(Uri.parse(url), headers: headers);

      print("🔹 Réponses récupérées pour message ID $parentId : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Message> replies = jsonResponse.map((item) => Message.fromJson(item)).toList();
        return replies;
      } else {
        throw Exception("⚠️ Erreur API fetchReplies (${response.statusCode})");
      }
    } catch (e) {
      print("❌ Exception fetchReplies: $e");
      throw Exception("Erreur réseau : ${e.toString()}");
    }
  }

  /// Envoi d'un message (parent ou réponse)
  Future<void> sendMessage(String message, {String? title, int? parentId}) async {
    try {
      String? token = await secureStorage.readToken();
      if (token == null) throw Exception("Utilisateur non authentifié.");

      String? userId = await secureStorage.readUserId();
      if (userId == null) throw Exception("Utilisateur non connecté !");

      final headers = {
        'Accept': 'application/ld+json',
        'Content-Type': 'application/ld+json',
        'Authorization': 'Bearer $token',
      };

      String userUri = "/forumFinal/api/users/$userId";
      String? parentUri = parentId != null ? "/forumFinal/api/messages/$parentId" : null;

      final body = jsonEncode({
        "titre": title ?? "Sans titre",  // Utilisation du titre fourni ou "Sans titre"
        "datePoste": DateTime.now().toIso8601String(),
        "contenu": message,
        "user": userUri,
        if (parentUri != null) "parent": parentUri,
      });

      final response = await http.post(Uri.parse(baseUrl), headers: headers, body: body);

      if (response.statusCode != 201) {
        throw Exception("Erreur lors de l'envoi du message (${response.statusCode}) : ${response.body}");
      }

      print("✅ Message envoyé avec succès !");
    } catch (e) {
      print("❌ Exception sendMessage: $e");
      throw Exception("Erreur réseau : ${e.toString()}");
    }
  }
}
