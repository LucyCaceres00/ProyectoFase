import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../modelos/destino.dart';
import 'destino_detalle.dart';

class ModalDestinoAleatorio extends StatefulWidget {
  final List<Destino> destinos;
  const ModalDestinoAleatorio({super.key, required this.destinos});

  @override
  State<ModalDestinoAleatorio> createState() => _ModalDestinoAleatorioState();
}

class _ModalDestinoAleatorioState extends State<ModalDestinoAleatorio>
    with SingleTickerProviderStateMixin {
  late int _indiceActual;
  late int _indiceGanador;
  late AnimationController _controladorEscala;
  late Animation<double> _animacionEscala;
  Timer? _timer;
  bool _finalizado = false;
  int _pasos = 0;
  final int _totalPasos = 20;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _indiceActual = random.nextInt(widget.destinos.length);
    _indiceGanador = random.nextInt(widget.destinos.length);

    _controladorEscala = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animacionEscala = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controladorEscala, curve: Curves.elasticOut),
    );

    _iniciarAnimacion();
  }

  void _iniciarAnimacion() {
    _siguientePaso();
  }

  void _siguientePaso() {
    if (_pasos >= _totalPasos) {
      // Último paso: mostrar el ganador
      setState(() {
        _indiceActual = _indiceGanador;
        _finalizado = true;
      });
      _controladorEscala.forward();
      return;
    }

    // Calcular delay: empieza rápido y desacelera
    final progreso = _pasos / _totalPasos;
    final delay = (50 + (progreso * progreso * 400)).toInt();

    _timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        _indiceActual = (_indiceActual + 1) % widget.destinos.length;
        _pasos++;
      });
      _siguientePaso();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controladorEscala.dispose();
    super.dispose();
  }

  Destino get _destinoActual => widget.destinos[_indiceActual];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              _finalizado ? 'Tu destino es...' : 'Buscando destino...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Imagen con efecto
            ScaleTransition(
              scale: _finalizado ? _animacionEscala : const AlwaysStoppedAnimation(1.0),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _finalizado ? AppTheme.surfaceColor : Colors.grey[300]!,
                    width: _finalizado ? 3 : 1,
                  ),
                  boxShadow: _finalizado
                      ? [
                          BoxShadow(
                            color: AppTheme.surfaceColor.withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _destinoActual.imagenprincipal != null
                      ? Image.network(
                          _destinoActual.imagenprincipal!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nombre del destino
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                _destinoActual.nombre,
                key: ValueKey(_indiceActual),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textoOscuro,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_finalizado) ...[
              const SizedBox(height: 8),
              Text(
                '${_destinoActual.municipio}, ${_destinoActual.departamento}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textoSuave,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DestinoDetalleScreen(destino: _destinoActual),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Ver destino',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
            if (!_finalizado) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
