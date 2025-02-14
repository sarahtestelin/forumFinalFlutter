import 'package:flutter/material.dart';
import 'messages_screen.dart'; // ✅ Import de l'écran des messages
import 'authentification_choix.dart'; // ✅ Import de l'écran d'authentification

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forum"),
        backgroundColor: Colors.green,
        actions: [
          // ✅ Bouton en haut à droite pour se connecter / s'inscrire
          IconButton(
            icon: Icon(Icons.person),
            tooltip: "Se connecter / S'inscrire",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthentificationChoix()),
              );
            },
          ),
        ],
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
            // ✅ Bouton pour voir les messages
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageScreen()),
                );
              },
              child: Text("Voir les messages"),
            ),
            SizedBox(height: 10),
            // ✅ Bouton pour se connecter / s'inscrire dans le corps de la page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthentificationChoix()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Couleur différente pour le distinguer
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("Se connecter / S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
