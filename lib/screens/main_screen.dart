import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert'; // Pour convertir les données en JSON

class MainScreen extends StatelessWidget {
  final List<Map<String, String>> data = [
    {
      'name': 'JAdesu Franco',
      'email': 'franco@gmail.com'
    },
    {
      'name': 'Thon Chaboto',
      'email': 'chaboto@gmail.com'
    },
  ];

  MainScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Convertir la liste `data` en JSON
    String jsonData = jsonEncode(data);
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Center(
        child: QrImageView(
          data: jsonData, // Utiliser les données JSON
          version: QrVersions.auto,
          size: 200.0,
          embeddedImage: AssetImage('assets/dcolsay_img.jpg'),
          embeddedImageStyle: QrEmbeddedImageStyle(
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
      ),
    );
  }
}