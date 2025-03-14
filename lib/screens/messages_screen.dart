import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/message.dart';
import '../providers/auth_provider.dart';
import 'message_detail_screen.dart'; // Import de la page de détails du message

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<List<Message>> futureMessages;
  bool isDescending = true;
  final TextEditingController titleController = TextEditingController();  // Titre du message
  final TextEditingController messageController = TextEditingController();  // Contenu du message

  @override
  void initState() {
    super.initState();
    futureMessages = ApiService().fetchMessages();  // Chargement initial des messages
  }

  List<Message> sortMessages(List<Message> messages) {
    messages.sort((a, b) => isDescending
        ? b.datePoste.compareTo(a.datePoste)
        : a.datePoste.compareTo(b.datePoste));
    return messages;
  }

  /// Envoie un message parent avec un titre
  void sendMessage(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez être connecté pour publier un message.")),
      );
      return;
    }

    String titleText = titleController.text.trim();
    String messageText = messageController.text.trim();

    if (titleText.isEmpty || messageText.isEmpty) return;

    try {
      // Envoie le message avec un titre et un contenu
      await ApiService().sendMessage(messageText, title: titleText); // Transmission du titre

      // Rafraîchir la liste des messages après l'envoi
      setState(() {
        futureMessages = ApiService().fetchMessages(); // Rafraîchissement de la liste des messages
      });

      // Nettoyage des champs de saisie
      titleController.clear();
      messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'envoi du message : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: Text("Messages")),
      body: Column(
        children: [
          // Affichage des messages
          Expanded(
            child: FutureBuilder<List<Message>>(
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
                          // Lorsque l'utilisateur clique sur un message,
                          // on le redirige vers la page de détails
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageDetailScreen(message: message),  // Passage du message sélectionné
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
          ),

          // Afficher le formulaire pour envoyer un message uniquement si l'utilisateur est connecté
          if (isAuthenticated) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Titre du message",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: "Votre message...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ),
            ElevatedButton(
              onPressed: () => sendMessage(context),
              child: Text("Envoyer un message"),
            ),
          ],

          // Afficher le bouton pour se connecter si l'utilisateur n'est pas connecté
          if (!isAuthenticated)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text("Se connecter pour poster"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),  // Largeur du bouton
                ),
              ),
            ),
        ],
      ),
    );
  }
}
