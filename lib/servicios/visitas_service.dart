import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/visita.dart';
import 'api_config.dart';
import 'registro_service.dart';

class VisitasService {
  static Future<List<Visita>> obtenerVisitasUsuario() async {
    final token = RegistrarService().token;
    final headers = token != null
        ? ApiConfig.getAuthHeaders(token)
        : ApiConfig.defaultHeaders;

    final url = Uri.parse(ApiConfig.buildUrl('Visita/obtenerVisitasUsuario'));

    final response = await http
        .get(url, headers: headers)
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['Data'] as List<dynamic>? ?? [];
      return data.asMap().entries.map((e) {
        final json = Map<String, dynamic>.from(e.value as Map<String, dynamic>);
        return Visita.fromJson(json);
      }).toList();
    }

    throw Exception('Error al obtener el ranking: ${response.statusCode}');
  }
}
