import 'package:flutter/material.dart';

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
        title: const Text('Résultat du Scan'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de résultat
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green : Colors.red,
                size: 100,
              ),
              const SizedBox(height: 20),
              // Message de résultat
              Text(
                isValid
                    ? 'Scan réussi ! Bienvenue, ${userName ?? 'Utilisateur'} !'
                    : errorMessage ?? 'Scan invalide !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isValid ? Colors.blue : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              // Informations supplémentaires en cas de succès
              if (isValid && userEmail != null) ...[
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
              // Bouton de retour à l'accueil
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue.shade800,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
