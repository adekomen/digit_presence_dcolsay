import 'package:digit_presence/screens/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeContent extends StatefulWidget {
  final Function(int) onTabSelected;
  const HomeContent({super.key, required this.onTabSelected});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digit Presence DCOLSAY"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_satisfied_alt_rounded, size: 150, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Bienvenue !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Utilisez les options ci-dessous pour naviguer.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                widget.onTabSelected(1); // Aller à l'onglet scanner
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scanner un QR Code"),
            ),
          ],
        ),
      ),
    );
  }
}
