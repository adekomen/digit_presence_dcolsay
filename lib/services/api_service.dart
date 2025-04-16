import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:digit_presence/services/auth_service.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:digit_presence/services/config.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Instance du service d'authentification
  final AuthService _authService = AuthService();
  
  // Méthode pour obtenir les en-têtes avec authentification
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    final headers = _headers();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Méthode pour valider un QR code
  Future<Map<String, dynamic>?> validateQRCode(String? code) async {
    if (code == null) {
      return {'success': false, 'message': 'Code QR invalide'};
    }

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        return {'success': false, 'message': 'Utilisateur non authentifié'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/validate-qr'),
        headers: headers,
        body: jsonEncode({'qrCode': code}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {'success': false, 'message': 'Session expirée'};
      } else {
        print('Erreur de réponse : ${response.statusCode}');
        print('Réponse du serveur : ${response.body}');
        return {'success': false, 'message': 'Erreur serveur'};
      }
    } catch (e) {
      print('Erreur lors de la validation : $e');
      return {'success': false, 'message': 'Erreur de réseau'};
    }
  }

  //méthode pour obtenir les en-têtes de base
  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }


  // ===== UTILISATEURS =====

  // Récupérer les données de l'utilisateur connecté
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/user'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        // Token expiré ou invalide
        await _authService.logout();
        return {
          'success': false,
          'message': 'Session expirée, veuillez vous reconnecter',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des données utilisateur',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Récupérer tous les utilisateurs
  Future<List<User>?> fetchAllUsers() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((userData) => User.fromJson(userData)).toList();
      } else if (response.statusCode == 401) {
        // Token expiré ou invalide
        await _authService.logout();
        return null;
      } else {
        print('Erreur de réponse : ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs : $e');
      return null;
    }
  }

  // ===== GESTION DES PRÉSENCES =====

  // Enregistrer une présence
  Future<bool> recordPresence(String qrCode) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/record-presence'),
        headers: headers,
        body: jsonEncode({
          'qrCode': qrCode,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la présence: $e');
      return false;
    }
  }

  // Récupérer l'historique des présences
  Future<List<Map<String, dynamic>>?> fetchPresenceHistory() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/presence-history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return null;
      } else {
        print('Erreur de réponse : ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique : $e');
      return null;
    }
  }

  register(Map<String, dynamic> userData) {}
}
