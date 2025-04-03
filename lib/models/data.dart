import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

const String apiUrl = 'http://10.0.2.2:8080/api';
// Pour iOS ou le test sur machine de développement
// const String apiUrl = 'http://localhost:8080/api';

class ApiService {
  final AuthService _authService = AuthService();

  // Méthode pour obtenir les headers avec le token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // Méthode pour récupérer tous les utilisateurs
  Future<List<Map<String, dynamic>>?> fetchAllUsers() async {
    try {
      final headers = await _getHeaders();
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

  Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/registers/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await _authService.logout();
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

  // Méthode pour valider les données scannées via l'API
  Future<Map<String, dynamic>?> validateQRCode(String? code) async {
    if (code == null) return null;

    try {
      final headers = await _getHeaders();
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
        await _authService.logout();
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
      final headers = await _getHeaders();
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
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/presence-history'),
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
}
