import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/destino.dart';
import 'api_config.dart';

class DestinoService {
  static Future<List<Destino>> obtenerDestinos() async {
    final url = Uri.parse(ApiConfig.buildUrl('Destino/obtenerDestinos'));

    final response = await http
        .get(url, headers: ApiConfig.defaultHeaders)
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['Data'] ?? [];
      return data.map((json) => Destino.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener destinos: ${response.statusCode}');
    }
  }

  static Future<Destino> obtenerDestinoPorId(int id) async {
    final destinos = await obtenerDestinos();
    return destinos.firstWhere((d) => d.destinoid == id);
  }
}
