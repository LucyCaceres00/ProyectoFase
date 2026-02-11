class ApiConfig {
  // URL base del API según la plataforma
  static String get baseUrl {
    return 'http://192.168.100.90:5209/api/';
  }

  // Timeout para las peticiones (en segundos)
  static const Duration timeout = Duration(seconds: 30);

  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Construir URL completa
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  // Headers con token (para peticiones autenticadas)
  static Map<String, String> getAuthHeaders(String token) {
    return {...defaultHeaders, 'Authorization': 'Bearer $token'};
  }
}
