import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class FilaCalificacion extends StatelessWidget {
  final IconData icono;
  final String label;
  final String descripcion;
  final int valor;
  final ValueChanged<int> onChanged;
  final bool obligatorio;

  const FilaCalificacion({
    super.key,
    required this.icono,
    required this.label,
    required this.descripcion,
    required this.valor,
    required this.onChanged,
    required this.obligatorio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: valor > 0 ? AppTheme.surfaceColor.withValues(alpha: 0.4) : AppTheme.colorBorde,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textoOscuro,
                      ),
                    ),
                    if (obligatorio) ...[
                      const SizedBox(width: 4),
                      const Text('*', style: TextStyle(color: Colors.red, fontSize: 13)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textoSuave),
                ),
                const SizedBox(height: 8),
                _Estrellas(valor: valor, onChanged: onChanged),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Estrellas extends StatelessWidget {
  final int valor;
  final ValueChanged<int> onChanged;
  const _Estrellas({required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final estrella = i + 1;
        return GestureDetector(
          onTap: () => onChanged(estrella == valor ? 0 : estrella),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              estrella <= valor ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 28,
              color: estrella <= valor ? AppTheme.colorEstrella : AppTheme.colorBorde,
            ),
          ),
        );
      }),
    );
  }
}
