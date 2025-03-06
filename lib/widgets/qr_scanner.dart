import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../screens/result_screen.dart';
import '../models/data.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!
          .pauseCamera(); // Pause la caméra sur Android lors de la réassemblage
    }
    controller!.resumeCamera(); // Reprend la caméra
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)), // Vue du scanner QR
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller
                                  ?.toggleFlash(); // Active/désactive le flash
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller
                                  ?.getFlashStatus(), // Récupère le statut du flash
                              builder: (context, snapshot) {
                                return Text(
                                    'Flash: ${snapshot.data}'); // Affiche le statut du flash
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller
                                  ?.flipCamera(); // Change de caméra
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller
                                  ?.getCameraInfo(), // Récupère les infos de la caméra
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Camera facing ${snapshot.data!.name}'); // Affiche la caméra utilisée
                                } else {
                                  return const Text(
                                      'loading'); // Affiche un message de chargement
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller
                                ?.pauseCamera(); // Met en pause la caméra
                          },
                          child: const Text('pause',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller
                                ?.resumeCamera(); // Reprend la caméra
                          },
                          child: const Text('continue',
                              style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0; // Définit la taille de la zone de scan
    return QRView(
      key: qrKey,
      onQRViewCreated:
          _onQRViewCreated, // Appelé lors de la création de la vue QR
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea), // Définition de l'overlay du scanner
      onPermissionSet: (ctrl, p) => _onPermissionSet(
          context, ctrl, p), // Appelé lors de la définition des permissions
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData; // Met à jour le résultat avec les données scannées
      });

      // Vérifie si les données scannées sont valides
      if (_isValidQRCode(scanData.code)) {
        // Arrêter le scanner après la détection d'un QR code
        controller.pauseCamera();

        // Naviguer vers ResultScreen avec un message de succès
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ResultScreen(isValid: true),
          ),
        );
      } else {
        // Naviguer vers ResultScreen avec un message d'erreur
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ResultScreen(isValid: false),
          ),
        );
      }
    });
  }

  bool _isValidQRCode(String? code) {
    if (code == null) return false;

    // Générer la version JSON des données de référence
    //String expectedJson = jsonEncode(MainScreen().data);

    // Comparer directement le JSON du QR scanné avec les données attendues
    return code == jsonData;
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p'); // Log les permissions
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'no Permission')), // Affiche un message si les permissions sont refusées
      );
    }
  }
}
