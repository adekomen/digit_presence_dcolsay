import 'package:digit_presence/services/api_service.dart';
import 'package:flutter/material.dart';
import '../widgets/qr_scanner.dart';
import 'history_screen.dart';
import 'home_content.dart';
import './profile/profile_screen.dart';
//import '../models/data.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // Defining Particles for animation.
ParticleOptions particles = const ParticleOptions(
    baseColor: Colors.cyan,
    spawnOpacity: 0.0,
    opacityChangeRate: 0.25,
    minOpacity: 0.1,
    maxOpacity: 0.4,
    particleCount: 70,
    spawnMaxRadius: 15.0,
    spawnMaxSpeed: 100.0,
    spawnMinSpeed: 30,
    spawnMinRadius: 7.0,
  );
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(), // Section d'accueil intégrée
    QRScanner(apiService: ApiService()), // Scanner
    const HistoryScreen(), // Historique des scans
    const ProfileScreen(), // Profil utilisateur
    const MainScreen(), //generer un code
  ];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scanner",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historique",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2_rounded),
            label: "Gene code",
          ),
        ],
      ),
    );
  }
}
