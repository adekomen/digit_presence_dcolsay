import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:digit_presence/widgets/qr_scanner.dart';

// Générer le mock pour http.Client
@GenerateMocks([http.Client])
import 'qr_scanner_test.mocks.dart'; // Import du fichier auto-généré

void main() {
  late MockClient client;

  setUp(() {
    client = MockClient();
  });

test('Envoi du QR code à /api/registers et vérification de la réponse', () async {
  // Données de test
  final qrData = {"qrCode": "testCode"};

  // Vérification avant la simulation
  print("⚡ Mocking client.post...");
  when(client.post(
    any,
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((_) async {
    print("✅ Mock client.post() appelé !");
    return http.Response(jsonEncode({"message": "Succès"}), 200);
  });

  // Exécution de la requête
  print("🚀 Envoi de la requête...");
  final response = await client.post(
    Uri.parse('http://localhost:8000/api/registers'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(qrData),
  );

  // Vérification que la requête a bien été appelée
  verify(client.post(
    any,
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).called(1);

  // Vérification du statut et du contenu de la réponse
  expect(response.statusCode, 200);
  expect(jsonDecode(response.body)['message'], "Succès");
});

}
