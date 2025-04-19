import 'dart:io';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'user_qr_screen.dart';
import '../../services/auth_service.dart';
import '../../services/config.dart';
import 'package:digit_presence/services/api_service.dart';
import 'package:digit_presence/screens/gene_code.dart'; 

// Constants
const String tProfile = "Mon Profil";
const String tEditProfile = "Modifier le profil";
const String tProfileImageDefault = "assets/dcolsay_img.jpg";
const double tDefaultSize = 16.0;
const Color tPrimaryColor = Colors.blue;
const Color tDarkColor = Colors.black;
const Color tAccentColor = Colors.blueAccent;
const String tFullName = "Nom Complet";
const String tEmail = "Email";
const String tPhoneNo = "Téléphone";
const String tPassword = "Mot de passe";
const double tFormHeight = 50.0;
const String tJoined = "Rejoint le : ";
const String tDelete = "Supprimer le compte";

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static const String _profileImageKey = 'profile_image_path';

  // Enregistrer le chemin de l'image de profil localement
  Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, path);
  }

  // Récupérer le chemin de l'image de profil
  Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey);
  }

  // Télécharger l'image de profil vers le serveur
  Future<bool> uploadProfileImage(File imageFile, String userId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      // Créer une requête multipart pour l'upload de fichier
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiConfig.apiUrl}/users/$userId/profile-image'));

      // Ajouter l'en-tête d'autorisation
      request.headers.addAll(
          {'Authorization': 'Bearer $token', 'Accept': 'application/json'});

      // Ajouter le fichier à la requête
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      // Envoyer la requête
      var response = await request.send();

      // Analyser la réponse
      if (response.statusCode == 200) {
        // Sauvegarder le chemin en local
        await saveProfileImagePath(imageFile.path);
        return true;
      }

      print('Erreur upload image: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Exception lors de l\'upload: $e');
      return false;
    }
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print("Début du chargement des données utilisateur");
      bool isAuthenticated = await _authService.isLoggedIn();
      print("Authentifié: $isAuthenticated");

      if (isAuthenticated) {
        print(
            "Utilisateur authentifié: ${_authService.currentUser?.firstname} ${_authService.currentUser?.lastname}");
      } else {
        print("Utilisateur non authentifié");
      }

      _profileImagePath = await _profileService.getProfileImagePath();
      print(
          "Chemin de l'image de profil: ${_profileImagePath ?? 'non défini'}");
    } catch (e) {
      print("Erreur lors du chargement des données: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Méthode pour gérer la déconnexion
  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      // Utiliser Get.offAllNamed pour effacer la pile de navigation
      Get.offAllNamed('/login');
    } catch (e) {
      print("Erreur lors de la déconnexion: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la déconnexion')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final user = _authService.currentUser;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(tProfile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(tProfile)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Vous n'êtes pas connecté"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Naviguer vers la page de connexion avec Get
                  Get.offAllNamed('/login');
                },
                child: const Text("Se connecter"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text(tProfile, style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UserQRScreen(),
              ),
            ),
            icon: const Icon(LineAwesomeIcons.qrcode_solid),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSize),
          child: Column(
            children: [
              /// -- IMAGE
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _profileImagePath != null
                          ? Image.file(
                              File(_profileImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Image(
                                  image: AssetImage(tProfileImageDefault),
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : const Image(
                              image: AssetImage(tProfileImageDefault),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 512,
                          maxHeight: 512,
                          imageQuality: 75,
                        );

                        if (image != null) {
                          // Créer une copie dans l'espace de stockage permanent de l'app
                          final appDir =
                              await getApplicationDocumentsDirectory();
                          final fileName = 'profile_${user.id}.jpg';
                          final savedImage = File('${appDir.path}/$fileName');
                          await savedImage.writeAsBytes(
                              await File(image.path).readAsBytes());

                          // Upload vers le serveur
                          final success =
                              await _profileService.uploadProfileImage(
                                  savedImage, user.id.toString());

                          if (success) {
                            setState(() {
                              _profileImagePath = savedImage.path;
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Photo de profil mise à jour')),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Échec de la mise à jour de la photo')),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: tPrimaryColor,
                        ),
                        child: const Icon(
                          LineAwesomeIcons.camera_solid,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text("${user.firstname} ${user.lastname}",
                  style: Theme.of(context).textTheme.headlineMedium),
              Text(user.role, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),

              /// -- USER INFO CARD
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(LineAwesomeIcons.envelope,
                            color: tPrimaryColor),
                        title: const Text("Email"),
                        subtitle: Text(user.email),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(LineAwesomeIcons.phone_solid,
                            color: tPrimaryColor),
                        title: const Text("Téléphone"),
                        subtitle: Text(user.phone),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(LineAwesomeIcons.user_tag_solid,
                            color: tPrimaryColor),
                        title: const Text("Role"),
                        subtitle: Text(user.role),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// -- BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UpdateProfileScreen(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tPrimaryColor,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    tEditProfile,
                    style: TextStyle(color: tDarkColor),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// -- MENU
              ProfileMenuWidget(
                  title: "Paramètres",
                  icon: LineAwesomeIcons.cog_solid,
                  onPress: () {}),
              ProfileMenuWidget(
                  title: "Détails de facturation",
                  icon: LineAwesomeIcons.wallet_solid,
                  onPress: () {}),
              ProfileMenuWidget(
                  title: "Gestion utilisateur",
                  icon: LineAwesomeIcons.user_check_solid,
                  onPress: () {}),
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                  title: "Information",
                  icon: LineAwesomeIcons.info_solid,
                  onPress: () {}),
              ProfileMenuWidget(
                  title: "Générer QR Code",
                  icon: LineAwesomeIcons.qrcode_solid,
                  onPress: () {
                    final apiService = ApiService();
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GeneCode(apiService: apiService),
                    ),
                  );
                  }),
              ProfileMenuWidget(
                  title: "Déconnexion",
                  icon: LineAwesomeIcons.sign_out_alt_solid,
                  textColor: Colors.red,
                  endIcon: false,
                  onPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("DÉCONNEXION"),
                          titleTextStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          content: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                                "Êtes-vous sûr de vouloir vous déconnecter?"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Non"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _handleLogout();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                side: BorderSide.none,
                              ),
                              child: const Text("Oui"),
                            ),
                          ],
                        );
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  String? _profileImagePath;
  String _joinedDate = ""; // Pour stocker la date d'inscription formatée

  // Controllers pour les champs de formulaire
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  bool _obscurePassword = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _authService.isLoggedIn();
    _profileImagePath = await _profileService.getProfileImagePath();

    if (_authService.currentUser != null) {
      firstNameController =
          TextEditingController(text: _authService.currentUser!.firstname);
      lastNameController =
          TextEditingController(text: _authService.currentUser!.lastname);
      emailController =
          TextEditingController(text: _authService.currentUser!.email);
      phoneController =
          TextEditingController(text: _authService.currentUser!.phone);
      passwordController = TextEditingController();

      // Formater la date d'inscription si disponible
      if (_authService.currentUser!.createdAt != null) {
        final DateTime createdAt = _authService.currentUser!.createdAt!;
        _joinedDate = DateFormat("d MMMM yyyy", 'fr_FR').format(createdAt);
      } else {
        _joinedDate = DateFormat("d MMMM yyyy", 'fr_FR').format(DateTime.now());
      }
    } else {
      firstNameController = TextEditingController();
      lastNameController = TextEditingController();
      emailController = TextEditingController();
      phoneController = TextEditingController();
      passwordController = TextEditingController();
      _joinedDate = DateFormat("d MMMM yyyy", 'fr_FR').format(DateTime.now());
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectAndUploadImage() async {
    if (_authService.currentUser == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      // Créer une copie dans l'espace de stockage permanent de l'app
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${_authService.currentUser!.id}.jpg';
      final savedImage = File('${appDir.path}/$fileName');
      await savedImage.writeAsBytes(await File(image.path).readAsBytes());

      // Upload vers le serveur
      final success = await _profileService.uploadProfileImage(
          savedImage, _authService.currentUser!.id.toString());

      if (success) {
        setState(() {
          _profileImagePath = savedImage.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo de profil mise à jour')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Échec de la mise à jour de la photo')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text(tEditProfile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LineAwesomeIcons.angle_left_solid)),
        title: Text(tEditProfile,
            style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSize),
          child: Column(
            children: [
              // -- IMAGE with ICON
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _profileImagePath != null
                          ? Image.file(
                              File(_profileImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Image(
                                  image: AssetImage(tProfileImageDefault),
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : const Image(
                              image: AssetImage(tProfileImageDefault),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _selectAndUploadImage,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: tPrimaryColor,
                        ),
                        child: const Icon(
                          LineAwesomeIcons.camera_solid,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // -- Form Fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre prénom';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                label: Text("Prénom"),
                                prefixIcon: Icon(LineAwesomeIcons.user)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre nom';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                label: Text("Nom"),
                                prefixIcon: Icon(LineAwesomeIcons.user)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: tFormHeight - 20),
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          label: Text(tEmail),
                          prefixIcon: Icon(LineAwesomeIcons.envelope)),
                    ),
                    const SizedBox(height: tFormHeight - 20),
                    TextFormField(
                      controller: phoneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          label: Text(tPhoneNo),
                          prefixIcon: Icon(LineAwesomeIcons.phone_solid)),
                    ),
                    const SizedBox(height: tFormHeight - 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        label: const Text(tPassword),
                        prefixIcon: const Icon(Icons.fingerprint),
                        suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? LineAwesomeIcons.eye_slash
                                : LineAwesomeIcons.eye),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            }),
                      ),
                    ),
                    const SizedBox(height: tFormHeight),

                    // -- Form Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Ajouter la logique pour mettre à jour le profil
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Profil mis à jour avec succès')),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: tPrimaryColor,
                            side: BorderSide.none,
                            shape: const StadiumBorder()),
                        child: const Text(tEditProfile,
                            style: TextStyle(color: tDarkColor)),
                      ),
                    ),
                    const SizedBox(height: tFormHeight),

                    // -- Created Date and Delete Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: tJoined,
                            style: const TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                  text:
                                      _joinedDate, // Utiliser la date dynamique
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Supprimer le compte"),
                                content: const Text(
                                    "Êtes-vous sûr de vouloir supprimer votre compte? Cette action est irréversible."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Annuler"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Ajouter la logique pour supprimer le compte
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Supprimer"),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.1),
                              elevation: 0,
                              foregroundColor: Colors.red,
                              shape: const StadiumBorder(),
                              side: BorderSide.none),
                          child: const Text(tDelete),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    var iconColor = isDark ? tPrimaryColor : tAccentColor;

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: iconColor.withOpacity(0.1),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title,
          style:
              Theme.of(context).textTheme.bodyLarge?.apply(color: textColor)),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(LineAwesomeIcons.angle_right_solid,
                  size: 18.0, color: Colors.grey))
          : null,
    );
  }
}
