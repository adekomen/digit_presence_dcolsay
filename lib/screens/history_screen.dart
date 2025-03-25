import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique des scans"),
      automaticallyImplyLeading: false),
      body: const Center(
        child: Text("Historique des QR Codes scannés"),
      ),
    );
  }
}
