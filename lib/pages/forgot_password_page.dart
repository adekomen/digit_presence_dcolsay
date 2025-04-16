import 'package:flutter/material.dart';
import 'package:digit_presence/components/my_textfield.dart';
import 'package:digit_presence/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String email;

  const ForgotPasswordPage({super.key, this.email = ''});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  // Demander un code OTP
  Future<void> _requestOtp() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Veuillez entrer votre email";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _authService.requestOtp(_emailController.text.trim());

      setState(() {
        _isLoading = false;
        if (success) {
          _otpSent = true;
          _successMessage = "Un code de vérification a été envoyé à votre email";
        } else {
          _errorMessage = "Impossible d'envoyer le code. Vérifiez votre email";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur lors de l'envoi du code: $e";
      });
    }
  }

  // Vérifier le code OTP
  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Veuillez entrer le code de vérification";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _authService.verifyOtp(
          _emailController.text.trim(), _otpController.text.trim());

      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _otpVerified = true;
          _successMessage = "Code vérifié avec succès";
        } else {
          _errorMessage = "Code de vérification invalide ou expiré";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur lors de la vérification du code: $e";
      });
    }
  }

  // Réinitialiser le mot de passe
  Future<void> _resetPassword() async {
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Veuillez entrer un nouveau mot de passe";
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Les mots de passe ne correspondent pas";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      /*final success = await _authService.resetPassword(
        //email: _emailController.text.trim(),
        //otp: _otpController.text.trim(),
        newPassword: _passwordController.text.trim(),
      );*/

      /*setState(() {
        _isLoading = false;
        if (success == true) {
          _successMessage = "Mot de passe réinitialisé avec succès";
          // Rediriger vers la page de connexion après quelques secondes
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ));
            }
          });
        } else {
          _errorMessage = "Erreur lors de la réinitialisation du mot de passe";
        }
      });*/
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur lors de la réinitialisation: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialisation du mot de passe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Étape 1: Demander un code OTP
              if (!_otpSent) ...[
                const Text(
                  'Veuillez entrer votre adresse email pour recevoir un code de réinitialisation',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _requestOtp,
                        child: const Text('Envoyer le code'),
                      ),
              ],

              // Étape 2: Vérifier le code OTP
              if (_otpSent && !_otpVerified) ...[
                const Text(
                  'Veuillez entrer le code de vérification envoyé à votre email',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _otpController,
                  hintText: 'Code de vérification',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _verifyOtp,
                        child: const Text('Vérifier le code'),
                      ),
                TextButton(
                  onPressed: _isLoading ? null : _requestOtp,
                  child: const Text("Renvoyer le code"),
                ),
              ],

              // Étape 3: Réinitialiser le mot de passe
              if (_otpVerified) ...[
                const Text(
                  'Veuillez entrer votre nouveau mot de passe',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Nouveau mot de passe',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirmer le mot de passe',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _resetPassword,
                        child: const Text('Réinitialiser le mot de passe'),
                      ),
              ],

              // Messages d'erreur ou de succès
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],

              if (_successMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
