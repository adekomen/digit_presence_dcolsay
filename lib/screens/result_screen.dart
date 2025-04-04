//import 'package:digit_presence/models/data.dart';
import 'package:digit_presence/services/api_service.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/qr_scanner.dart';

class ResultScreen extends StatelessWidget {
  final bool isValid;
  final String? userName;
  final String? userEmail;
  final String? errorMessage;

  const ResultScreen({
    super.key,
    required this.isValid,
    this.userName,
    this.userEmail,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du scan'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.cancel,
              color: isValid ? Colors.green : Colors.red,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              isValid ? 'QR Code valide' : 'QR Code invalide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isValid ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            if (isValid && userName != null && userEmail != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'M/Mme: $userName',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: $userEmail',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Présence validée avec succès',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!isValid) ...[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  errorMessage ??
                      'Ce QR Code n\'est pas valide pour cette application',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (isValid) {
                  // Redirection vers HomeScreen avec MaterialPageRoute
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  // Redirection vers QRScanner avec MaterialPageRoute
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => QRScanner(apiService: ApiService())),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(isValid ? 'Aller à l\'accueil' : 'Retour au scan',
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
