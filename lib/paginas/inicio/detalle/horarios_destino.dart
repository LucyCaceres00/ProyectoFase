import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';

class HorariosDestino extends StatelessWidget {
  final Destino destino;
  const HorariosDestino({super.key, required this.destino});

  String _obtenerDiaActual() {
    final dias = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    return dias[DateTime.now().weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final horarios = destino.horariosDestino ?? [];

    if (horarios.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.colorBorde),
        ),
        child: const Row(
          children: [
            Icon(Icons.access_time_rounded, color: AppTheme.surfaceColor),
            SizedBox(width: 14),
            Text(
              'Horarios no disponibles',
              style: TextStyle(color: AppTheme.textoSuave),
            ),
          ],
        ),
      );
    }

    final diaActual = _obtenerDiaActual();
    final horarioHoy = horarios.firstWhere(
      (h) => h.diaSemana == diaActual,
      orElse: () => horarios.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horario de hoy
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colorBorde),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    horarioHoy.esCerrado ? 'Cerrado hoy' : 'Abierto hoy',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.surfaceColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    horarioHoy.esCerrado
                        ? 'No disponible'
                        : '${horarioHoy.horaApertura} — ${horarioHoy.horaCierre}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textoOscuro,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          title: const Text(
            'Ver todos los horarios',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          children: horarios.map((horario) {
            final esHoy = horario.diaSemana == diaActual;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: esHoy ? AppTheme.primaryColor.withValues(alpha: 0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: esHoy ? AppTheme.primaryColor.withValues(alpha: 0.2) : AppTheme.colorBorde,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    horario.diaSemana,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: esHoy ? FontWeight.w700 : FontWeight.w500,
                      color: AppTheme.textoOscuro,
                    ),
                  ),
                  Text(
                    horario.esCerrado
                        ? 'Cerrado'
                        : '${horario.horaApertura} - ${horario.horaCierre}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: esHoy ? FontWeight.w600 : FontWeight.w400,
                      color: horario.esCerrado ? Colors.red : AppTheme.textoSuave,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
