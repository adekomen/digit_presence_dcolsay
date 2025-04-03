import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

class User {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String role;
  final String qrCode;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.role,
    required this.qrCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['utilisateur_id'],
      firstname: json['prenom_utilisateur'],
      lastname: json['nom_utilisateur'],
      email: json['email_utilisateur'],
      phone: json['telephone_utilisateur'] ?? '',
      role: json['role_nom'] ?? 'User',
      qrCode: json['qr_code_utilisateur'],
    );
  }
}

class AuthService {
  // Stocker l'utilisateur actuel
  User? _currentUser;

  // Getter pour l'utilisateur
  User? get currentUser => _currentUser;

  // Méthode de connexion
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Enregistrer le token et les infos utilisateur dans les préférences partagées
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);

          if (data['user'] != null) {
            await prefs.setString('user_data', jsonEncode(data['user']));
            _currentUser = User.fromJson(data['user']);
          }
        }

        return data;
      } else {
        print('Erreur de connexion: ${response.statusCode}');
        print('Réponse: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la connexion: $e');
      return null;
    }
  }

  // Méthode pour vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');

    if (token != null && userData != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userData));
        return true;
      } catch (e) {
        print('Erreur lors du chargement des données utilisateur: $e');
        return false;
      }
    }
    return false;
  }

  // Méthode de déconnexion
  Future<void> logout() async {
    try {
      final token = await getToken();

      if (token != null) {
        // Appel à l'API pour invalider le token
        await http.post(
          Uri.parse('$apiUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    } finally {
      // Supprimer les données locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      _currentUser = null;
    }
  }

  // Méthode pour obtenir le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Méthode pour demander un code OTP
  Future<bool> requestOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/request-otp'),
        headers: {'Content-Type': 'application/json'},
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

  // Méthode pour vérifier un code OTP
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
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

  // Méthode pour réinitialiser le mot de passe
  Future<bool> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
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
