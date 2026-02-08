import 'package:flutter/material.dart';
import '../inicio_sesion/paises_modal.dart';
import '../../servicios/registro_service.dart';
import '../inicio/inicio.dart';

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
  bool _mostrarContrasena = false;
  bool _mostrarConfirmarContrasena = false;
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
            // Guardar el token si viene en la respuesta
            if (response.data != null && response.data?['Token'] != null) {
              _authService.setToken(response.data!['Token']);
            }

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

  Future<void> _mostrarSelectorPais() async {
    final resultado = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const SelectorPaisDialog();
      },
    );

    if (resultado != null) {
      setState(() {
        _paisSeleccionado = resultado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- TÍTULO ---
              Center(
                child: Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Completa tus datos para registrarte',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),

              const SizedBox(height: 40),

              // --- CAMPO: NOMBRE COMPLETO ---
              _buildLabel("Nombre completo", colors.primary),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  hintText: 'Lucy Caceres',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre completo';
                  }
                  if (value.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // --- CAMPO: CORREO ELECTRÓNICO ---
              _buildLabel("Correo electrónico", colors.primary),
              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo electrónico';
                  }
                  // Validación básica de email
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // --- CAMPO: PAÍS DE ORIGEN ---
              _buildLabel("País de origen", colors.primary),
              TextFormField(
                readOnly: true,
                onTap: _mostrarSelectorPais,
                decoration: InputDecoration(
                  hintText: 'Selecciona tu país',
                  prefixIcon: const Icon(Icons.public),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                ),
                controller: TextEditingController(text: _paisSeleccionado),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona tu país';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // --- CAMPO: CONTRASEÑA ---
              _buildLabel("Contraseña", colors.primary),
              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // --- CAMPO: CONFIRMAR CONTRASEÑA ---
              _buildLabel("Confirmar contraseña", colors.primary),
              TextFormField(
                controller: _confirmarContrasenaController,
                obscureText: !_mostrarConfirmarContrasena,
                decoration: InputDecoration(
                  hintText: '********',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarConfirmarContrasena
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _mostrarConfirmarContrasena =
                            !_mostrarConfirmarContrasena;
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña';
                  }
                  if (value != _contrasenaController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // --- BOTÓN: REGISTRARSE ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registrarUsuario,
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // --- TEXTO: YA TIENES CUENTA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes cuenta?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Inicia sesión',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
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
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }
}
