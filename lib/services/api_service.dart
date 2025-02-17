import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  static const String baseUrl = "https://s3-4684.nuage-peda.fr/forumFinal/api/messages";

  Future<List<Message>> fetchMessages() async {
    try {
      final headers = {
        'Accept': 'application/ld+json', // ✅ Format accepté par API Platform
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
}
