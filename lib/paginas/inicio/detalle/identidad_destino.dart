import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';

class IdentidadDestino extends StatelessWidget {
  final Destino destino;
  const IdentidadDestino({super.key, required this.destino});

  String _formatVisitas(int visitas) {
    if (visitas >= 1000) {
      return '+${(visitas / 1000).floor()}K';
    }
    return visitas.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                destino.categoria,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.colorEstrella, size: 18),
                const SizedBox(width: 4),
                Text(
                  destino.calificacionpromedio.toString(),
                  style: const TextStyle(
                    color: AppTheme.textoOscuro,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                 _formatVisitas(destino.totalvisitas),
                  style: TextStyle(color: AppTheme.textoSuave, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          destino.nombre,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.textoOscuro,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 16),
            const SizedBox(width: 4),
            Text(
              '${destino.municipio}, ${destino.departamento}',
              style: const TextStyle(
                color: AppTheme.textoSuave,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
