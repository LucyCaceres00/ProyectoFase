import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';

class CompartirDestinoCard extends StatelessWidget {
  final Destino destino;

  const CompartirDestinoCard({
    super.key,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _seccionImagen(),
          _seccionContenido(),
          _seccionMarca(),
        ],
      ),
    );
  }

  Widget _seccionImagen() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: destino.imagenprincipal != null
              ? Image.network(
                  destino.imagenprincipal!,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagenFallback(),
                )
              : _imagenFallback(),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '¡Lo visité!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )        
      ],
    );
  }

  Widget _imagenFallback() {
    return Container(
      height: 190,
      color: AppTheme.secondaryColor.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white54, size: 48),
      ),
    );
  }

  Widget _seccionContenido() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre + badge de TuriPuntos
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  destino.nombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      destino.puntosDestino > 0 ? '+${destino.puntosDestino} pts' : 'TuriPuntos',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${destino.municipio}, ${destino.departamento}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(
                destino.categoria,
                AppTheme.primaryColor.withValues(alpha: 0.10),
                AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              _chip(
                '⭐ ${destino.calificacionpromedio.toStringAsFixed(1)}',
                Colors.amber.withValues(alpha: 0.12),
                Colors.amber[800]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seccionMarca() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Center(
        child: Image.asset(
          'imagenes/toori_logo_letras_blancas.png',
          height: 22,
        ),
      ),
    );
  }

  Widget _chip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
