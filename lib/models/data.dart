import 'dart:convert';

final List<Map<String, String>> data = [
  {
    'name': 'JAdesu Franco',
    'email': 'franco@gmail.com',
  },
  {
    'name': 'Thon Chaboto',
    'email': 'chaboto@gmail.com',
  },
];

// Convertir la liste `data` en JSON
String get jsonData => jsonEncode(data);
