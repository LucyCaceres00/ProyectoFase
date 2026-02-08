import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Clase para probar la conexión con el API antes de usarlo
class TestConnection {
  /// Probar si el servidor está accesible
  static Future<ConnectionResult> testServerConnection() async {
    final baseUrl = ApiConfig.baseUrl;
    print('🧪 Probando conexión a: $baseUrl');

    try {
      // Intentar hacer una petición simple GET
      final url = Uri.parse(baseUrl);

      print('   Esperando respuesta (timeout: 10 segundos)...');

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      print('✅ Servidor respondió!');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');

      return ConnectionResult(
        success: true,
        message: 'Conexión exitosa al servidor',
        statusCode: response.statusCode,
      );
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: El servidor no respondió a tiempo');
      print('   Error: $e');

      return ConnectionResult(
        success: false,
        message:
            'El servidor no respondió a tiempo. Verifica:\n'
            '1. Que tu servidor esté corriendo en el puerto 5209\n'
            '2. Que el firewall permita conexiones\n'
            '3. Si usas Android emulador, la URL debe ser http://10.0.2.2:5209/api/\n'
            '4. Si usas dispositivo físico, usa tu IP local (ej: http://192.168.1.100:5209/api/)',
        statusCode: 408,
        error: e.toString(),
      );
    } on SocketException catch (e) {
      print('🔌 Error de conexión: No se pudo conectar al servidor');
      print('   Error: $e');

      return ConnectionResult(
        success: false,
        message:
            'No se pudo conectar al servidor. Verifica:\n'
            '1. Que tu servidor esté corriendo\n'
            '2. La URL correcta:\n'
            '   - Android emulador: http://10.0.2.2:5209/api/\n'
            '   - Dispositivo físico: http://TU_IP_LOCAL:5209/api/\n'
            '   - Desktop/Web: http://localhost:5209/api/\n'
            '3. Que ambos dispositivos estén en la misma red WiFi (para dispositivo físico)',
        statusCode: 0,
        error: e.toString(),
      );
    } on HttpException catch (e) {
      print('🌐 Error HTTP: ${e.message}');

      return ConnectionResult(
        success: false,
        message: 'Error HTTP: ${e.message}',
        statusCode: 0,
        error: e.toString(),
      );
    } catch (e) {
      print('❌ Error inesperado: $e');

      return ConnectionResult(
        success: false,
        message: 'Error inesperado: $e',
        statusCode: 0,
        error: e.toString(),
      );
    }
  }

  /// Probar un endpoint específico con POST
  static Future<ConnectionResult> testPostEndpoint(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final fullUrl = ApiConfig.buildUrl(endpoint);
    print('🧪 Probando POST a: $fullUrl');
    print('   Body: $body');

    try {
      final url = Uri.parse(fullUrl);

      final response = await http
          .post(
            url,
            headers: ApiConfig.defaultHeaders,
            body: body.toString(),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Endpoint respondió!');
      print('   Status Code: ${response.statusCode}');
      print('   Response Body: ${response.body}');

      return ConnectionResult(
        success: response.statusCode >= 200 && response.statusCode < 300,
        message: 'Respuesta del servidor: ${response.body}',
        statusCode: response.statusCode,
      );
    } on TimeoutException catch (e) {
      return ConnectionResult(
        success: false,
        message: 'Timeout en el endpoint $endpoint',
        statusCode: 408,
        error: e.toString(),
      );
    } catch (e) {
      return ConnectionResult(
        success: false,
        message: 'Error al probar endpoint: $e',
        statusCode: 0,
        error: e.toString(),
      );
    }
  }

  /// Obtener información del sistema
  static Map<String, String> getSystemInfo() {
    return {
      'Platform': Platform.operatingSystem,
      'Version': Platform.operatingSystemVersion,
      'Base URL': ApiConfig.baseUrl,
      'Timeout': '${ApiConfig.timeout.inSeconds} segundos',
    };
  }
}

/// Resultado de la prueba de conexión
class ConnectionResult {
  final bool success;
  final String message;
  final int statusCode;
  final String? error;

  ConnectionResult({
    required this.success,
    required this.message,
    required this.statusCode,
    this.error,
  });

  @override
  String toString() {
    return 'ConnectionResult(success: $success, statusCode: $statusCode, message: $message)';
  }
}
