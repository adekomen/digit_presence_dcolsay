import 'package:flutter/material.dart';
import 'package:digit_presence/components/my_button.dart';
import 'package:digit_presence/components/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/api_client.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final ApiClient _apiClient = ApiClient();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  bool isLoading = false;

  void registerUser() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      _showErrorDialog("Veuillez remplir tous les champs !");
      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showErrorDialog("Les mots de passe ne correspondent pas");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Créer un ID unique pour l'utilisateur
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();

      // Créer un objet utilisateur avec les données
      final userData = {
        'id': uuid,
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'name': nameController.text.trim(),
        'lastname': lastNameController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      // Récupérer SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Récupérer les utilisateurs existants ou créer une liste vide
      final existingUsersString = prefs.getString('users') ?? '[]';
      final existingUsers = json.decode(existingUsersString) as List;

      // Vérifier si l'email existe déjà
      final emailExists = existingUsers
          .any((user) => user['email'] == emailController.text.trim());

      if (emailExists) {
        _showErrorDialog("Cet email existe déjà");
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Ajouter le nouvel utilisateur
      existingUsers.add(userData);

      // Enregistrer la liste mise à jour
      await prefs.setString('users', json.encode(existingUsers));

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Erreur lors de l\'inscription. Veuillez réessayer.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erreur d\'inscription'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Succès'),
        content: const Text(
            'Inscription réussie ! Vous pouvez maintenant vous connecter.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/dcolsay_img.jpg',
                  height: 100,
                ),
                const SizedBox(height: 50),
                Text(
                  'Créez un compte pour commencer!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: nameController,
                  hintText: 'Prénom',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: lastNameController,
                  hintText: 'Nom',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Mot de passe',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirmer le mot de passe',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(
                        onPressed: registerUser,
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous avez déjà un compte?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      ),
                      child: const Text(
                        'Connectez-vous',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
