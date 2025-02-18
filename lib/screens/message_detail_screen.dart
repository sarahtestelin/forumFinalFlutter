import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class MessageDetailScreen extends StatefulWidget {
  final Message message;

  const MessageDetailScreen({Key? key, required this.message}) : super(key: key);

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  late Future<List<Message>> futureReplies;
  final TextEditingController replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureReplies = ApiService().fetchReplies(widget.message.id);
  }

  /// Envoie une réponse au message principal
  void sendReply(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez être connecté pour répondre.")),
      );
      return;
    }

    String replyText = replyController.text.trim();
    if (replyText.isEmpty) return;

    await ApiService().sendMessage(replyText, parentId: widget.message.id);

    // Rafraîchissement de la liste des réponses
    setState(() {
      futureReplies = ApiService().fetchReplies(widget.message.id);
    });

    replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text("Détails du message")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message.titre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(widget.message.contenu, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              "Posté par ${widget.message.author}",
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(),

            // Affichage des réponses
            Expanded(
              child: FutureBuilder<List<Message>>(
                future: futureReplies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Erreur : ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucune réponse"));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Message reply = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(reply.contenu),
                          subtitle: Text("Posté par ${reply.author}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Zone de réponse si l'utilisateur est connecté
            if (isAuthenticated)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text("Répondre au message :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyController,
                          decoration: const InputDecoration(
                            hintText: "Votre réponse...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => sendReply(context),
                      ),
                    ],
                  ),
                ],
              )
            else
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text("Se connecter pour répondre"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
