# 🔐 RegistrarService - Servicio de Autenticación

Servicio especializado para manejar registro, login y autenticación de usuarios.

## 📋 Métodos Disponibles

### 1. registrarUsuario()

Registra un nuevo usuario en el sistema.

**Endpoint:** `Usuario/registrarUsuario`

**Parámetros:**
```dart
Future<ApiResponse<Map<String, dynamic>>> registrarUsuario({
  required String nombre,      // Nombre completo del usuario
  required String correo,      // Correo electrónico
  required String contrasena,  // Contraseña
  required String pais,        // País de origen
})
```

**Body enviado al API:**
```json
{
  "Nombre": "Lucy Caceres",
  "Contrasena": "miPassword123",
  "Pais": "Perú",
  "Correo": "lucy@ejemplo.com"
}
```

**Ejemplo de uso:**
```dart
final RegistrarService _authService = RegistrarService();

Future<void> _registrarUsuario() async {
  final response = await _authService.registrarUsuario(
    nombre: _nombreController.text.trim(),
    correo: _correoController.text.trim(),
    contrasena: _contrasenaController.text,
    pais: _paisSeleccionado!,
  );

  if (response.success) {
    // ✅ Registro exitoso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  } else {
    // ❌ Error en el registro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

### 2. iniciarSesion()

Inicia sesión con correo y contraseña.

**Endpoint:** `Usuario/login` *(ajusta según tu API)*

**Parámetros:**
```dart
Future<ApiResponse<Map<String, dynamic>>> iniciarSesion({
  required String correo,      // Correo electrónico
  required String contrasena,  // Contraseña
})
```

**Body enviado al API:**
```json
{
  "Correo": "lucy@ejemplo.com",
  "Contrasena": "miPassword123"
}
```

**Ejemplo de uso:**
```dart
final RegistrarService _authService = RegistrarService();

Future<void> _iniciarSesion() async {
  final response = await _authService.iniciarSesion(
    correo: _correoController.text.trim(),
    contrasena: _passwordController.text,
  );

  if (response.success) {
    // ✅ Login exitoso

    // El token ya fue guardado automáticamente
    final usuario = response.data?['usuario'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message)),
    );

    // Navegar a pantalla principal
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExplorarDestinosScreen(),
      ),
    );
  } else {
    // ❌ Error en login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

### 3. cerrarSesion()

Cierra la sesión del usuario y limpia el token.

**Ejemplo de uso:**
```dart
final RegistrarService _authService = RegistrarService();

void _cerrarSesion() {
  _authService.cerrarSesion();

  // Navegar al login
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
    (route) => false,
  );
}
```

---

### 4. estaAutenticado (getter)

Verifica si el usuario tiene un token activo.

**Ejemplo de uso:**
```dart
final RegistrarService _authService = RegistrarService();

@override
void initState() {
  super.initState();

  // Verificar si ya está autenticado
  if (_authService.estaAutenticado) {
    // Ya tiene sesión activa
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }
}
```

---

### 5. token (getter)

Obtiene el token actual del usuario.

**Ejemplo de uso:**
```dart
final RegistrarService _authService = RegistrarService();

String? obtenerToken() {
  return _authService.token;
}
```

---

## 📊 Formato de Respuesta Esperado del API

### Registro Exitoso
```json
{
  "statusCode": 200,
  "message": "Usuario registrado exitosamente",
  "data": {
    "id": 123,
    "nombre": "Lucy Caceres",
    "correo": "lucy@ejemplo.com",
    "pais": "Perú"
  }
}
```

### Login Exitoso
```json
{
  "statusCode": 200,
  "message": "Login exitoso",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "usuario": {
      "id": 123,
      "nombre": "Lucy Caceres",
      "correo": "lucy@ejemplo.com"
    }
  }
}
```

### Error
```json
{
  "statusCode": 400,
  "message": "El correo ya está registrado",
  "data": null
}
```

---

## 🎯 Implementación Completa en Pantalla de Registro

Aquí está el ejemplo completo de cómo se implementó en `registro.dart`:

```dart
import 'package:flutter/material.dart';
import '../../servicios/auth_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  final RegistrarService _authService = RegistrarService();

  String? _paisSeleccionado;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      // Mostrar loading
      setState(() {
        _isLoading = true;
      });

      try {
        // Llamar al servicio de registro
        final response = await _authService.registrarUsuario(
          nombre: _nombreController.text.trim(),
          correo: _correoController.text.trim(),
          contrasena: _contrasenaController.text,
          pais: _paisSeleccionado!,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          // Registro exitoso
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                backgroundColor: Colors.green,
              ),
            );

            // Volver al login
            Navigator.pop(context);
          }
        } else {
          // Error en el registro
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ... campos del formulario ...

            // Botón con loading
            ElevatedButton(
              onPressed: _isLoading ? null : _registrarUsuario,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔧 Casos de Uso Comunes

### Verificar autenticación al iniciar la app

```dart
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final RegistrarService _authService = RegistrarService();

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_authService.estaAutenticado) {
      // Ya tiene sesión activa
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // No tiene sesión, ir al login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

### Proteger rutas que requieren autenticación

```dart
class PerfilScreen extends StatefulWidget {
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final RegistrarService _authService = RegistrarService();

  @override
  void initState() {
    super.initState();
    _verificarAutenticacion();
  }

  void _verificarAutenticacion() {
    if (!_authService.estaAutenticado) {
      // No está autenticado, redirigir al login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _authService.cerrarSesion();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Perfil del Usuario'),
      ),
    );
  }
}
```

---

## ⚠️ Notas Importantes

1. **Singleton Pattern**: `RegistrarService` usa el patrón Singleton, por lo que siempre tendrás la misma instancia y el mismo token en toda la app.

2. **Token Automático**: Cuando el login es exitoso, el token se guarda automáticamente. No necesitas hacerlo manualmente.

3. **Campo Id**: El campo `"Id": 0` no se envía en el registro porque no es necesario (el servidor lo genera).

4. **Campos Opcionales**: Los campos que no están en el formulario (Foto, NivelExplorador, TuriPuntos, Estado, FechaCreacion) no se envían porque el servidor debe asignarles valores por defecto.

5. **Trim en strings**: Siempre usa `.trim()` en los campos de texto para eliminar espacios en blanco.

6. **Validación**: Valida el formulario antes de hacer la petición para asegurar que todos los campos requeridos estén completos.

7. **Loading State**: Siempre muestra un indicador de carga mientras se procesa la petición para mejorar la UX.

8. **mounted check**: Usa `if (mounted)` antes de actualizar el estado o mostrar SnackBars después de operaciones asíncronas.
