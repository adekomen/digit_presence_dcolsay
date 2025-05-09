import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:digit_presence/services/api_service.dart';
import 'package:digit_presence/services/config.dart';
import 'package:http/http.dart' as http;

class GeneCode extends StatefulWidget {
  final ApiService apiService;

  const GeneCode({super.key, required this.apiService});

  @override
  State<GeneCode> createState() => _GeneCodeState();
}

class _GeneCodeState extends State<GeneCode> {
  late Future<Uint8List> _qrCodeFuture;

  Future<Uint8List> fetchQrCode() async {
    final token = await widget.apiService.getToken(); // Méthode à adapter si besoin

    final response = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/entreprises/1/qrcode'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'image/png',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes; // Données binaires de l'image PNG
    } else {
      throw Exception('Impossible de récupérer le QR code');
    }
  }

  @override
  void initState() {
    super.initState();
    _qrCodeFuture = fetchQrCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code du jour'),
      ),
      body: Center(
        child: FutureBuilder<Uint8List>(
          future: _qrCodeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Erreur : ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.memory(
                    snapshot.data!,
                    width: 220,
                    height: 220,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'QR code généré depuis le backend',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            } else {
              return const Text('QR code introuvable.');
            }
          },
        ),
      ),
    );
  }
}
