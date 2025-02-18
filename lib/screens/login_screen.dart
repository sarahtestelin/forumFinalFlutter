import 'package:flutter/material.dart';
import '../widgets/myscaffold.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      name: "Connexion",
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Bienvenue ! Connectez-vous pour accéder au forum.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              LoginForm(), // 📌 Le formulaire est maintenant dans un widget séparé
            ],
          ),
        ),
      ),
    );
  }
}
