import 'package:flutter/material.dart';
import '../widgets/qr_scanner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrez votre ID'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'ID Utilisateur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final userId = _userIdController.text.trim();
                if (userId.isNotEmpty) {
                  // Naviguer vers le scanner avec l'ID de l'utilisateur
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QRScanner(userId: userId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Veuillez entrer un ID valide')),
                  );
                }
              },
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}
