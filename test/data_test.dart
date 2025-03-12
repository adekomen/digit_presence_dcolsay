import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:digit_presence/models/data.dart';
import 'data_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  test('fetchAllUsers() retourne les données correctes en cas de succès',
      () async {
    // Crée un mock de http.Client
    final mockHttpClient = MockClient();

    // Simule une réponse réussie de l'API
    final mockResponse = '''[
      
    ]''';
    when(mockHttpClient.get(Uri.parse('http://localhost:8000/api/registers')))
        .thenAnswer((_) async => http.Response(mockResponse, 200));

    // Crée une instance de ApiService avec le mock http.Client
    final apiService = ApiService();

    // Appelle fetchAllUsers()
    final result = await apiService.fetchAllUsers();

    // Vérifie que les données sont correctement retournées
    expect(result, isA<List<Map<String, dynamic>>>());
    expect(result?.length, 10);
  });
}
