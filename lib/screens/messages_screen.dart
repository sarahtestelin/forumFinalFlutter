import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/message.dart';
import 'message_detail_screen.dart';
import '../providers/auth_provider.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<List<Message>> futureMessages;
  bool isDescending = true;

  @override
  void initState() {
    super.initState();
    futureMessages = ApiService().fetchMessages();
  }

  List<Message> sortMessages(List<Message> messages) {
    messages.sort((a, b) => isDescending
        ? b.datePoste.compareTo(a.datePoste)
        : a.datePoste.compareTo(b.datePoste));
    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messages")),
      body: FutureBuilder<List<Message>>(
        future: futureMessages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun message disponible"));
          }

          List<Message> messages = sortMessages(snapshot.data!);

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              Message message = messages[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageDetailScreen(
                          message: message, // ✅ Supprimé `token`
                        ),
                      ),
                    );
                  },
                  title: Text(message.titre, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(message.contenu),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
