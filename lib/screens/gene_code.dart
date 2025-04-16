import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:digit_presence/services/api_service.dart';
import 'package:digit_presence/services/config.dart';

class GeneCode extends StatefulWidget {
  final ApiService apiService;
  const GeneCode({super.key, required this.apiService});

  @override
  State<GeneCode> createState() => GeneCodeState();
}

class GeneCodeState extends State<GeneCode> {
  String qrContent = '${ApiConfig.apiUrl}/scan';
  bool isLoading = true; // Indicateur de chargement

  String get getQrContent => qrContent;

  @override
  void initState() {
    super.initState();
    // Récupérer les données de la base de données via l'API
    fetchData();
  }

  // Méthode pour récupérer les données de l'API
  Future<void> fetchData() async {
    try {
      final response = await widget.apiService.fetchAllUsers();
      print('Réponse reçue : ${response?.toString()}'); // Vérifie ce qui est reçu

      if (response != null && response.isNotEmpty) {
        setState(() {
          // Ajoutez les données JSON comme paramètre de requête
          final jsonData = Uri.encodeComponent(jsonEncode(response));
          qrContent = '$qrContent?data=$jsonData'; // Ajoute les données JSON comme paramètre de requête
          isLoading = false;
        });
      } else {
        print('Données vides ou null.');
        setState(() {
          qrContent = '$qrContent?message=${Uri.encodeComponent('Aucune donnée reçue')}'; // Met un message par défaut
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur : $e');
      setState(() {
        qrContent = '$qrContent?message=${Uri.encodeComponent('Erreur lors de la récupération')}'; // Met un message d'erreur
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer un QR Code'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Affiche un indicateur de chargement
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: qrContent,
                    version: QrVersions.auto,
                    size: 200.0,
                    embeddedImage: const AssetImage('assets/dcolsay_img.jpg'),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(40, 40),
                    ),
                    errorStateBuilder: (cxt, err) {
                      return Container(
                        child: Center(
                          child: Text(
                            'Uh oh! Something went wrong...',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
