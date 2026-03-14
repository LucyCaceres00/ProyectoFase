import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../modelos/ranking_usuario.dart';

class PodioWidget extends StatelessWidget {
  final List<RankingUsuario> top3;

  const PodioWidget({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    final primero = top3.isNotEmpty ? top3[0] : null;
    final segundo = top3.length > 1 ? top3[1] : null;
    final tercero = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.colorBorde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (segundo != null) _tarjetaPodio(segundo, medalla: 2, escala: 0.85),
          const SizedBox(width: 4),
          if (primero != null) _tarjetaPodio(primero, medalla: 1, escala: 1.0),
          const SizedBox(width: 4),
          if (tercero != null) _tarjetaPodio(tercero, medalla: 3, escala: 0.85),
        ],
      ),
    );
  }

  Widget _tarjetaPodio(
    RankingUsuario usuario, {
    required int medalla,
    required double escala,
  }) {
    final double avatarSize = 56 * escala;
    final colorMedalla = _colorMedalla(medalla);
    final iconoMedalla = Icons.workspace_premium_rounded;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge de medalla
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorMedalla.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(iconoMedalla, size: 16, color: colorMedalla),
          ),
          const SizedBox(height: 8),
          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorMedalla,
                width: medalla == 1 ? 3 : 2,
              ),
            ),
            child: Center(
              child: Text(
                usuario.iniciales,
                style: TextStyle(
                  color: AppTheme.textoOscuro,
                  fontSize: 16 * escala,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Nombre
          Text(
            usuario.nombre.split(' ').first,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textoOscuro,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Puntos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: medalla == 1
                  ? AppTheme.colorEstrella
                  : medalla == 2
                  ? const Color(0xFFB0BEC5)
                  : const Color(0xFFCD7F32),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${usuario.turiPuntos} pts',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorMedalla(int posicion) {
    switch (posicion) {
      case 1:
        return AppTheme.colorEstrella;
      case 2:
        return const Color(0xFFB0BEC5);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppTheme.textoSuave;
    }
  }
}
