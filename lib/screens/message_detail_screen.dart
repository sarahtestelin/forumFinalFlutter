import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MessageDetailScreen extends StatefulWidget {
  final Message message;

  MessageDetailScreen({required this.message});

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  late Future<List<Message>> futureReplies;
  TextEditingController replyController = TextEditingController();
  final AuthService authService = AuthService();
  String? userId;
  String? userName;

  @override
  void initState() {
    super.initState();
    futureReplies = ApiService().fetchReplies(widget.message.id);

    // Récupération de l'ID utilisateur et de son nom/prénom s'il est connecté
    authService.getUserInfo().then((userInfo) {
      print("🔍 Informations utilisateur récupérées : $userInfo");
      if (userInfo != null) {
        setState(() {
          userId = userInfo['id'];
          userName = "${userInfo['prenom']} ${userInfo['nom']}";
        });
      }
    });
  }

  void sendReply() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vous devez être connecté pour répondre.")),
      );
      return;
    }

    String replyText = replyController.text.trim();
    if (replyText.isEmpty) return;

    await ApiService().sendMessage(replyText, parentId: widget.message.id);
    setState(() {
      futureReplies = ApiService().fetchReplies(widget.message.id);
    });
    replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    print("🛠️ Vérification : userId = $userId, userName = $userName");
    return Scaffold(
      appBar: AppBar(title: Text("Détails du message")),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message.titre, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(widget.message.contenu, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Posté par ${widget.message.author}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            Divider(),

            Expanded(
              child: FutureBuilder<List<Message>>(
                future: futureReplies,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Erreur : ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Aucune réponse"));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Message reply = snapshot.data![index];
                      return ListTile(
                        title: Text(reply.contenu),
                        subtitle: Text("Posté par ${reply.author}"),
                      );
                    },
                  );
                },
              ),
            ),

            if (userId != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: replyController,
                        decoration: InputDecoration(hintText: "Répondre en tant que $userName..."),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: sendReply,
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "Veuillez vous connecter s'il vous plaît.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
