import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../modelos/destino.dart';
import '../../servicios/destino_service.dart';
import 'detalle/encabezado_destino.dart';
import 'detalle/identidad_destino.dart';
import 'detalle/descripcion_destino.dart';
import 'detalle/horarios_destino.dart';
import 'detalle/tarifas_destino.dart';
import 'detalle/mapa_destino.dart';
import 'detalle/checkin_destino.dart';

class DestinoDetalleScreen extends StatefulWidget {
  final Destino destino;
  const DestinoDetalleScreen({super.key, required this.destino});

  @override
  State<DestinoDetalleScreen> createState() => _DestinoDetalleScreenState();
}

class _DestinoDetalleScreenState extends State<DestinoDetalleScreen> {
  late Destino _destino;

  @override
  void initState() {
    super.initState();
    _destino = widget.destino;
  }

  Future<void> _recargarDestino() async {
    try {
      final actualizado = await DestinoService.obtenerDestinoPorId(_destino.destinoid);
      if (mounted) setState(() => _destino = actualizado);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: EncabezadoDestino(destino: _destino)),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        IdentidadDestino(destino: _destino),
                        const SizedBox(height: 24),
                        _divisor(),
                        const SizedBox(height: 24),
                        DescripcionDestino(destino: _destino),
                        const SizedBox(height: 24),
                        _divisor(),
                        const SizedBox(height: 24),
                        HorariosDestino(destino: _destino),
                        const SizedBox(height: 20),
                        TarifasDestino(destino: _destino),
                        const SizedBox(height: 24),
                        _divisor(),
                        const SizedBox(height: 24),
                        MapaDestino(destino: _destino),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CheckinDestino(
              destino: _destino,
              onResenaEnviada: _recargarDestino,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divisor() => Container(height: 1, color: const Color(0xFFF0F0F5));
}
