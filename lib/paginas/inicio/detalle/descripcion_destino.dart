import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';

class DescripcionDestino extends StatelessWidget {
  final Destino destino;
  const DescripcionDestino({super.key, required this.destino});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textoOscuro,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          destino.descripcion.isNotEmpty
              ? destino.descripcion
              : 'Sin descripción disponible.',
          style: const TextStyle(fontSize: 14, color: AppTheme.textoSuave, height: 1.75),
        ),
      ],
    );
  }
}
