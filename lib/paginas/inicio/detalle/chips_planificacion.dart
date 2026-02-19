import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class ChipsPlanificacion extends StatelessWidget {
  const ChipsPlanificacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Planifica tu visita',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textoOscuro,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _chip('⏱️', '2-3 horas'),
            _chip('👨‍👩‍👧', 'Familiar'),
            _chip('🎒', 'Aventura'),
            _chip('📸', 'Fotográfico'),
          ],
        ),
      ],
    );
  }

  Widget _chip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.colorBordeChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textoOscuro,
            ),
          ),
        ],
      ),
    );
  }
}
