import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Center(
        child: QrImageView(
          data: data.toString(),
          version: QrVersions.auto,
          size: 200.0,
          embeddedImage: AssetImage('assets/dcolsay_img.jpg'),
          embeddedImageStyle: QrEmbeddedImageStyle(
            size: Size(40, 40),
          ),
        ),
      ),
    );
  }
}