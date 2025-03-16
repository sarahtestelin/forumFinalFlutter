import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool isAuthenticated = authProvider.isAuthenticated;
    final user = authProvider.user; // permet de récupèrer les infos utilisateur

    return Scaffold(
      appBar: AppBar(
        title: Text("Forum"),
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
                "${user?['prenom']} ${user?['nom']}",
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
            Icon(Icons.forum, size: 100, color: Colors.indigoAccent),
            SizedBox(height: 20),

            // affiche "Bonjour + Prénom Nom" si l'utilisateur est connecté
            if (isAuthenticated)
              Text(
                "Bonjour, ${user?['prenom']} ${user?['nom']} 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
                textAlign: TextAlign.center,
              ),

            Text(
              "Bienvenue sur le forum !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Ton forum communautaire préféré !",
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
            SizedBox(height: 20),

            // bouton "Voir mon profil" si l'utilisateur est connecté
            if (isAuthenticated)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                child: Text("Voir mon profil", style: TextStyle(color: Colors.blue)),
              ),
            // si l'utilisateur n'est pas connecté ca affiche un bouton pour se connecter
            if (!isAuthenticated)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text("Se connecter pour accéder au profil", style: TextStyle(color: Colors.blue)),
              ),
          ],
        ),
      ),
    );
  }
}
