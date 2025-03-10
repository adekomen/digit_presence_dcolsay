import 'package:flutter/material.dart';
import '../widgets/qr_scanner.dart';
import '../models/data.dart'; // Importez ApiService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userIdController = TextEditingController();
  bool isLoading = false; // Indicateur de chargement

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
            isLoading
                ? const CircularProgressIndicator() // Afficher un indicateur de chargement
                : ElevatedButton(
                    onPressed: () async {
                      final userId = _userIdController.text.trim();
                      if (userId.isNotEmpty) {
                        setState(() {
                          isLoading =
                              true; // Afficher l'indicateur de chargement
                        });

                        // Vérifier si l'ID existe dans la base de données
                        final user = await ApiService.fetchUserById(userId);
                        setState(() {
                          isLoading =
                              false; // Masquer l'indicateur de chargement
                        });

                        if (user != null) {
                          // Naviguer vers le scanner avec l'ID de l'utilisateur
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QRScanner(userId: userId),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('ID utilisateur invalide')),
                          );
                        }
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
