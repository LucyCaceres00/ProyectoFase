import 'package:flutter/material.dart';
import '../../../app_theme.dart';

class TarifasDestino extends StatelessWidget {
  const TarifasDestino({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tarifas de entrada',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textoOscuro,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Moneda: Lempiras hondureños (HNL)',
          style: TextStyle(fontSize: 12, color: AppTheme.textoSuave),
        ),
        const SizedBox(height: 14),
        _filaTarifa(
          Icons.person_outline,
          'Adultos',
          'L 100',
          'Documento de identidad requerido',
        ),
        const SizedBox(height: 10),
        _filaTarifa(
          Icons.child_care_outlined,
          'Niños (6-12 años)',
          'L 50',
          'Menores de 6 años gratis',
        ),
        const SizedBox(height: 10),
        _filaTarifa(
          Icons.school_outlined,
          'Estudiantes',
          'L 75',
          'Presentar carnet vigente',
        ),
      ],
    );
  }

  Widget _filaTarifa(IconData icon, String tipo, String precio, String nota) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.colorBorde),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textoOscuro,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nota,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textoSuave),
                ),
              ],
            ),
          ),
          Text(
            precio,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
