import 'package:flutter/material.dart';
import '../../servicios/registro_service.dart';

class ModalContrasenia {
  static Future<void> mostrar(BuildContext context) async {
    final mensaje = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _RecuperarContraseniaDialog(),
    );

    if (mensaje != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

class _RecuperarContraseniaDialog extends StatefulWidget {
  const _RecuperarContraseniaDialog();

  @override
  State<_RecuperarContraseniaDialog> createState() =>
      _RecuperarContraseniaDialogState();
}

class _RecuperarContraseniaDialogState
    extends State<_RecuperarContraseniaDialog> {
  final _correoCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final correo = _correoCtrl.text.trim();
    if (correo.isEmpty) {
      setState(() => _error = 'Por favor ingresa tu correo');
      return;
    }
    if (!correo.contains('@') || !correo.contains('.')) {
      setState(() => _error = 'Ingresa un correo válido');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    final response = await RegistrarService().recuperarContrasena(
      correo: correo,
    );

    if (!mounted) return;

    if (response.success) {
      Navigator.pop(
        context,
        response.message.isNotEmpty
            ? response.message
            : 'Revisa tu correo para continuar',
      );
    } else {
      setState(() {
        _cargando = false;
        _error = response.message.isNotEmpty
            ? response.message
            : 'No se pudo enviar el correo. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      icon: Icon(
        Icons.lock_reset_outlined,
        size: 44,
        color: Theme.of(context).colorScheme.primary,
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
            controller: _correoCtrl,
            keyboardType: TextInputType.emailAddress,
            enabled: !_cargando,
            decoration: InputDecoration(
              hintText: 'tu@ejemplo.com',
              prefixIcon: const Icon(Icons.email_outlined),
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _cargando ? null : _enviar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _cargando
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
  }
}
