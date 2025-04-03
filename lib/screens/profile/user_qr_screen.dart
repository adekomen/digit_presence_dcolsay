//import 'package:digit_presence/models/data.dart';
import 'package:digit_presence/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'profile_screen.dart';
import '../../widgets/qr_scanner.dart';

class UserQRScreen extends StatelessWidget {
  const UserQRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Votre Code QR',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QRScanner(apiService: ApiService()),
                        ),
                      ),
                      icon: const Icon(LineAwesomeIcons.expand_solid),
                    ),
                  ],
                ),
              ),

              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage(tProfileImage),
              ),
              const SizedBox(height: 16),

              Text(
                tProfileHeading,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // QR Code
              QrImageView(
                data: tProfileHeading,
                version: QrVersions.auto,
                size: 250,
                gapless: false,
                eyeStyle: QrEyeStyle(
                  color: tPrimaryColor,
                  eyeShape: QrEyeShape.square,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: tPrimaryColor,
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Votre code QR est prêt !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bouton Partager
              ElevatedButton(
                onPressed: () {
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tPrimaryColor,
                  minimumSize: const Size(250, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Partager',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
