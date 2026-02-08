import 'package:flutter/material.dart';
import '../inicio/inicio.dart';
import '../inicio_sesion/registro.dart';
import '../../servicios/registro_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final RegistrarService _authService = RegistrarService();
  bool _isLoading = false;
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    // Validación básica
    if (_correoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu correo electrónico'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Llamar al servicio de inicio de sesión
      final response = await _authService.iniciarSesion(
        correo: _correoController.text.trim(),
        contrasena: _contrasenaController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        // Login exitoso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar a la pantalla principal (ExplorarDestinosScreen)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ExplorarDestinosScreen(),
            ),
            (route) => false,
          );
        }
      } else {
        // Error en el login
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),

            Image.asset(
              'imagenes/toori_logo_letras.png',
              height: 200,
              fit: BoxFit.contain,
              cacheHeight: 400,
            ),

            _buildLabel("Correo electrónico", colors.primary),
            TextField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'tu@ejemplo.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- CAMPO: CONTRASEÑA ---
            _buildLabel("Contraseña", colors.primary),
            TextField(
              controller: _contrasenaController,
              obscureText: !_mostrarContrasena,
              decoration: InputDecoration(
                hintText: '********',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarContrasena
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _mostrarContrasena = !_mostrarContrasena;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- BOTÓN: INICIAR SESIÓN ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿No tienes cuenta?',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Regístrate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper para las etiquetas arriba de los inputs
  Widget _buildLabel(String text, Color color) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
