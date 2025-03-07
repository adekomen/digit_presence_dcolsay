import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://localhost:8000/api';

class ApiService {
  // Méthode pour récupérer toutes les données de la base de données
  static Future<List<dynamic>?> fetchAllUsers() async {
    try {
      final response = await http.get(Uri.parse(
          '$apiUrl/registers')); // Endpoint pour récupérer tous les utilisateurs
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retourner les données décodées
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
      return null;
    }
  }

  // Méthode pour valider les données scannées via l'API
  static Future<Map<String, dynamic>?> validateQRCode(String? code) async {
    if (code == null) return null;

    try {
      final response = await http.post(
        Uri.parse(
            '$apiUrl/registers'), // Endpoint pour valider le QR code
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': code}), // Envoyer les données scannées
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retourner la réponse de l'API
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la validation : $e');
      return null;
    }
  }
}
