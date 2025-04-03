import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Configuration de l'URL de base
  // Utiliser la variable d'environnement ou un paramètre pour définir dynamiquement
  static const String apiUrl = 'http://api.dcolsay.local/api';
  // Alternatives pour différents environnements:
  // static const String apiUrl = 'http://10.0.2.2:8080/api';  // Pour Android Emulator
  // static const String apiUrl = 'http://localhost:8080/api'; // Pour iOS ou tests sur machine dev

  // Headers par défaut pour les requêtes API
  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Headers avec authentification
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getAuthToken();
    final headers = _headers();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ===== AUTHENTIFICATION =====

  // Récupérer le token d'authentification
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Enregistrer le token d'authentification
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Effacer le token d'authentification (déconnexion)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Méthode de connexion
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: _headers(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Sauvegarder le token
        final token = responseData['data']['token'];
        await saveAuthToken(token);
      }

      return responseData;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Méthode d'inscription
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/register'),
        headers: _headers(),
        body: json.encode(userData),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // ===== UTILISATEURS =====

  // Récupérer les données de l'utilisateur connecté
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/auth/user'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Token expiré ou invalide
        await logout();
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

  // Méthode pour récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>?> fetchAllUsers() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/registers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((registers) => registers as Map<String, dynamic>)
            .toList();
      } else if (response.statusCode == 401) {
        // Token expiré ou invalide
        await logout();
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

  // Récupérer un utilisateur par ID
  Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/registers/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout();
        return null;
      } else {
        print('Erreur de réponse : ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
      return null;
    }
  }

  // ===== GESTION DES PRÉSENCES =====

  // Vérifier la validité d'un QR code avec le serveur
  Future<Map<String, dynamic>> verifyQrCode(Map<String, dynamic> qrData) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiUrl/presence/verify'),
        headers: headers,
        body: json.encode({
          'qr_data': qrData,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Méthode pour valider les données scannées via l'API
  Future<Map<String, dynamic>?> validateQRCode(String? code) async {
    if (code == null) return null;

    try {
      final headers = await _getAuthHeaders();
      print('Envoi de la requête à : $apiUrl/validate-qr');
      print('Données envoyées : ${jsonEncode({'qrCode': code})}');

      final response = await http.post(
        Uri.parse('$apiUrl/validate-qr'),
        headers: headers,
        body: jsonEncode({'qrCode': code}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout();
        return null;
      } else {
        print('Erreur de réponse : ${response.statusCode}');
        print('Réponse du serveur : ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la validation : $e');
      return null;
    }
  }

  // Méthode pour enregistrer une présence
  Future<bool> recordPresence(String qrCode) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiUrl/record-presence'),
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

  // Méthode pour récupérer l'historique des présences
  Future<List<Map<String, dynamic>>?> fetchPresenceHistory() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/presence-history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        await logout();
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

  // ===== RÉINITIALISATION DE MOT DE PASSE =====

  // Demander un code OTP pour réinitialisation de mot de passe
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/password/email'),
        headers: _headers(),
        body: json.encode({
          'email': email,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Vérifier un code OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/password/verify'),
        headers: _headers(),
        body: json.encode({
          'email': email,
          'token': otp,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Réinitialiser le mot de passe
  Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/password/reset'),
        headers: _headers(),
        body: json.encode({
          'email': email,
          'token': otp,
          'password': password,
          'password_confirmation': password,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }
}
