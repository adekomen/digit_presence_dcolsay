import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../screens/result_screen.dart';
import 'package:digit_presence/services/api_service.dart';
import 'package:intl/intl.dart';

class QRScanner extends StatefulWidget {
  final ApiService apiService;

  const QRScanner({super.key, required this.apiService});

  @override
  State<QRScanner> createState() => QRScannerState();
}

class QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isLoading = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                              onPressed: () async {
                                await controller?.toggleFlash();
                                setState(() {});
                              },
                              child: FutureBuilder(
                                future: controller?.getFlashStatus(),
                                builder: (context, snapshot) {
                                  return Text('Flash: ${snapshot.data}');
                                },
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                              onPressed: () async {
                                await controller?.flipCamera();
                                setState(() {});
                              },
                              child: FutureBuilder(
                                future: controller?.getCameraInfo(),
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    return Text(
                                        'Camera facing ${snapshot.data!.name}');
                                  } else {
                                    return const Text('loading');
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
                            await controller?.pauseCamera();
                          },
                          child: const Text('pause',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
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
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      if (isLoading) return;

      controller.pauseCamera();
      setState(() {
        result = scanData;
        isLoading = true;
      });

      try {
        final qrContent = scanData.code;
        print("QR content scanné : $qrContent");

        if (qrContent == null || qrContent.isEmpty) {
          _showError("QR Code vide ou invalide");
          return;
        }

        // Vérifier si l'utilisateur est authentifié
        final token = await widget.apiService.getToken();
        if (token == null) {
          _showError("Utilisateur non authentifié");
          return;
        }

        // Encapsuler le contenu non-JSON dans un objet JSON avec une clé 'qrCode'
        Map<String, dynamic> qrData;
        try {
          qrData = json.decode(qrContent);
        } catch (e) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          qrData = {"qrCode": "$qrContent|$formattedDate"};
        }

        // Appel à l'API pour validation du QR Code
        final response = await widget.apiService.validateQRCode(json.encode(qrData));
        print("Réponse API : $response");

        if (response != null && response['status'] == 'success') {  
          final userData = response['data'];
          print("Utilisateur reconnu : ${userData['nom_utilisateur']}");

          // Obtenir l'heure actuelle du scan
          String scanTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                isValid: true,
                userName: "${userData['nom_utilisateur']} ${userData['prenom_utilisateur']}",
                scanStatus: userData['statut_presence'],
                scanTime: scanTime,  // Passer l'heure du scan
              ),
            ),
          );
        } else {
          _showError(response?['message'] ?? "Erreur de validation avec le serveur");
        }
      } catch (e) {
        print("Erreur lors de la validation : $e");
        _showError("Une erreur s'est produite");
      } finally {
        setState(() {
          isLoading = false;
        });
        await Future.delayed(const Duration(seconds: 2));  
        if (mounted) {
          controller.resumeCamera();
        }
      }
    });
  }



  void _showError(String message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          isValid: false,
          errorMessage: message,
        ),
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission de caméra non accordée')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
