import 'package:digit_presence/screens/main_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/qr_scanner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Construction de l'interface utilisateur
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digit Presence DCOLSAY'),
        backgroundColor: Colors.blue,
        elevation: 10,
      ),
      body: Container(
        // Définition du dégradé de fond
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 171, 203, 230),
              const Color.fromARGB(255, 229, 175, 174),
              const Color.fromARGB(255, 199, 189, 145),
              Colors.green.shade400,
            ],
            stops: const [
              0.2,
              0.5,
              0.7,
              1.0
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/dcolsay_img.jpg',
                height: 150,
              ),
              const SizedBox(height: 20),
              // Texte de bienvenue
              const Text(
                'Bienvenue sur Digit Presence',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Texte d'instruction
              const Text(
                'Scannez le code QR pour enregistrer votre présence ou votre départ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Bouton pour scanner le QR code
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const QRScanner(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'SCANNER ICI',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MainScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'GENERATE A QR CODE',
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
