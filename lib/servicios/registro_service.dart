import '../modelos/api_response.dart';
import 'api_service.dart';

class RegistrarService {
  final ApiService _apiService = ApiService();

  static final RegistrarService _instance = RegistrarService._internal();
  factory RegistrarService() => _instance;
  RegistrarService._internal();

  int? _usuarioId;
  String? _nombre;
  String? _correo;
  String? _nivelExplorador;
  int? _turiPuntos;

  /// Obtener el usuarioId del usuario autenticado
  int? get usuarioId => _usuarioId;
  String? get nombre => _nombre;
  String? get correo => _correo;
  String? get nivelExplorador => _nivelExplorador;
  int? get turiPuntos => _turiPuntos;

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
        body: {'correo': correo, 'contrasena': contrasena},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final token = data['Token'] ?? data['token'];
        if (token != null) {
          _apiService.setToken(token as String);
        }
        final idRaw = data['Id'] ?? data['id'] ?? data['usuarioId'];
        if (idRaw != null) {
          _usuarioId = (idRaw as num).toInt();
        }
        _nombre = data['Nombre'] as String? ?? data['nombre'] as String?;
        _correo = data['Correo'] as String? ?? data['correo'] as String?;
        _nivelExplorador = data['nivelExplorador'] as String?;
        _usuarioId = data['UsuarioId'] != null
            ? (data['UsuarioId'] as num).toInt()
            : _usuarioId;
        if (data['turiPuntos'] != null) {
          _turiPuntos = (data['turiPuntos'] as num).toInt();
        }
      }

      return response;
    } catch (e) {
      return ApiResponse.error('Error al iniciar sesión: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> recuperarContrasena({
    required String correo,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        'Usuario/recuperarContrasena',
        body: {'correo': correo},
        fromJson: (json) => json as Map<String, dynamic>,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Error al recuperar contraseña: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> cambiarContrasenia({
    required String nuevaContrasenia,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        'Usuario/cambiarContraseniaUsuario/$nuevaContrasenia',
        fromJson: (json) => json as Map<String, dynamic>,
        requiresAuth: true,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Error al cambiar contraseña: $e');
    }
  }

  void setToken(String token) {
    _apiService.setToken(token);
  }

  void cerrarSesion() {
    _apiService.clearToken();
    _usuarioId = null;
    _nombre = null;
    _correo = null;
    _nivelExplorador = null;
    _turiPuntos = null;
  }

  /// Obtener el token actual
  String? get token => _apiService.token;

  /// Verificar si el usuario está autenticado
  bool get estaAutenticado => _apiService.token != null;
}
