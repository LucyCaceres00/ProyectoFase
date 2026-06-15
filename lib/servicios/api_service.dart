import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../modelos/api_response.dart';
import 'api_config.dart';

class ApiService {
  String? _token;

  // Setear para el token
  void setToken(String token) {
    _token = token;
  }

  // Obtener el token
  String? get token => _token;

  // Limpiar token
  void clearToken() {
    _token = null;
  }

  // Obtener headers
  Map<String, String> _getHeaders({bool includeAuth = false}) {
    if (includeAuth && _token != null) {
      return ApiConfig.getAuthHeaders(_token!);
    }
    return ApiConfig.defaultHeaders;
  }

  // GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.buildUrl(endpoint));
      final urlWithParams = queryParameters != null
          ? url.replace(queryParameters: queryParameters)
          : url;

      final response = await http
          .get(urlWithParams, headers: _getHeaders(includeAuth: requiresAuth))
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse.error(
        'La petición tardó demasiado. Verifica tu conexión o intenta más tarde.',
        statusCode: 408,
      );
    } on SocketException {
      return ApiResponse.error('No hay conexión a internet', statusCode: 0);
    } on http.ClientException {
      return ApiResponse.error(
        'Error de conexión con el servidor',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error('Error inesperado: $e', statusCode: 500);
    }
  }

  // POST Request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.buildUrl(endpoint));
      final response = await http
          .post(
            url,
            headers: _getHeaders(includeAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse.error(
        'La petición tardó demasiado. Verifica tu conexión o intenta más tarde.',
        statusCode: 408,
      );
    } on SocketException {
      return ApiResponse.error('No hay conexión a internet', statusCode: 0);
    } on http.ClientException {
      return ApiResponse.error(
        'Error de conexión con el servidor',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error('Error inesperado: $e', statusCode: 500);
    }
  }

  // PUT Request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.buildUrl(endpoint));

      final response = await http
          .put(
            url,
            headers: _getHeaders(includeAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse.error(
        'La petición tardó demasiado. Verifica tu conexión o intenta más tarde.',
        statusCode: 408,
      );
    } on SocketException {
      return ApiResponse.error('No hay conexión a internet', statusCode: 0);
    } on http.ClientException {
      return ApiResponse.error(
        'Error de conexión con el servidor',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error('Error inesperado: $e', statusCode: 500);
    }
  }
  
  // Manejar respuesta HTTP
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(jsonResponse, fromJsonData: fromJson);
      } else {
        // Error del servidor
        final message =
            jsonResponse['message'] ??
            jsonResponse['Message'] ??
            'Error en la petición';
        return ApiResponse.error(message, statusCode: response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error(
        'Error al procesar la respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }
}
