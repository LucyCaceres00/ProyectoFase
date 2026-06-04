import 'package:flutter/material.dart';
import '../../servicios/registro_service.dart';

class ModalContrasenia {
  static Future<void> mostrar(BuildContext context) async {
    final correoCtrl = TextEditingController();
    bool cargando = false;
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          Future<void> enviar() async {
            final correo = correoCtrl.text.trim();
            if (correo.isEmpty) {
              setStateDialog(() => error = 'Por favor ingresa tu correo');
              return;
            }
            if (!correo.contains('@') || !correo.contains('.')) {
              setStateDialog(() => error = 'Ingresa un correo válido');
              return;
            }

            setStateDialog(() {
              cargando = true;
              error = null;
            });

            final response = await RegistrarService().recuperarContrasena(
              correo: correo,
            );

            if (!ctx.mounted) return;
            setStateDialog(() => cargando = false);

            if (response.success) {
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      response.message.isNotEmpty
                          ? response.message
                          : 'Revisa tu correo para continuar',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            } else {
              setStateDialog(
                () => error = response.message.isNotEmpty
                    ? response.message
                    : 'No se pudo enviar el correo. Intenta de nuevo.',
              );
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: Icon(
              Icons.lock_reset_outlined,
              size: 44,
              color: Theme.of(ctx).colorScheme.primary,
            ),
            title: const Text(
              'Recuperar contraseña',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingresa tu correo electrónico y recibirás instrucciones para restablecer tu contraseña.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !cargando,
                  decoration: InputDecoration(
                    hintText: 'tu@ejemplo.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(ctx).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: cargando ? null : () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: cargando ? null : enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Enviar'),
              ),
            ],
          );
        },
      ),
    );

    correoCtrl.dispose();
  }
}
