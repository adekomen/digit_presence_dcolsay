class ApiConfig {
  // Configuration dynamique de l'URL de base
  static String getBaseUrl() {
    return 'http://192.168.1.120:8080/api';
  }

  // URL de base accessible partout dans l'application
  static String get apiUrl => getBaseUrl();
}
