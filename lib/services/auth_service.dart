import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'config.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Utilisateur actuel
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Clés pour SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  // En-têtes de base pour les requêtes
  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // En-têtes avec authentication
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    final headers = _headers();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Connexion utilisateur
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/login'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Si la structure de réponse contient un token
        if (data['token'] != null) {
          await _saveToken(data['token']);

          // Sauvegarde des données utilisateur si disponibles
          if (data['user'] != null) {
            _currentUser = User.fromJson(data['user']);
            await _saveUserData(_currentUser!);
          }

          return {
            'success': true,
            'message': 'Connexion réussie',
            'data': data
          };
        }
      }

      // En cas d'échec
      return {
        'success': false,
        'message': 'Email ou mot de passe incorrect',
        'status': response.statusCode,
        'response': response.body
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userData = await _getUserData();

    if (token != null && userData != null) {
      try {
        _currentUser = userData;
        return true;
      } catch (e) {
        print('Erreur lors du chargement des données utilisateur: $e');
        return false;
      }
    }
    return false;
  }

  // Déconnexion
  Future<bool> logout() async {
    try {
      final token = await getToken();

      if (token != null) {
        // Appel API pour invalider le token (côté serveur)
        try {
          await http.post(
            Uri.parse('${ApiConfig.apiUrl}/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        } catch (e) {
          print('Erreur lors de la déconnexion sur le serveur: $e');
          // On continue pour supprimer les données locales même si l'API échoue
        }
      }

      // Suppression des données locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
      _currentUser = null;

      return true;
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      return false;
    }
  }

  // Récupérer le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Sauvegarder le token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Sauvegarder les données utilisateur
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
  }

  // Récupérer les données utilisateur
  Future<User?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userDataKey);

    if (userData != null) {
      try {
        return User.fromJson(jsonDecode(userData));
      } catch (e) {
        print('Erreur lors du décodage des données utilisateur: $e');
        return null;
      }
    }
    return null;
  }

  // Demander un code OTP pour réinitialisation
  Future<bool> requestOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/request-otp'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la demande d\'OTP: $e');
      return false;
    }
  }

  // Vérifier un code OTP
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/verify-otp'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la vérification de l\'OTP: $e');
      return false;
    }
  }

  // Réinitialiser le mot de passe
  Future<bool> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/reset-password'),
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la réinitialisation du mot de passe: $e');
      return false;
    }
  }
}
