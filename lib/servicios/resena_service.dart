import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../modelos/api_response.dart';
import '../modelos/resena.dart';
import 'api_config.dart';
import 'registro_service.dart';

class ResenaService {
  static Future<void> guardarResena(Resena resena, {List<XFile> imagenes = const []}) async {
    final token = RegistrarService().token;
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final url = Uri.parse(ApiConfig.buildUrl('Resenia/insertarResenia'));

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll(resena.toJson().map((k, v) => MapEntry(k, v.toString())));

    for (final img in imagenes) {
      request.files.add(await http.MultipartFile.fromPath('imagenes', img.path));
    }

    final streamed = await request.send().timeout(ApiConfig.timeout);
    final response = await http.Response.fromStream(streamed);

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
