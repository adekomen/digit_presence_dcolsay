import 'package:flutter/material.dart';
import 'package:digit_presence/components/my_button.dart';
import 'package:digit_presence/components/my_textfield.dart';
import 'package:digit_presence/components/square_tile.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Instance du service d'authentification
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  // Vérifier si l'utilisateur est déjà connecté
  Future<void> _checkIfAlreadyLoggedIn() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn && mounted) {
      // Rediriger vers l'écran d'accueil si déjà connecté
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ));
    }
  }

  // Méthode de connexion
  Future<void> signUserIn() async {
    // Vérifie si les champs email et mot de passe sont vides
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Veuillez remplir tous les champs";
      });
      print("Erreur: Champs vides"); // Message de débogage
      return;
    }

    // Démarre l'état de chargement et réinitialise le message d'erreur
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    print("Début de la connexion..."); // Message de débogage

    try {
      // Appelle le service d'authentification pour se connecter
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      print("Résultat de la connexion: $result"); // Message de débogage

      // Vérifie si la connexion a réussi
      if (result['success']) {
        // Connexion réussie, navigue vers l'écran d'accueil
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
        }
        print("Connexion réussie"); // Message de débogage
      } else {
        // Échec de la connexion, affiche un message d'erreur
        setState(() {
          _errorMessage = result['message'] ?? "Échec de la connexion";
          _isLoading = false;
        });
        print("Échec de la connexion: $_errorMessage"); // Message de débogage
      }
    } catch (e) {
      // Gère les exceptions et affiche un message d'erreur
      setState(() {
        _errorMessage = "Erreur de connexion: $e";
        _isLoading = false;
      });
      print("Exception capturée: $e"); // Message de débogage
    }
  }


  // Naviguer vers la page de récupération de mot de passe
  void _navigateToForgotPassword() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ForgotPasswordPage(email: emailController.text),
    ));
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

                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),

                Text(
                  'Bienvenue à toi, tu nous as manqué !❤❤😘',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Mot de passe',
                  obscureText: true,
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _navigateToForgotPassword,
                        child: Text(
                          'Mot de passe oublié?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // sign in button
                _isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(
                        onPressed: signUserIn,
                        text: 'Se connecter',
                      ),

                const SizedBox(height: 30),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Ou continuer avec',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // google + apple sign in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    // google button
                    SquareTile(imagePath: 'lib/images/google.png'),

                    SizedBox(width: 25),

                    // apple button
                    SquareTile(imagePath: 'lib/images/apple.png')
                  ],
                ),

                const SizedBox(height: 20),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore membre?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        // Naviguer vers la page d'inscription
                        Navigator.pushNamed(context, '/registers');
                      },
                      child: const Text(
                        'Inscrivez-vous maintenant',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
