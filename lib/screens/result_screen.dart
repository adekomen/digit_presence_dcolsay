import 'package:flutter/material.dart';

// Déclaration de la classe ResultScreen qui est un widget sans état
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key}); // Constructeur de la classe avec une clé optionnelle

  @override
  Widget build(BuildContext context) { // Méthode build pour construire l'interface utilisateur
    return Scaffold( // Scaffold fournit une structure de base pour l'application
      appBar: AppBar(
        title: const Text('Scan Réussi'),
        backgroundColor: Colors.blue,
        elevation: 10,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), 
          child: Column( // Colonne pour organiser les widgets verticalement
            mainAxisAlignment: MainAxisAlignment.center, // Centre les widgets verticalement
            children: [
              const Icon( // Icône de succès
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text( // Message de succès
                'Scan réussi ! Bienvenue à DCOLSAY !',
                style: TextStyle( 
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40), 
              ElevatedButton( // Bouton pour retourner à l'accueil
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst); // Revenir à la première page de la pile de navigation
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, 
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
