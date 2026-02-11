# 📡 Sistema de API - Documentación

Sistema completo para manejar peticiones HTTP a tu API en `http://localhost:5209/api/`

## 📁 Estructura de Archivos

```
lib/
├── modelos/
│   └── api_response.dart       # Modelo para respuestas del API
└── servicios/
    ├── api_config.dart         # Configuración del API (URL base)
    ├── api_service.dart        # Servicio principal HTTP
    ├── api_service_ejemplo.dart # Ejemplos de uso
    └── README_API.md           # Esta documentación
```

## 🚀 Inicio Rápido

### 1. Importar el servicio en tu pantalla

```dart
import 'package:proyecto_fase/servicios/api_service.dart';
import 'package:proyecto_fase/modelos/api_response.dart';
```

### 2. Crear instancia del servicio

```dart
class _MiPantallaState extends State<MiPantalla> {
  final ApiService _apiService = ApiService();

  // ... resto del código
}
```

### 3. Hacer peticiones

```dart
Future<void> obtenerDatos() async {
  final response = await _apiService.get('/destinos');

  if (response.success) {
    print('Datos: ${response.data}');
  } else {
    print('Error: ${response.message}');
  }
}
```

## 📖 Métodos Disponibles

### GET - Obtener datos

```dart
// GET simple
final response = await _apiService.get('/usuarios');

// GET con parámetros de query
final response = await _apiService.get(
  '/usuarios/buscar',
  queryParameters: {
    'nombre': 'Juan',
    'edad': '25',
  },
);

// GET con modelo de datos
final response = await _apiService.get<Map<String, dynamic>>(
  '/usuarios/1',
  fromJson: (json) => json as Map<String, dynamic>,
);
```

### POST - Crear datos

```dart
final response = await _apiService.post(
  '/auth/login',
  body: {
    'correo': 'usuario@ejemplo.com',
    'password': '123456',
  },
);
```

### PUT - Actualizar datos

```dart
final response = await _apiService.put(
  '/usuarios/1',
  body: {
    'nombre': 'Nuevo Nombre',
    'edad': 30,
  },
);
```

### DELETE - Eliminar datos

```dart
final response = await _apiService.delete('/usuarios/1');
```

## 🔐 Autenticación

### Guardar token después del login

```dart
Future<void> _login() async {
  final response = await _apiService.post(
    '/auth/login',
    body: {
      'correo': _correoController.text,
      'password': _passwordController.text,
    },
  );

  if (response.success) {
    // Guardar el token
    final token = response.data?['token'];
    if (token != null) {
      _apiService.setToken(token);
    }
  }
}
```

### Usar token en peticiones autenticadas

```dart
final response = await _apiService.get(
  '/perfil',
  requiresAuth: true, // Incluye el token en los headers
);
```

### Cerrar sesión (limpiar token)

```dart
_apiService.clearToken();
```

## 📊 Manejo de Respuestas

### Estructura de ApiResponse

```dart
class ApiResponse<T> {
  final int statusCode;      // Código HTTP (200, 404, 500, etc.)
  final String message;      // Mensaje del servidor
  final T? data;            // Datos devueltos por el API
  final bool success;       // true si statusCode 200-299
}
```

### Verificar éxito

```dart
final response = await _apiService.get('/usuarios');

// Opción 1: Usando success
if (response.success) {
  print('✅ Operación exitosa');
  print('Datos: ${response.data}');
} else {
  print('❌ Error: ${response.message}');
}

// Opción 2: Usando statusCode
switch (response.statusCode) {
  case 200:
    print('✅ OK');
    break;
  case 400:
    print('⚠️ Petición incorrecta');
    break;
  case 401:
    print('🔒 No autorizado');
    break;
  case 404:
    print('❌ No encontrado');
    break;
  case 500:
    print('💥 Error del servidor');
    break;
}
```

## 🎯 Ejemplos Prácticos

### Login

