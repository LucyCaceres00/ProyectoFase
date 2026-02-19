import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';
import '../../../servicios/ubicacion_service.dart';

class CheckinDestino extends StatelessWidget {
  final Destino destino;
  const CheckinDestino({super.key, required this.destino});

  Future<void> _hacerCheckin(BuildContext context) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final resultado = await UbicacionService.verificarCercania(destino);

      if (!context.mounted) return;
      Navigator.pop(context); // Cerrar loading

      if (resultado.error != null) {
        _mostrarDialogo(
          context,
          icono: Icons.location_off_outlined,
          titulo: 'Ubicación requerida',
          mensaje: resultado.error!,
        );
        return;
      }

      if (resultado.permitido) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-in registrado en ${destino.nombre}'),
            backgroundColor: AppTheme.colorExito,
          ),
        );
      } else {
        _mostrarDialogo(
          context,
          icono: Icons.location_off_outlined,
          titulo: 'Fuera de rango',
          mensaje:
              'Actualmente se encuentra fuera de la distancia permitida para registrar la visita a ${destino.nombre}, intente nuevamente al estar más cerca.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Cerrar loading

      String mensaje;
      if (e.toString().contains('permission') ||
          e.toString().contains('Permission')) {
        mensaje =
            'Se necesita permiso de ubicación para hacer check-in. Habilítelo desde la configuración del dispositivo.';
      } else if (e.toString().contains('location service') ||
          e.toString().contains('LocationService')) {
        mensaje =
            'El servicio de ubicación está desactivado. Actívelo para continuar.';
      } else {
        mensaje =
            'No se pudo obtener la ubicación. Verifique que el GPS esté activado y los permisos otorgados, luego intente nuevamente.';
      }

      _mostrarDialogo(
        context,
        icono: Icons.error_outline,
        titulo: 'Error',
        mensaje: mensaje,
      );
    }
  }

  void _mostrarDialogo(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String mensaje,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(icono, size: 48, color: AppTheme.primaryColor),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Entendido',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => _hacerCheckin(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.surfaceColor,
            foregroundColor: AppTheme.textoOscuro,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 20),
              SizedBox(width: 8),
              Text(
                'Hacer Check-in',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
