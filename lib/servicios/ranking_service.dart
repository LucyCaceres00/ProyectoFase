import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/ranking_usuario.dart';
import 'api_config.dart';
import 'registro_service.dart';

class RankingService {
  static Future<List<RankingUsuario>> obtenerRanking() async {
    final token = RegistrarService().token;
    final headers = token != null
        ? ApiConfig.getAuthHeaders(token)
        : ApiConfig.defaultHeaders;

    final url = Uri.parse(ApiConfig.buildUrl('Ranking/obtenerRanking'));

    final response = await http
        .get(url, headers: headers)
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['Data'] as List<dynamic>? ?? [];
      return data
          .asMap()
          .entries
          .map((e) {
            final json = e.value as Map<String, dynamic>;
            json['posicion'] = json['posicion'] ?? (e.key + 1);
            return RankingUsuario.fromJson(json);
          })
          .toList();
    }

    throw Exception('Error al obtener el ranking: ${response.statusCode}');
  }
}
