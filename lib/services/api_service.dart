import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:digit_presence/services/auth_service.dart';
import 'package:digit_presence/services/config.dart';
import 'package:intl/intl.dart';


class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

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
  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  // En-têtes de base
  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ===== VALIDATION DU QR CODE =====

  Future<Map<String, dynamic>?> validateQRCode(String? code) async {
    if (code == null) {
      print('❌ Code QR nul');
      return {'success': false, 'message': 'Code QR invalide'};
    }

    print('📷 QR code scanné : $code');

    try {
      final headers = await _getAuthHeaders();
      print('📨 Headers envoyés : $headers');

      if (!headers.containsKey('Authorization')) {
        print('❌ Pas de token');
        return {'success': false, 'message': 'Utilisateur non authentifié'};
      }

      // Encapsulate the code in a JSON object with the expected format
      Map<String, dynamic> qrData;
      try {
        qrData = json.decode(code);
      } catch (e) {
        // Format the plain text as expected by the backend
        String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        qrData = {"qrCode": "$code|$formattedDate"};
      }

      final body = jsonEncode(qrData);
      print('📤 Corps envoyé : $body');

      final url = Uri.parse('${ApiConfig.apiUrl}/presences');
      print('🌐 URL de requête : $url');

      final response = await http.post(url, headers: headers, body: body);
      print('✅ Code HTTP : ${response.statusCode}');
      print('🧾 Réponse serveur : ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await _authService.logout();
        return {'success': false, 'message': 'Session expirée'};
      } else {
        return {'success': false, 'message': 'Erreur serveur'};
      }
    } catch (e) {
      print('💥 Erreur lors de la validation : $e');
      return {'success': false, 'message': 'Erreur de réseau'};
    }
  }




  // ===== UTILISATEUR =====

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

  // Récupérer tous les utilisateurs (si nécessaire ailleurs)
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

  // ===== HISTORIQUE DES PRÉSENCES =====

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

  // Méthode vide réservée à un futur enregistrement utilisateur
  register(Map<String, dynamic> userData) {}
}
