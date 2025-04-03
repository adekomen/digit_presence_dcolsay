import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../services/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  String qrData = ''; // Données à encoder dans le QR code
  bool isLoading = true; // Indicateur de chargement
  Map<String, dynamic> currentUser = {};
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Récupérer les données de l'utilisateur actuel depuis l'API
    fetchCurrentUser();
  }

  // Méthode pour récupérer l'utilisateur actuel via l'API Docker
  Future<void> fetchCurrentUser() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Récupérer le token depuis le stockage local
      final authToken = await _apiService.getAuthToken();

      if (authToken == null || authToken.isEmpty) {
        setState(() {
          qrData = json.encode({"error": "Utilisateur non connecté"});
          isLoading = false;
        });
        return;
      }

      // Appel à l'API Docker pour récupérer les données utilisateur
      final response = await _apiService.getCurrentUser();

      if (response['success']) {
        final user = response['data'];
        setState(() {
          currentUser = user;

          // Générer une signature unique pour notre application
          final appSignature = 'DigiPresence_${user['id']}';

          // Créer les données du QR code avec la signature
          final qrCodeData = {
            'app_signature': appSignature,
            'user_id': user['id'],
            'email': user['email'],
            'name': user['name'],
            'lastname': user['lastname'],
            'timestamp': DateTime.now().toIso8601String(),
          };

          // Ajouter un hash de sécurité pour vérification
          final dataToHash = qrCodeData.toString();
          final hash = sha256.convert(utf8.encode(dataToHash)).toString();
          qrCodeData['hash'] = hash;

          qrData = json.encode(qrCodeData);
          isLoading = false;
        });
      } else {
        setState(() {
          qrData = json.encode({
            "error":
                "Erreur: ${response['message'] ?? 'Impossible de récupérer les données utilisateur'}"
          });
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur API : $e');
      setState(() {
        qrData =
            json.encode({"error": "Erreur lors de la connexion au serveur"});
        isLoading = false;
      });
    }
  }

  // Méthode pour rafraîchir manuellement le QR code
  Future<void> refreshQRCode() async {
    await fetchCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : refreshQRCode,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Affiche un indicateur pendant le chargement
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bonjour ${currentUser['name'] ?? ''}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'QR Code DCOLSAY',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 30),
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 250.0,
                    embeddedImage: const AssetImage('assets/dcolsay_img.jpg'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(40, 40),
                    ),
                    errorStateBuilder: (cxt, err) {
                      return Container(
                        child: const Center(
                          child: Text(
                            'Une erreur est survenue lors de la génération du QR Code',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Date de validité: ${DateTime.now().add(const Duration(hours: 24)).toString().substring(0, 16)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
      ),
    );
  }
}
