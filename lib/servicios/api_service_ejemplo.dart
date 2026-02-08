// EJEMPLO DE USO DEL API SERVICE
// Este archivo muestra cómo usar el ApiService para hacer peticiones HTTP

import 'api_service.dart';
import '../modelos/api_response.dart';

class EjemploApiService {
  final ApiService _apiService = ApiService();

  // ============================================================================
  // EJEMPLO 1: GET - Obtener lista de usuarios
  // ============================================================================
  Future<void> obtenerUsuarios() async {
    final response = await _apiService.get<List<dynamic>>(
      '/usuarios', // Solo la ruta después de http://localhost:5209/api
      requiresAuth: false, // Si requiere token de autenticación
    );

    if (response.success) {
      print('✅ Éxito: ${response.message}');
      print('Datos: ${response.data}');
      print('Status Code: ${response.statusCode}');
    } else {
      print('❌ Error: ${response.message}');
      print('Status Code: ${response.statusCode}');
    }
  }

  // ============================================================================
  // EJEMPLO 2: GET - Obtener un usuario específico con modelo
  // ============================================================================
  Future<void> obtenerUsuarioPorId(int id) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/usuarios/$id',
      fromJson: (json) => json as Map<String, dynamic>,
      requiresAuth: false,
    );

    if (response.success) {
      print('Usuario encontrado: ${response.data}');
      // Acceder a campos específicos
      final nombre = response.data?['nombre'];
      print('Nombre: $nombre');
    } else {
      print('Error: ${response.message}');
    }
  }

  // ============================================================================
  // EJEMPLO 3: GET con parámetros de query
  // ============================================================================
  Future<void> buscarUsuarios(String nombre) async {
    final response = await _apiService.get<List<dynamic>>(
      '/usuarios/buscar',
      queryParameters: {
        'nombre': nombre,
        'activo': 'true',
      },
    );

    if (response.success) {
      print('Usuarios encontrados: ${response.data?.length}');
    }
  }

  // ============================================================================
  // EJEMPLO 4: POST - Crear usuario (Login/Registro)
  // ============================================================================
  Future<void> iniciarSesion(String correo, String password) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/auth/login',
      body: {
        'correo': correo,
        'password': password,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success) {
      print('Login exitoso: ${response.message}');

      // Obtener el token de la respuesta
      final token = response.data?['token'];
      if (token != null) {
        // Guardar el token para futuras peticiones autenticadas
        _apiService.setToken(token);
        print('Token guardado: $token');
      }

      // Obtener datos del usuario
      final usuario = response.data?['usuario'];
      print('Usuario: $usuario');
    } else {
      print('Error de login: ${response.message}');
    }
  }

  // ============================================================================
  // EJEMPLO 5: POST - Registrar usuario
  // ============================================================================
  Future<ApiResponse<Map<String, dynamic>>> registrarUsuario({
    required String nombre,
    required String correo,
    required String password,
    required String pais,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/auth/registro',
      body: {
        'nombre': nombre,
        'correo': correo,
        'password': password,
        'pais': pais,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    // Retornar la respuesta para que el llamador la maneje
    return response;
  }

  // ============================================================================
  // EJEMPLO 6: PUT - Actualizar usuario (requiere autenticación)
  // ============================================================================
  Future<void> actualizarUsuario(int id, Map<String, dynamic> datos) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '/usuarios/$id',
      body: datos,
      fromJson: (json) => json as Map<String, dynamic>,
      requiresAuth: true, // Esta petición requiere token
    );

    if (response.success) {
      print('Usuario actualizado: ${response.message}');
    } else {
      print('Error: ${response.message}');
    }
  }

  // ============================================================================
  // EJEMPLO 7: DELETE - Eliminar usuario
  // ============================================================================
  Future<void> eliminarUsuario(int id) async {
    final response = await _apiService.delete(
      '/usuarios/$id',
      requiresAuth: true,
    );

    if (response.success) {
      print('Usuario eliminado exitosamente');
    } else {
      print('Error al eliminar: ${response.message}');
    }
  }

  // ============================================================================
  // EJEMPLO 8: Manejo completo de errores
  // ============================================================================
  Future<void> ejemploManejoErrores() async {
    final response = await _apiService.get('/destinos');

    // Verificar por statusCode
    switch (response.statusCode) {
      case 200:
        print('✅ Operación exitosa');
        break;
      case 400:
        print('⚠️ Petición incorrecta: ${response.message}');
        break;
      case 401:
        print('🔒 No autorizado: ${response.message}');
        // Redirigir al login
        break;
      case 404:
        print('❌ No encontrado: ${response.message}');
        break;
      case 500:
        print('💥 Error del servidor: ${response.message}');
        break;
      default:
        print('❓ Error desconocido: ${response.message}');
    }

    // O verificar con el flag success
    if (response.success) {
      print('Todo bien 👍');
    } else {
      print('Algo salió mal 👎: ${response.message}');
    }
  }

  // ============================================================================
  // EJEMPLO 9: Cerrar sesión (limpiar token)
  // ============================================================================
  void cerrarSesion() {
    _apiService.clearToken();
    print('Token eliminado, sesión cerrada');
  }
}

// ============================================================================
// CÓMO USAR EN TUS PANTALLAS
// ============================================================================

/*

// En tu pantalla de Login:
import 'package:proyecto_fase/servicios/api_service.dart';

class LoginScreen extends StatefulWidget {
  // ...
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();

  Future<void> _login() async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/auth/login',
      body: {
        'correo': _correoController.text,
        'password': _passwordController.text,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success) {
      // Guardar token
      final token = response.data?['token'];
      if (token != null) {
        _apiService.setToken(token);
      }

      // Mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );

      // Navegar a la siguiente pantalla
      Navigator.pushReplacement(context, ...);
    } else {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

*/
