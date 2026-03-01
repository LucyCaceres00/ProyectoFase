import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/api_response.dart';
import '../modelos/resena.dart';
import 'api_config.dart';
import 'registro_service.dart';

class ResenaService {
  static Future<void> guardarResena(Resena resena) async {
    final token = RegistrarService().token;
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final url = Uri.parse(ApiConfig.buildUrl('Resena/guardarResena'));

    final response = await http
        .post(
          url,
          headers: ApiConfig.getAuthHeaders(token),
          body: jsonEncode(resena.toJson()),
        )
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
          : 'Error al guardar la reseña');
    }
  }
}
