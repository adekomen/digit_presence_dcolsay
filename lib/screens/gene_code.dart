import 'package:digit_presence/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:digit_presence/services/config.dart';

class GeneCode extends StatelessWidget {
  const GeneCode({super.key, required ApiService apiService});

  @override
  Widget build(BuildContext context) {
    // Lien de scan pour le backend
    final String qrContent = '${ApiConfig.apiUrl}/scan';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer un QR Code'),
      ),
      body: Center(
        child: Column(
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
                return const Center(
                  child: Text(
                    'Uh oh! Something went wrong...',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Scannez ce code pour marquer votre présence.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
