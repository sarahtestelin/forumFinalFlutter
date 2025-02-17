import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // 🔹 Configuration sécurisée (désactive la sauvegarde en clair sur Android)
  static const _secureOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock, // Sécurise l'accès
  );

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true, // Active l'encryption sur Android
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 🔑 Clés de stockage
  static const String _keyEmail = 'email';
  static const String _keyPassword = 'password';
  static const String _keyToken = 'token';

  /// 🔹 Sauvegarde des identifiants
  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email, iOptions: _secureOptions, aOptions: _androidOptions);
    await _storage.write(key: _keyPassword, value: password, iOptions: _secureOptions, aOptions: _androidOptions);
  }

  /// 🔹 Sauvegarde du token JWT
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token, iOptions: _secureOptions, aOptions: _androidOptions);
  }

  /// 🔹 Récupération des identifiants
  Future<Map<String, String?>> readCredentials() async {
    String? email = await _storage.read(key: _keyEmail, iOptions: _secureOptions, aOptions: _androidOptions);
    String? password = await _storage.read(key: _keyPassword, iOptions: _secureOptions, aOptions: _androidOptions);
    return {'email': email, 'password': password};
  }

  /// 🔹 Récupération du token JWT
  Future<String?> readToken() async {
    return await _storage.read(key: _keyToken, iOptions: _secureOptions, aOptions: _androidOptions);
  }

  /// 🔹 Suppression des identifiants et du token
  Future<void> deleteCredentials() async {
    await _storage.delete(key: _keyEmail, iOptions: _secureOptions, aOptions: _androidOptions);
    await _storage.delete(key: _keyPassword, iOptions: _secureOptions, aOptions: _androidOptions);
    await _storage.delete(key: _keyToken, iOptions: _secureOptions, aOptions: _androidOptions);
  }

  // 🔑 Clé pour l'ID utilisateur
  static const String _keyUserId = 'user_id';

  /// 🔹 Sauvegarde de l'ID utilisateur
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId, iOptions: _secureOptions, aOptions: _androidOptions);
  }

  /// 🔹 Récupération de l'ID utilisateur
  Future<String?> readUserId() async {
    return await _storage.read(key: _keyUserId, iOptions: _secureOptions, aOptions: _androidOptions);
  }

  /// 🔹 Suppression de l'ID utilisateur (déconnexion)
  Future<void> deleteUserId() async {
    await _storage.delete(key: _keyUserId, iOptions: _secureOptions, aOptions: _androidOptions);
  }

}