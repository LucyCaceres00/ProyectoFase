import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';
import 'carrusel_imagenes.dart';

class EncabezadoDestino extends StatelessWidget {
  final Destino destino;
  const EncabezadoDestino({super.key, required this.destino});

  List<String> get _imagenes {
    if (destino.galeriaimagenes != null && destino.galeriaimagenes!.isNotEmpty) {
      return destino.galeriaimagenes!;
    }
    if (destino.imagenprincipal != null) {
      return [destino.imagenprincipal!];
    }
    return [];
  }

  void _abrirCarrusel(BuildContext context, int inicial) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => CarruselImagenes(imagenes: _imagenes, indiceInicial: inicial),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _abrirCarrusel(context, 0),
      child: SizedBox(
        height: 300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            destino.imagenprincipal != null
                ? Image.network(
                    destino.imagenprincipal!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                  )
                : Container(color: Colors.grey[300]),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x66000000)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
            if (_imagenes.isNotEmpty)
              Positioned(
                bottom: 48,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_library_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${_imagenes.length} foto${_imagenes.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: _botonCircular(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonCircular(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8),
        ],
      ),
      child: Icon(icon, color: AppTheme.primaryColor, size: 20),
    );
  }
}
