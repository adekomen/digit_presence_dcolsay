import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:digit_presence/screens/main_screen.dart';
import 'package:digit_presence/models/data.dart';
import 'main_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  // Test pour vérifier que fectchData() est appelé dans initState()
  testWidgets('fetchData() est appelée dans initState()',
      (WidgetTester tester) async {
    // Crée un mock de ApiService
    final mockApiService = MockApiService();

    // Simule une réponse de fetchAllUsers()
    when(mockApiService.fetchAllUsers()).thenAnswer((_) async => []);

    // Construit le widget MainScreen avec le mock ApiService
    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(apiService: mockApiService),
      ),
    );

    // Vérifie que fetchData() a été appelée
    verify(mockApiService.fetchAllUsers()).called(1);
  });

  // Test pour simuler une réponse de l'API et vérifier que jsonData est crrectement mis à jour
  testWidgets('jsonData est correctement mis à jour',
      (WidgetTester tester) async {
    // Crée un mock de ApiService
    final mockApiService = MockApiService();

    // Simuler une réponse de fetchAllUsers()
    final mockResponse = [
    {
        "id": 1,
        "lastname": "Klein",
        "firstname": "Jaquan",
        "email": "rath.nathen@example.net",
        "password": "Jaklein@08",
    },
    {
        "id": 2,
        "lastname": "Quigley",
        "firstname": "Orpha",
        "email": "kreiger.colleen@example.org",
        "password": "Orgley@12",
    },
    ];
    when(mockApiService.fetchAllUsers()).thenAnswer((_) async => mockResponse);

    // Construit le widget MainScreen avec le mock ApiService
    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(
            apiService: mockApiService),
      ),
    );

    // Attend que l'interface utilisateur se mette à jour
    await tester.pump();

    // Vérifie que jsonData est correctement mis à jour
    final mainScreenState = tester.state<MainScreenState>(find.byType(MainScreen));
    expect(mainScreenState.jsonData, jsonEncode(mockResponse));
  });

  // Test pour vérifier que le widget QrImageView est affiché avec les bonnes données
  testWidgets('QrImageView s\'affiche correctement',
      (WidgetTester tester) async {
    // Crée un mock de ApiService
    final mockApiService = MockApiService();

    // Simuler une réponse de fetchAllUsers()
    final mockResponse = [
    {
        "id": 1,
        "lastname": "Klein",
        "firstname": "Jaquan",
        "email": "rath.nathen@example.net",
        "password": "Jaklein@08",
    },
    {
        "id": 2,
        "lastname": "Quigley",
        "firstname": "Orpha",
        "email": "kreiger.colleen@example.org",
        "password": "Orgley@12",
    },
    ];
    when(mockApiService.fetchAllUsers()).thenAnswer((_) async => mockResponse);

    // Construit le widget MainScreen avec le mock ApiService
    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(
            apiService: mockApiService),
      ),
    );

    // Attend que l'interface utilisateur se mette à jour
    await tester.pump();

    // Vérifie que le QR Code est affiché
    expect(find.byType(QrImageView), findsOneWidget);
  });

  // Test de l'indicateur de chargement
  testWidgets('CircularProgressIndicator est affiché pendant le chargement',
      (WidgetTester tester) async {
    // Crée un mock de ApiService
    final mockApiService = MockApiService();

    // Simule une réponse de fetchAllUsers() qui prend du temps
    when(mockApiService.fetchAllUsers()).thenAnswer((_) async {
      await Future.delayed(
          const Duration(seconds: 2)); // Simule un délai de chargement
      return [];
    });

    // Construit le widget MainScreen avec le mock ApiService
    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(
            apiService: mockApiService), // Passe le mock à MainScreen
      ),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // Test pour simuler qu'il y'a une erreur lors de la récupération
  testWidgets('jsonData contient un message d\'erreur en cas d\'échec de la récupération des données',
      (WidgetTester tester) async {
    // Crée un mock de ApiService
    final mockApiService = MockApiService();

    // Simule une erreur lors de l'appel à fetchAllUsers()
    when(mockApiService.fetchAllUsers())
        .thenThrow(Exception('Erreur de connexion'));

    // Construit le widget MainScreen avec le mock ApiService
    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(
            apiService: mockApiService), // Passe le mock à MainScreen
      ),
    );

    // Attend que l'interface utilisateur se mette à jour
    await tester.pump();

    // Vérifie que jsonData contient un message d'erreur
    final mainScreenState =
        tester.state<MainScreenState>(find.byType(MainScreen));
    expect(mainScreenState.jsonData,
        '{"message": "Erreur lors de la récupération"}');
  });
}
