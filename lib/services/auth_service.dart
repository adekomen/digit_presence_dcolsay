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
  static const String _otpKey = 'otp';

  // En-têtes de base pour les requêtes
  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("Tentative de connexion avec email: $email");
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/admin/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email_utilisateur': email,
          'mot_de_passe_utilisateur': password,
        }),
      );

      print("Code de statut: ${response.statusCode}");
      final data = jsonDecode(response.body);
      print("Réponse API: $data");

      if (response.statusCode == 200 && data['token'] != null) {
        print("Token reçu, sauvegarde en cours...");
        await _saveToken(data['token']);

        // Vérifier si les données utilisateur sont présentes
        if (data['admin'] != null) {
          print("Données utilisateur reçues: ${data['admin']}");
          try {
            _currentUser = User.fromJson(data['admin']);
            print(
                "Utilisateur créé: ${_currentUser?.firstname} ${_currentUser?.lastname}");
            await _saveUserData(_currentUser!);
            print("Données utilisateur sauvegardées dans SharedPreferences");
          } catch (e) {
            print("ERREUR lors de la création de l'utilisateur: $e");
          }
        } else {
          print("Aucune donnée utilisateur dans la réponse");
        }

        return {
          'success': true,
          'message': 'Connexion réussie',
          'data': data,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Email ou mot de passe incorrect',
        'status': response.statusCode,
        'response': data,
      };
    } catch (e) {
      print("Exception lors de la connexion: $e");
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Demander un code OTP
  Future<bool> requestOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/request-otp'),
        headers: _headers(),
        body: jsonEncode({'email': email}),
      );
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');print('STATUS CODE: ${response.statusCode}');
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la demande OTP: $e');
      return false;
    }
  }

  // Vérifier et valider le OTP
Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/verify-otp'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['token'] != null) {
        await _saveToken(data['token']);
        if (data['user'] != null) {
          _currentUser = User.fromJson(data['user']);
          await _saveUserData(_currentUser!);
        }
        return {
          'success': true,
          'message': 'OTP vérifié avec succès',
          'data': data
        };
      }
    }

    return {
      'success': false,
      'message': 'OTP incorrect ou expiré',
      'status': response.statusCode,
      'response': response.body
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Erreur de connexion au serveur lors de la vérification du OTP: $e',
    };
  }
}


  // Sauvegarder le token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Sauvegarder les données utilisateur
  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode(user.toJson());
      print("Sauvegarde des données utilisateur: $userData");
      await prefs.setString(_userDataKey, userData);
      print("Données utilisateur sauvegardées avec succès");
    } catch (e) {
      print("Erreur lors de la sauvegarde des données utilisateur: $e");
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      print("Token récupéré: ${token != null ? 'Oui' : 'Non'}");

      if (token == null) {
        print("Pas de token, utilisateur non connecté");
        return false;
      }

      final userData = await _getUserData();
      print(
          "Données utilisateur récupérées: ${userData != null ? 'Oui' : 'Non'}");

      if (userData != null) {
        _currentUser = userData;
        print(
            "Utilisateur chargé: ${_currentUser?.firstname} ${_currentUser?.lastname}");
        return true;
      } else {
        print("Données utilisateur non trouvées dans SharedPreferences");
        return false;
      }
    } catch (e) {
      print("Erreur lors de la vérification de connexion: $e");
      return false;
    }
  }

  // Récupérer le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Récupérer les données utilisateur
  Future<User?> _getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userDataKey);

      if (userData != null) {
        print("Données utilisateur brutes trouvées: $userData");
        try {
          final user = User.fromJson(jsonDecode(userData));
          print(
              "Utilisateur décodé avec succès: ${user.firstname} ${user.lastname}");
          return user;
        } catch (e) {
          print("ERREUR lors du décodage des données utilisateur: $e");
          // Essai de débogage
          final Map<String, dynamic> jsonData = jsonDecode(userData);
          print("Clés disponibles: ${jsonData.keys.toList()}");
          return null;
        }
      }
      print("Aucune donnée utilisateur stockée");
      return null;
    } catch (e) {
      print("Exception dans _getUserData: $e");
      return null;
    }
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
  //reset password
  Future<Map<String, dynamic>> resetPassword(String email, {required /*String email*/, required String newPassword}) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/reset-password'),
      headers: _headers(),
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': 'Réinitialisation du mot de passe réussie',
      };
    }

    return {
      'success': false,
      'message': 'Erreur lors de la réinitialisation du mot de passe',
      'status': response.statusCode,
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Erreur de connexion au serveur lors de la réinitialisation du mot de passe: $e',
    };
  }
}

}


// Connexion utilisateur avec OTP
 /* Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/admin/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Si la réponse demande l'OTP, on initie l'envoi de l'OTP
        if (data['otp_required'] == true) {
          return {
            'success': false,
            'message': 'OTP requis. Vérifiez votre email ou téléphone.',
            'otp_required': true
          };
        }

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
  }*/
