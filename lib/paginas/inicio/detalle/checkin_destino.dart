import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';
import '../../../modelos/estado_visita.dart';
import '../../../servicios/ubicacion_service.dart';
import '../../../servicios/visita_service.dart';
import '../../../servicios/registro_service.dart';
import '../../../widgets/app_dialogo.dart';
import '../../resena/resena_screen.dart';

class CheckinDestino extends StatefulWidget {
  final Destino destino;
  const CheckinDestino({super.key, required this.destino});

  @override
  State<CheckinDestino> createState() => _CheckinDestinoState();
}

class _CheckinDestinoState extends State<CheckinDestino> {
  EstadoVisita? _estadoVisita;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    setState(() => _cargando = true);
    final usuarioId = RegistrarService().usuarioId ?? 0;

    final pendienteCache = await VisitaService.leerCachePendiente(
      usuarioId,
      widget.destino.destinoid,
    );
    if (mounted) {
      setState(() {
        _estadoVisita = EstadoVisita(tieneReseniaPendiente: pendienteCache);
        _cargando = false;
      });
    }

    try {
      final estado = await VisitaService.obtenerEstadoVisita(
        usuarioId: usuarioId,
        destinoId: widget.destino.destinoid,
      );
      if (mounted) setState(() => _estadoVisita = estado);
    } catch (_) {}
  }

  String? _validarHorario() {
    final horarios = widget.destino.horariosDestino;
    if (horarios == null || horarios.isEmpty) return null;

    final dias = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    final diaActual = dias[DateTime.now().weekday % 7];

    final horarioHoy = horarios.firstWhere(
      (h) => h.diaSemana == diaActual,
      orElse: () => horarios.first,
    );

    if (horarioHoy.esCerrado) {
      return '${widget.destino.nombre} está cerrado hoy ($diaActual). No es posible hacer check-in.';
    }

    TimeOfDay parsearHora(String hora) {
      final texto = hora.trim().toUpperCase();
      final esAm = texto.contains('AM');
      final esPm = texto.contains('PM');
      final soloHora = texto.replaceAll('AM', '').replaceAll('PM', '').trim();
      final partes = soloHora.split(':');
      int horas = int.parse(partes[0].trim());
      final minutos = partes.length > 1 ? int.parse(partes[1].trim()) : 0;
      if (esAm || esPm) {
        if (esAm && horas == 12) horas = 0;
        if (esPm && horas != 12) horas += 12;
      }
      return TimeOfDay(hour: horas, minute: minutos);
    }

    final ahora = TimeOfDay.now();
    final apertura = parsearHora(horarioHoy.horaApertura);
    final cierre = parsearHora(horarioHoy.horaCierre);

    final ahoraMin = ahora.hour * 60 + ahora.minute;
    final aperturaMin = apertura.hour * 60 + apertura.minute;
    final cierreMin = cierre.hour * 60 + cierre.minute;

    if (ahoraMin < aperturaMin) {
      return '${widget.destino.nombre} aún no ha abierto. Abre a las ${horarioHoy.horaApertura.trim()}.';
    }
    if (ahoraMin > cierreMin) {
      return '${widget.destino.nombre} ya cerró hoy. El horario de cierre fue a las ${horarioHoy.horaCierre.trim()}.';
    }

    return null;
  }

  Future<void> _hacerCheckin() async {
    final errorHorario = _validarHorario();
    if (errorHorario != null) {
      AppDialogo.mostrar(
        context,
        icono: Icons.access_time_rounded,
        titulo: 'Fuera de horario',
        mensaje: errorHorario,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final resultado = await UbicacionService.verificarCercania(
        widget.destino,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (resultado.error != null) {
        AppDialogo.mostrar(
          context,
          icono: Icons.location_off_outlined,
          titulo: 'Ubicación requerida',
          mensaje: resultado.error!,
        );
        return;
      }

      if (resultado.permitido) {
        _mostrarConfirmacion(resultado);
      } else {
        AppDialogo.mostrar(
          context,
          icono: Icons.location_off_outlined,
          titulo: 'Fuera de rango',
          mensaje:
              'Actualmente se encuentra fuera de la distancia permitida para registrar la visita a ${widget.destino.nombre}, intente nuevamente al estar más cerca.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

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

      AppDialogo.mostrar(
        context,
        icono: Icons.error_outline,
        titulo: 'Error',
        mensaje: mensaje,
      );
    }
  }

  void _mostrarConfirmacion(ResultadoUbicacion resultado) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.location_on,
          size: 48,
          color: AppTheme.primaryColor,
        ),
        title: const Text(
          'Confirmar visita',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Tu ubicación está dentro de la distancia válida para hacer check-in en ${widget.destino.nombre}.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _registrarVisita(resultado);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirmar visita',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registrarVisita(ResultadoUbicacion resultado) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final usuarioId = RegistrarService().usuarioId ?? 0;

      await VisitaService.guardarVisita(
        usuarioId: usuarioId,
        destinoId: widget.destino.destinoid,
        latitud: resultado.latitud!,
        longitud: resultado.longitud!,
      );

      if (!mounted) return;
      Navigator.pop(context);

      setState(() {
        _estadoVisita = EstadoVisita(tieneReseniaPendiente: true);
      });

      AppDialogo.mostrarExito(
        context,
        titulo: '¡Visita registrada!',
        mensaje:
            'Tu visita a ${widget.destino.nombre} fue registrada. ¡Comparte tu experiencia escribiendo una reseña!',
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      final esNoAutorizado =
          e.toString().contains('No autorizado') ||
          e.toString().contains('sesión');

      AppDialogo.mostrar(
        context,
        icono: esNoAutorizado ? Icons.lock_outline : Icons.error_outline,
        titulo: esNoAutorizado ? 'Sesión requerida' : 'Error al registrar',
        mensaje: esNoAutorizado
            ? 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'
            : 'No se pudo registrar la visita. Por favor, intente nuevamente.',
      );
    }
  }

  Future<void> _abrirResena() async {
    final resenaGuardada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ResenaScreen(destino: widget.destino)),
    );

    if (resenaGuardada == true && mounted) {
      setState(() {
        _estadoVisita = EstadoVisita(tieneReseniaPendiente: false);
      });
    }
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
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _estadoVisita?.tieneReseniaPendiente == true
            ? _botonResena()
            : _botonCheckin(),
      ),
    );
  }

  Widget _botonCheckin() {
    return ElevatedButton(
      onPressed: _hacerCheckin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    );
  }

  Widget _botonResena() {
    return ElevatedButton(
      onPressed: _abrirResena,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Escribir Reseña',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
