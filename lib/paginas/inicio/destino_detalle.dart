import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../modelos/destino.dart';
import 'detalle/encabezado_destino.dart';
import 'detalle/identidad_destino.dart';
import 'detalle/chips_planificacion.dart';
import 'detalle/descripcion_destino.dart';
import 'detalle/horarios_destino.dart';
import 'detalle/tarifas_destino.dart';
import 'detalle/mapa_destino.dart';
import 'detalle/checkin_destino.dart';

class DestinoDetalleScreen extends StatelessWidget {
  final Destino destino;
  const DestinoDetalleScreen({super.key, required this.destino});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: EncabezadoDestino(destino: destino)),
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
                        IdentidadDestino(destino: destino),
                        const SizedBox(height: 20),
                        const ChipsPlanificacion(),
                        const SizedBox(height: 24),
                        _divisor(),
                        const SizedBox(height: 24),
                        DescripcionDestino(destino: destino),
                        const SizedBox(height: 24),
                        _divisor(),
                        const SizedBox(height: 24),
                        const HorariosDestino(),
                        const SizedBox(height: 20),
                        const TarifasDestino(),
                        const SizedBox(height: 24),
                        _divisor(),
                        const SizedBox(height: 24),
                        MapaDestino(destino: destino),
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
            child: CheckinDestino(destino: destino),
          ),
        ],
      ),
    );
  }

  Widget _divisor() => Container(height: 1, color: const Color(0xFFF0F0F5));
}
