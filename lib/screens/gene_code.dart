import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../models/data.dart';


class GeneCode extends StatefulWidget {
  final ApiService apiService;
  const GeneCode({super.key, required this.apiService});

  @override
  State<GeneCode> createState() => GeneCodeState();
}

class GeneCodeState extends State<GeneCode> {
  String jsonData = ''; // Données JSON à encoder dans le QR code
  bool isLoading = true; // Indicateur de chargement

  String get getJsonData => jsonData;

  @override
  void initState() {
    super.initState();
    // Récupérer les données de la base de données via l'API
    fetchData();
  }

  // Méthode pour récupérer les données de l'API
  Future<void> fetchData() async {
    try {
      final apiService = ApiService();
      final response = await apiService.fetchAllUsers();
      print(
          'Réponse reçue : ${response?.toString()}'); // Vérifie ce qui est reçu

      if (response != null && response.isNotEmpty) {
        setState(() {
          jsonData = jsonEncode(response); // Convertit en JSON
          isLoading = false;
        });
      } else {
        print('Données vides ou null.');
        setState(() {
          jsonData =
              '{"message": "Aucune donnée reçue"}'; // Met un message par défaut
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur : $e');
      setState(() {
        jsonData = '{"message": "Erreur lors de la récupération"}';
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
            ? const CircularProgressIndicator() // Affiche un indicateur le chargement
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: jsonData,
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
