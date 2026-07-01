import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../modelos/api_response.dart';
import '../modelos/entrada.dart';
import 'api_config.dart';
import 'registro_service.dart';

class EntradaService {
  static String generarCodigo() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    final code =
        List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'TUR-$code';
  }

  static Future<EntradaComprada> registrarEntrada({
    required int destinoId,
    required int cantidadTotal,
    required double montoTotal,
    required String moneda,
    required String codigo,
    required List<DetalleEntrada> detalles,
  }) async {
    final token = RegistrarService().token;
    if (token == null) throw Exception('No hay sesión activa');

    final entrada = EntradaComprada(
      usuarioId: 0,
      destinoId: destinoId,
      cantidadTotal: cantidadTotal,
      montoTotal: montoTotal,
      moneda: moneda,
      codigo: codigo,
      fechaCompra: DateTime.now(),
      detalles: detalles,
    );

    final url = Uri.parse(ApiConfig.buildUrl('Entrada/registrarEntrada'));
    final response = await http
        .post(
          url,
          headers: ApiConfig.getAuthHeaders(token),
          body: jsonEncode(entrada.toJson()),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 401) throw Exception('No autorizado');

    final responseBody = ApiResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (!responseBody.success) {
      throw Exception(responseBody.message.isNotEmpty
          ? responseBody.message
          : 'Error al registrar la entrada');
    }

    if (responseBody.data != null) {
      return EntradaComprada.fromJson(
          responseBody.data as Map<String, dynamic>);
    }

    return entrada;
  }

  static Future<int?> validarCodigo(String codigo) async {
    final token = RegistrarService().token;
    if (token == null) throw Exception('No hay sesión activa');

    final url = Uri.parse(ApiConfig.buildUrl('Entrada/validarCodigo/$codigo'));
    final response = await http
        .get(url, headers: ApiConfig.getAuthHeaders(token))
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 401) throw Exception('No autorizado');
    if (response.statusCode == 404) return null;

    final responseBody = ApiResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (!responseBody.success) return null;

    if (responseBody.data != null) {
      final data = responseBody.data as Map<String, dynamic>;
      return data['entradaId'] as int?;
    }

    return null;
  }

  static Future<void> marcarUsada(int entradaId) async {
    final token = RegistrarService().token;
    if (token == null) return;

    final url =
        Uri.parse(ApiConfig.buildUrl('Entrada/marcarUsada/$entradaId'));
    await http
        .put(url, headers: ApiConfig.getAuthHeaders(token))
        .timeout(ApiConfig.timeout);
  }
}
