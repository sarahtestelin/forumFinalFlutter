import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/message.dart';


class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<List<Message>> futureMessages;
  bool isDescending = true; // par défaut tri du plus récent au plus ancien

  @override
  void initState() {
    super.initState();
    futureMessages = ApiService().fetchMessages();
  }

  /// Fonction pour trier la liste des messages
  List<Message> sortMessages(List<Message> messages) {
    messages.sort((a, b) => isDescending
        ? b.datePoste.compareTo(a.datePoste)  // Du plus récent au plus ancien
        : a.datePoste.compareTo(b.datePoste)  // Du plus ancien au plus récent
    );
    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
        backgroundColor: Colors.green,
        actions: [
          // menu déroulant pour choisir le tri
          DropdownButton<bool>(
            value: isDescending,
            icon: Icon(Icons.sort, color: Colors.white),
            dropdownColor: Colors.green[200],
            onChanged: (bool? newValue) {
              if (newValue != null) {
                setState(() {
                  isDescending = newValue;
                });
              }
            },
            items: [
              DropdownMenuItem(
                value: true,
                child: Text("Plus récent → Plus ancien"),
              ),
              DropdownMenuItem(
                value: false,
                child: Text("Plus ancien → Plus récent"),
              ),
            ],
          ),
        ],
      ),
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

          // appliquer le tri sur la liste des messages
          List<Message> messages = sortMessages(snapshot.data!);

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              Message message = messages[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    message.titre,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.contenu),
                      SizedBox(height: 5),
                      Text(
                        "Posté par ${message.author} - ${message.datePoste.toLocal()}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}