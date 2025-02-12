import 'package:flutter/material.dart';
import 'messages_screen.dart'; // ✅ Import de l'écran des messages

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forum"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "Bienvenue sur le forum !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Bienvenue sur mon application !",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageScreen()),
                );
              },
              child: Text("Voir les messages"),
            ),
          ],
        ),
      ),
    );
  }
}
