import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'messages_screen.dart'; // ✅ Import du fichier correctement

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool isAuthenticated = authProvider.isAuthenticated;

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
