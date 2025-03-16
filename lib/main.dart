import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/authentification_choix.dart';
import 'screens/message_detail_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..loadSession(), // charge le token et le profil utilisateur
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forum',
      theme: ThemeData(
        // Thème principal bleu pour l'ensemble de l'application
        primaryColor: Colors.blue,  // Couleur principale de l'AppBar
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),  // Utilisation de bleu comme base
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,  // AppBar en bleu
        ),
        useMaterial3: true,  // Activer Material 3
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