```dart
Future<void> _iniciarSesion() async {
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
      SnackBar(
        content: Text(response.message),
        backgroundColor: Colors.green,
      ),
    );

    // Navegar a siguiente pantalla
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
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
```

### Registro

```dart
Future<void> _registrarUsuario() async {
  final response = await _apiService.post(
    '/auth/registro',
    body: {
      'nombre': _nombreController.text,
      'correo': _correoController.text,
      'password': _contrasenaController.text,
      'pais': _paisSeleccionado,
    },
  );

  if (response.success) {
    // Registro exitoso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  } else {
    // Error en registro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### Obtener Lista de Destinos

```dart
Future<void> _cargarDestinos() async {
  // Mostrar loading
  setState(() => _isLoading = true);

  final response = await _apiService.get<List<dynamic>>(
    '/destinos',
    requiresAuth: true,
  );

  setState(() => _isLoading = false);

  if (response.success) {
    setState(() {
      _destinos = response.data ?? [];
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );
  }
}
```

### Actualizar Perfil

```dart
Future<void> _actualizarPerfil() async {
  final response = await _apiService.put(
    '/usuarios/${_userId}',
    body: {
      'nombre': _nombreController.text,
      'email': _emailController.text,
      'pais': _paisSeleccionado,
    },
    requiresAuth: true,
  );

  if (response.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

## ⚙️ Configuración

### Cambiar URL del API

Edita el archivo `api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:5209/api';
  // ... resto de configuración
}
```

### Cambiar timeout de peticiones

```dart
class ApiConfig {
  static const Duration timeout = Duration(seconds: 30);
  // ... resto de configuración
}
```

## 🔧 Formato de Respuesta del API

Tu API debe devolver respuestas en este formato:

```json
{
  "statusCode": 200,
  "message": "Operación exitosa",
  "data": {
    // Tus datos aquí
  }
}
```

O alternativamente:

```json
{
  "statusCode": 200,
  "mensaje": "Operación exitosa",  // Acepta "message" o "mensaje"
  "data": {
    // Tus datos aquí
  }
}
```

## ❌ Manejo de Errores

El servicio maneja automáticamente estos errores:

- **Sin conexión a internet**: `statusCode: 0`, mensaje personalizado
- **Error de conexión**: `statusCode: 0`, mensaje personalizado
- **Timeout**: `statusCode: 0`, mensaje de timeout
- **Error del servidor (500)**: Extrae el mensaje del JSON
- **Error del cliente (400, 404, etc.)**: Extrae el mensaje del JSON

```dart
final response = await _apiService.get('/usuarios');

if (response.statusCode == 0) {
  print('Sin conexión a internet');
} else if (response.statusCode >= 400 && response.statusCode < 500) {
  print('Error del cliente: ${response.message}');
} else if (response.statusCode >= 500) {
  print('Error del servidor: ${response.message}');
}
```

## 📝 Notas Importantes

1. ✅ Todas las peticiones incluyen automáticamente headers JSON
2. ✅ Los errores de red se manejan automáticamente
3. ✅ El timeout es de 30 segundos por defecto
4. ✅ El token se mantiene en memoria durante la sesión
5. ⚠️ Recuerda limpiar el token al cerrar sesión
6. ⚠️ Las rutas deben empezar con `/` (ej: `/usuarios`, no `usuarios`)

## 🆘 Solución de Problemas

### Error: "No hay conexión a internet"
- Verifica tu conexión
- Asegúrate de que el servidor esté corriendo en `localhost:5209`

### Error: "Error de conexión con el servidor"
- Verifica que la URL del API sea correcta
- Asegúrate de que el servidor esté activo

### Error: "Error al procesar la respuesta del servidor"
- El servidor no está devolviendo JSON válido
- Verifica el formato de respuesta del servidor

### Token no funciona
- Asegúrate de guardarlo después del login: `_apiService.setToken(token)`
- Usa `requiresAuth: true` en las peticiones que lo necesiten
