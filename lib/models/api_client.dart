// import 'package:dio/dio.dart';

// class ApiClient {
//   final Dio _dio = Dio();
//   String? _accessToken;

//   void setToken(String token) {
//     _accessToken = token;
//   }

//   Future<dynamic> registerUser(Map<String, dynamic>? data) async {
//     try {
//       Response response = await _dio.post(
//         'http://localhost:8000/api/register',
//         data: data,
//       );
//       return response.data;
//     } on DioException catch (e) {
//       return e.response?.data ?? {'error': 'Une erreur est survenue'};
//     }
//   }

//   Future<dynamic> login(String email, String password) async {
//     try {
//       Response response = await _dio.post(
//         'http://localhost:8000/api/login',
//         data: {
//           'email': email,
//           'password': password,
//         },
//       );
//       _accessToken = response.data['token'];
//       return response.data;
//     } on DioException catch (e) {
//       return e.response?.data ?? {'error': 'Une erreur est survenue'};
//     }
//   }

//   Future<dynamic> getUserProfileData() async {
//     if (_accessToken == null) return {'error': 'Utilisateur non authentifié'};

//     try {
//       Response response = await _dio.get(
//         'http://localhost:8000/api/account',
//         options: Options(
//           headers: {'Authorization': 'Bearer $_accessToken'},
//         ),
//       );
//       return response.data;
//     } on DioException catch (e) {
//       return e.response?.data ?? {'error': 'Une erreur est survenue'};
//     }
//   }

//   Future<dynamic> updateUserProfile(Map<String, dynamic> data) async {
//     if (_accessToken == null) return {'error': 'Utilisateur non authentifié'};

//     try {
//       Response response = await _dio.put(
//         'http://localhost:8000/api/account',
//         data: data,
//         options: Options(
//           headers: {'Authorization': 'Bearer $_accessToken'},
//         ),
//       );
//       return response.data;
//     } on DioException catch (e) {
//       return e.response?.data ?? {'error': 'Une erreur est survenue'};
//     }
//   }

//   Future<dynamic> logout() async {
//     if (_accessToken == null) return {'error': 'Utilisateur non authentifié'};

//     try {
//       Response response = await _dio.post(
//         'http://localhost:8000/api/logout',
//         options: Options(
//           headers: {'Authorization': 'Bearer $_accessToken'},
//         ),
//       );
//       _accessToken = null;
//       return response.data;
//     } on DioException catch (e) {
//       return e.response?.data ?? {'error': 'Une erreur est survenue'};
//     }
//   }
// }


import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio();
  String? _accessToken;

  // URL de l'API en ligne pour tester l'authentification
  final String baseUrl =
      'https://reqres.in/api'; // Remplace par ton API si besoin

  void setToken(String token) {
    _accessToken = token;
  }

  Future<dynamic> registerUser(Map<String, dynamic>? data, String trim) async {
    try {
      Response response = await _dio.post(
        '$baseUrl/register', // Endpoint d'inscription
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'error': 'Une erreur est survenue'};
    }
  }

  Future<dynamic> login(String email, String password) async {
    try {
      Response response = await _dio.post(
        '$baseUrl/login', // Endpoint de connexion
        data: {
          'email': email,
          'password': password,
        },
      );
      _accessToken = response.data['token'];
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'error': 'Une erreur est survenue'};
    }
  }

  Future<dynamic> getUserProfileData() async {
    if (_accessToken == null) return {'error': 'Utilisateur non authentifié'};

    try {
      Response response = await _dio.get(
        '$baseUrl/users/2', // Exemple de récupération de profil
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'error': 'Une erreur est survenue'};
    }
  }

  Future<dynamic> logout() async {
    _accessToken = null;
    return {'message': 'Déconnexion réussie'};
  }
}
