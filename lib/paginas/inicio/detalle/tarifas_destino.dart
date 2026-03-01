import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';

class TarifasDestino extends StatelessWidget {
  final Destino destino;
  const TarifasDestino({super.key, required this.destino});

  IconData _obtenerIcono(String tipoVisitante) {
    final tipo = tipoVisitante.toLowerCase();
    if (tipo.contains('niño') || tipo.contains('child')) {
      return Icons.child_care_outlined;
    } else if (tipo.contains('estudiante') || tipo.contains('student')) {
      return Icons.school_outlined;
    } else if (tipo.contains('adulto mayor') || tipo.contains('senior') || tipo.contains('tercera edad')) {
      return Icons.elderly_outlined;
    } else if (tipo.contains('extranjero') || tipo.contains('foreign')) {
      return Icons.public_outlined;
    } else {
      return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarifas = destino.tarifasDestino ?? [];

    if (tarifas.isEmpty) {
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
          const SizedBox(height: 14),
          if (destino.esgratis)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green),
                  SizedBox(width: 12),
                  Text(
                    'Entrada gratuita',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            )
          else
            const Text(
              'Información de tarifas no disponible',
              style: TextStyle(fontSize: 12, color: AppTheme.textoSuave),
            ),
        ],
      );
    }

    // Obtener la moneda principal (la más común en las tarifas)
    final monedaPrincipal = tarifas.isNotEmpty ? tarifas.first.moneda : 'HNL';

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
        Text(
          'Moneda principal: ${_obtenerNombreMoneda(monedaPrincipal)}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textoSuave),
        ),
        const SizedBox(height: 14),
        ...tarifas.asMap().entries.map((entry) {
          final index = entry.key;
          final tarifa = entry.value;
          return Column(
            children: [
              if (index > 0) const SizedBox(height: 10),
              _filaTarifa(
                _obtenerIcono(tarifa.visitante),
                tarifa.visitante,
                '${_obtenerSimboloMoneda(tarifa.moneda)} ${tarifa.precio.toStringAsFixed(tarifa.precio.truncateToDouble() == tarifa.precio ? 0 : 2)}',
                tarifa.descripcion,
              ),
            ],
          );
        }),
      ],
    );
  }

  String _obtenerSimboloMoneda(String moneda) {
    switch (moneda.toUpperCase()) {
      case 'HNL':
        return 'L';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return moneda;
    }
  }

  String _obtenerNombreMoneda(String moneda) {
    switch (moneda.toUpperCase()) {
      case 'HNL':
        return 'Lempiras hondureños (HNL)';
      case 'USD':
        return 'Dólares estadounidenses (USD)';
      case 'EUR':
        return 'Euros (EUR)';
      default:
        return moneda;
    }
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
