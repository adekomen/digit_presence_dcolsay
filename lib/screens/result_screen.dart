import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool isValid; // Indique si les données scannées sont valides

  const ResultScreen({super.key, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du Scan'),
        backgroundColor: Colors.blue,
        elevation: 10,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de succès ou d'erreur
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green : Colors.red,
                size: 100,
              ),
              const SizedBox(height: 20),
              // Message de succès ou d'erreur
              Text(
                isValid
                    ? 'Scan réussi ! Bienvenue à DCOLSAY !'
                    : 'Scan invalide !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isValid ? Colors.blue : Colors.red,
                ),
              ),
              const SizedBox(height: 40),
              // Bouton pour revenir à l'accueil
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Retour à l\'accueil',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
