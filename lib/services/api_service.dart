import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  // ✅ URL de l'API en ligne
  static const String baseUrl = "https://s3-4684.nuage-peda.fr/forumFinal/api/messages";

  /// Fonction pour récupérer tous les messages depuis l'API
  Future<List<Message>> fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // ✅ Vérifie si l'API retourne "member" au lieu de "hydra:member"
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey("member")) {
          List<dynamic> messagesJson = jsonResponse["member"];
          return messagesJson.map((item) => Message.fromJson(item)).toList();
        } else {
          throw Exception("Format de réponse inattendu : ${response.body}");
        }
      } else {
        throw Exception("Échec du chargement des messages (Code ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Erreur réseau : ${e.toString()}");
    }
  }
}
