import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../modelos/destino.dart';
import '../modelos/horario_destino.dart';
import '../modelos/tarifa_destino.dart';
import '../modelos/api_response.dart';
import 'api_config.dart';
import 'registro_service.dart';

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

  /// Crea un nuevo destino junto con sus horarios, tarifas e imágenes.
  ///
  /// Coincide con el DestinoDTO del backend: 'categoria' (nombre) es
  /// obligatorio además de 'categoriaid', y las imágenes se envían como
  /// archivos en los campos 'portada' e 'imagenes' (`IFormFile` / `List<IFormFile>`
  /// en el DTO). horariosDestino/tarifasDestino se envían con la notación
  /// indexada que el model binder de formularios de ASP.NET Core entiende
  /// de forma nativa (horariosDestino[0].campo, tarifasDestino[0].campo).
  static Future<ApiResponse<Map<String, dynamic>>> crearDestino({
    required String nombre,
    required String descripcion,
    required int categoriaId,
    required String categoriaNombre,
    required String departamento,
    required String municipio,
    required double latitud,
    required double longitud,
    XFile? portada,
    List<XFile> imagenes = const [],
    int? tiempoPromedioVisita,
    required int distanciaCheckinPermitida,
    required bool esGratis,
    List<HorarioDestino> horarios = const [],
    List<TarifaDestino> tarifas = const [],
  }) async {
    final token = RegistrarService().token;
    if (token == null) {
      return ApiResponse.error('No hay sesión activa', statusCode: 401);
    }

    final url = Uri.parse(ApiConfig.buildUrl('Destino/crearDestino'));

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['nombre'] = nombre
        ..fields['descripcion'] = descripcion
        ..fields['categoriaid'] = categoriaId.toString()
        ..fields['categoria'] = categoriaNombre
        ..fields['departamento'] = departamento
        ..fields['municipio'] = municipio
        ..fields['latitud'] = latitud.toString()
        ..fields['longitud'] = longitud.toString()
        ..fields['distanciaCheckinPermitida'] = distanciaCheckinPermitida
            .toString()
        ..fields['esgratis'] = esGratis.toString();

      if (tiempoPromedioVisita != null) {
        request.fields['tiempopromediovisita'] = tiempoPromedioVisita
            .toString();
      }

      for (var i = 0; i < horarios.length; i++) {
        final h = horarios[i];
        request.fields['horariosDestino[$i].horarioId'] = h.horarioId
            .toString();
        request.fields['horariosDestino[$i].diaSemana'] = h.diaSemana;
        request.fields['horariosDestino[$i].horaApertura'] = h.horaApertura;
        request.fields['horariosDestino[$i].horaCierre'] = h.horaCierre;
        request.fields['horariosDestino[$i].esCerrado'] = h.esCerrado
            .toString();
      }

      for (var i = 0; i < tarifas.length; i++) {
        final t = tarifas[i];
        request.fields['tarifasDestino[$i].tarifaId'] = t.tarifaId
            .toString();
        request.fields['tarifasDestino[$i].Visitante'] = t.visitante;
        request.fields['tarifasDestino[$i].precio'] = t.precio.toString();
        request.fields['tarifasDestino[$i].moneda'] = t.moneda;
        request.fields['tarifasDestino[$i].descripcion'] = t.descripcion;
      }

      if (portada != null) {
        request.files.add(
          await http.MultipartFile.fromPath('portada', portada.path),
        );
      }

      for (final imagen in imagenes) {
        request.files.add(
          await http.MultipartFile.fromPath('imagenes', imagen.path),
        );
      }

      debugPrint('[DestinoService] POST ${url.toString()}');
      debugPrint(
        '[DestinoService] fields=${request.fields} files=${request.files.map((f) => '${f.field}:${f.filename}').toList()}',
      );

      final streamed = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);

      debugPrint(
        '[DestinoService] respuesta status=${response.statusCode} body=${response.body}',
      );

      final responseBody = response.body.trim();
      if (responseBody.isEmpty) {
        return ApiResponse.error(
          'El servidor no devolvió respuesta',
          statusCode: response.statusCode,
        );
      }

      final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
      return ApiResponse<Map<String, dynamic>>.fromJson(
        jsonResponse,
        fromJsonData: (data) => data as Map<String, dynamic>,
      );
    } on TimeoutException {
      return ApiResponse.error(
        'La petición tardó demasiado. Verifica que el servidor esté encendido y que la IP en ApiConfig.baseUrl sea correcta.',
        statusCode: 408,
      );
    } on SocketException catch (e) {
      return ApiResponse.error(
        'No se pudo conectar con el servidor ($e). Verifica que el dispositivo esté en la misma red y que la IP en ApiConfig.baseUrl sea correcta.',
        statusCode: 0,
      );
    } catch (e) {
      debugPrint('[DestinoService] error: $e');
      return ApiResponse.error('Error al crear el destino: $e');
    }
  }
}
