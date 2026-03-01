import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/api_response.dart';
import '../modelos/estado_visita.dart';
import 'api_config.dart';
import 'registro_service.dart';

class VisitaService {
  static String _cacheKey(int usuarioId, int destinoId) =>
      'visita_pendiente_${usuarioId}_$destinoId';

  // ── Cache local ────────────────────────────────────────────────────────────

  static Future<bool> leerCachePendiente(int usuarioId, int destinoId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cacheKey(usuarioId, destinoId)) ?? false;
  }

  static Future<void> guardarCachePendiente(int usuarioId, int destinoId, bool pendiente) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cacheKey(usuarioId, destinoId), pendiente);
  }

  // ── API ────────────────────────────────────────────────────────────────────

  static Future<void> guardarVisita({
    required int usuarioId,
    required int destinoId,
    required double latitud,
    required double longitud,
  }) async {
    final token = RegistrarService().token;
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final url = Uri.parse(ApiConfig.buildUrl('Visita/guardarVisita'));

    final body = jsonEncode({
      'usuarioId': usuarioId,
      'fechaVisita': DateTime.now().toIso8601String(),
      'destinoId': destinoId,
      'latitud': latitud,
      'longitud': longitud,
    });

    final response = await http
        .post(url, headers: ApiConfig.getAuthHeaders(token), body: body)
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 401) {
      throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
    }

    final responseBody = ApiResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (!responseBody.success) {
      throw Exception(responseBody.message.isNotEmpty
          ? responseBody.message
          : 'Error al guardar la visita');
    }

    // Marcar en cache que tiene reseña pendiente
    await guardarCachePendiente(usuarioId, destinoId, true);
  }

  /// Verifica si el usuario tiene una visita sin reseña.
  /// Endpoint: GET /api/Visita/obtenerEstadoVisita/{usuarioId}/{destinoId}
  static Future<EstadoVisita> obtenerEstadoVisita({
    required int usuarioId,
    required int destinoId,
  }) async {
    final token = RegistrarService().token;
    if (token == null) {
      final pendienteCache = await leerCachePendiente(usuarioId, destinoId);
      return EstadoVisita(tieneVisitaPendiente: pendienteCache);
    }

    try {
      final url = Uri.parse(
        ApiConfig.buildUrl('Visita/obtenerEstadoVisita/$usuarioId/$destinoId'),
      );

      final response = await http
          .get(url, headers: ApiConfig.getAuthHeaders(token))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final responseBody = ApiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        if (responseBody.success && responseBody.data != null) {
          final estado = EstadoVisita.fromJson(
            responseBody.data as Map<String, dynamic>,
          );
          // Sincronizar cache con respuesta del API
          await guardarCachePendiente(usuarioId, destinoId, estado.tieneVisitaPendiente);
          return estado;
        }
      }
    } catch (_) {
      // Si falla el API, usar cache local
    }

    final pendienteCache = await leerCachePendiente(usuarioId, destinoId);
    return EstadoVisita(tieneVisitaPendiente: pendienteCache);
  }
}
