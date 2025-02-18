import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

class MyScaffold extends StatelessWidget {
  final Widget body;
  final String name;

  const MyScaffold({required this.body, required this.name});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoggedIn = authProvider.isAuthenticated;
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: TextStyle(color: Colors.white)),
        actions: [
          if (isLoggedIn) ...[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  Text(
                    "${user?['prenom']} ${user?['nom']}",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      authProvider.logout();
                      Navigator.pushNamed(context, '/home'); // ✅ Reste sur Home après déconnexion
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.login, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // ✅ Permet d'accéder à LoginScreen
                );
              },
            ),
          ],
        ],
      ),
      body: body,
    );
  }
}
