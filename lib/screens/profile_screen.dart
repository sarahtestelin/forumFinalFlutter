import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';  // Import du provider pour accéder aux infos de l'utilisateur

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;  // Récupère les infos utilisateur
    final userId = user?['id'];  // Récupère l'ID de l'utilisateur

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profil')),
        body: Center(child: Text('Utilisateur non trouvé')),
      );
    }

    // Récupération de l'email et de la date d'inscription
    final email = user?['email'] ?? 'Non disponible';
    final dateInscription = user?['dateInscription'] ?? 'Non disponible';

    return Scaffold(
      appBar: AppBar(title: Text('Profil de l\'utilisateur')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nom: ${user?['prenom']} ${user?['nom']}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("ID utilisateur: $userId", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Email: $email", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Date d'inscription: $dateInscription", style: TextStyle(fontSize: 16)),
            // Affiche d'autres informations que tu souhaites
          ],
        ),
      ),
    );
  }
}
