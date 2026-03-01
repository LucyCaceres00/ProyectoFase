import '../modelos/api_response.dart';
import 'api_service.dart';

class RegistrarService {
  final ApiService _apiService = ApiService();

  // Singleton para mantener una única instancia
  static final RegistrarService _instance = RegistrarService._internal();
  factory RegistrarService() => _instance;
  RegistrarService._internal();

  int? _usuarioId;

  /// Obtener el usuarioId del usuario autenticado
  int? get usuarioId => _usuarioId;

  Future<ApiResponse<Map<String, dynamic>>> registrarUsuario({
    required String nombre,
    required String correo,
    required String contrasena,
    required String pais,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        'Usuario/registrarUsuario',
        body: {
          'Id': 0,
          'Nombre': nombre,
          'Contrasena': contrasena,
          'Pais': pais,
          'Correo': correo,
          'Foto': '',
          'NivelExplorador': '',
          'TuriPuntos': 0,
          'Estado': '',
          'FechaCreacion': null,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse.error('Error al registrar usuario: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        'Authentication/login',
        body: {'Correo': correo, 'Contrasena': contrasena},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        if (response.data!['Token'] != null) {
          _apiService.setToken(response.data!['Token']);
        }
        if (response.data!['Id'] != null) {
          _usuarioId = response.data!['Id'] as int;
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error('Error al iniciar sesión: $e');
    }
  }

  void setToken(String token) {
    _apiService.setToken(token);
  }

  void cerrarSesion() {
    _apiService.clearToken();
    _usuarioId = null;
  }

  /// Obtener el token actual
  String? get token => _apiService.token;

  /// Verificar si el usuario está autenticado
  bool get estaAutenticado => _apiService.token != null;
}
