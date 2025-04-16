class ApiConfig {
  // Configuration dynamique de l'URL de base
  static String getBaseUrl() {
    return 'https://voidexplorer.alwaysdata.net/digit-presence-lumen/Digit-present-Api/public/api';
  }

  // URL de base accessible partout dans l'application
  static String get apiUrl => getBaseUrl();
}
