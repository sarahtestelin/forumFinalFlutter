import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'messages_screen.dart'; // ✅ Import correct

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool isAuthenticated = authProvider.isAuthenticated;
    final user = authProvider.user; // Récupère les infos utilisateur

    return Scaffold(
      appBar: AppBar(
        title: Text("Forum"),
        backgroundColor: Colors.green,
        actions: [
          if (!isAuthenticated) ...[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Se connecter", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text("S'inscrire", style: TextStyle(color: Colors.white)),
            ),
          ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Bonjour, ${user?['prenom']} ${user?['nom']} 👋",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                authProvider.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Déconnecté avec succès")),
                );
              },
              child: Text("Se déconnecter", style: TextStyle(color: Colors.white)),
            ),
          ]
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum, size: 100, color: Colors.green),
            SizedBox(height: 20),

            // ✅ Affiche "Bonjour + Prénom Nom" si l'utilisateur est connecté
            if (isAuthenticated)
              Text(
                "Bonjour, ${user?['prenom']} ${user?['nom']} 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),

            Text(
              "Bienvenue sur le forum !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Discutez et échangez avec d'autres membres.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageScreen()), // ✅ Utilisation correcte
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
