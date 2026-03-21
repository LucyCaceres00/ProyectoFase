import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';

class EncabezadoResena extends StatelessWidget {
  final Destino destino;
  const EncabezadoResena({super.key, required this.destino});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colorBorde),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: destino.imagenprincipal != null
                ? Image.network(
                    destino.imagenprincipal!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImagen(),
                  )
                : _placeholderImagen(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destino.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textoOscuro,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 13, color: AppTheme.textoSuave),
                    const SizedBox(width: 3),
                    Text(
                      '${destino.municipio}, ${destino.departamento}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppTheme.colorEstrella),
                    const SizedBox(width: 3),
                    Text(
                      '${destino.calificacionpromedio}  ·  ${destino.categoria}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImagen() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_outlined, color: AppTheme.primaryColor),
    );
  }
}
