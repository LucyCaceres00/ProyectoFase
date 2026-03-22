import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_fase/modelos/resena.dart';
import 'api_config.dart';
import 'registro_service.dart';

class ResenasService {
  static Future<List<Resena>> obtenerReseniasUsuario() async {
    final token = RegistrarService().token;
    final headers = token != null
        ? ApiConfig.getAuthHeaders(token)
        : ApiConfig.defaultHeaders;

    final url = Uri.parse(ApiConfig.buildUrl('Resenia/obtenerReseniasUsuario'));

    final response = await http
        .get(url, headers: headers)
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['Data'] as List<dynamic>? ?? [];
      return data.asMap().entries.map((e) {
        final json = Map<String, dynamic>.from(e.value as Map<String, dynamic>);
        return Resena.fromJson(json);
      }).toList();
    }

    throw Exception('Error al obtener el ranking: ${response.statusCode}');
  }
}
