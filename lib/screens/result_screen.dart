import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final bool isValid;
  final String? userName;
  final String? scanStatus;
  final String? errorMessage;
  final String? scanTime;  // Ajouter l'heure du scan

  const ResultScreen({
    super.key,
    required this.isValid,
    this.userName,
    this.scanStatus,
    this.errorMessage,
    this.scanTime,  // Passer l'heure du scan
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du scan'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isValid ? Icons.check_circle : Icons.cancel,
              color: widget.isValid ? Colors.green : Colors.red,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              widget.isValid ? 'QR Code valide' : 'QR Code invalide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isValid ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            if (widget.isValid && widget.userName != null && widget.scanStatus != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'M/Mme: ${widget.userName}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Statut : ${widget.scanStatus}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Heure du scan : ${widget.scanTime}',  // Afficher l'heure du scan
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Présence validée avec succès',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!widget.isValid) ...[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  widget.errorMessage ?? 'Ce QR Code n\'est pas valide pour cette application',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (widget.isValid) {
                  Navigator.pop(context, 0);
                } else {
                  Navigator.pop(context, 1);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(widget.isValid ? 'Aller à l\'accueil' : 'Retour au scan',
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
