import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool isValid;
  final String? userName;
  final String? userEmail;

  const ResultScreen({
    super.key,
    required this.isValid,
    this.userName,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du Scan'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green : Colors.red,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                isValid
                    ? 'Scan réussi ! Bienvenue, $userName !'
                    : 'Scan invalide !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isValid ? Colors.blue : Colors.red,
                ),
              ),
              if (isValid) ...[
                const SizedBox(height: 20),
                Text(
                  'Email : $userEmail',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
