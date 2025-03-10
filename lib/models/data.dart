import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://localhost:8000/api';

class ApiService {
  // Méthode pour récupérer tous les utilisateurs
  static Future<List<Map<String, dynamic>>?> fetchAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/registers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((registers) => registers as Map<String, dynamic>).toList();
      } else {
        print('Erreur de réponse : ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs : $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl/registers/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(
            response.body); // Retourner les informations de l'utilisateur
      } else if (response.statusCode == 404) {
        return null; // L'utilisateur n'existe pas
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
  static Future<Map<String, dynamic>?> validateQRCode(String? code) async {
    if (code == null) return null;

    try {
      print('Envoi de la requête à : $apiUrl/validate-qr');
      print('Données envoyées : ${jsonEncode({'qrCode': code})}');

      final response = await http.post(
        Uri.parse('$apiUrl/validate-qr'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qrCode': code}), // Envoyer les données scannées
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retourner la réponse de l'API
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
}
