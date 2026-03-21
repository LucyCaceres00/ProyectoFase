import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/usuario_perfil.dart';
import 'api_config.dart';
import 'registro_service.dart';

class PerfilService {
  static Future<UsuarioPerfil> obtenerInformacionUsuario() async {
    final token = RegistrarService().token;
    final headers = token != null
        ? ApiConfig.getAuthHeaders(token)
        : ApiConfig.defaultHeaders;

    final url = Uri.parse(ApiConfig.buildUrl('Usuario/obtenerInformacionUsuario'));

    final response = await http
        .get(url, headers: headers)
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final lista = body['Data'] as List<dynamic>;
      return UsuarioPerfil.fromJson(lista.first as Map<String, dynamic>);
    }

    throw Exception('Error al obtener el perfil: ${response.statusCode}');
  }
}
