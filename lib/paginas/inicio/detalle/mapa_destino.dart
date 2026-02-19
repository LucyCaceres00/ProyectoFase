import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app_theme.dart';
import '../../../modelos/destino.dart';

class MapaDestino extends StatelessWidget {
  final Destino destino;
  const MapaDestino({super.key, required this.destino});

  bool get _tieneUbicacion => destino.latitud != 0.0 || destino.longitud != 0.0;

  Future<void> _abrirOpcionesMapa(BuildContext context) async {
    final double lat = destino.latitud;
    final double lng = destino.longitud;

    final googleNativo = Uri.parse('comgooglemaps://?q=$lat,$lng&center=$lat,$lng');
    final wazeNativo = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
    final googleWeb = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    final tieneGoogle = await canLaunchUrl(googleNativo);
    final tieneWaze = await canLaunchUrl(wazeNativo);

    if (!tieneGoogle && !tieneWaze) {
      await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
      return;
    }

    if (tieneGoogle && !tieneWaze) {
      await launchUrl(googleNativo, mode: LaunchMode.externalApplication);
      return;
    }

    if (!tieneGoogle && tieneWaze) {
      await launchUrl(wazeNativo, mode: LaunchMode.externalApplication);
      return;
    }

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Abrir ubicación en',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textoOscuro),
            ),
            const SizedBox(height: 16),
            _OpcionMapa(
              icon: Icons.map_outlined,
              label: 'Google Maps',
              color: AppTheme.colorGoogleMaps,
              url: googleNativo,
            ),
            const SizedBox(height: 10),
            _OpcionMapa(
              icon: Icons.navigation_outlined,
              label: 'Waze',
              color: AppTheme.colorWaze,
              url: wazeNativo,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textoOscuro),
        ),
        const SizedBox(height: 14),
        if (!_tieneUbicacion)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.colorBorde),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off_outlined, color: AppTheme.textoSuave, size: 28),
                  SizedBox(height: 6),
                  Text(
                    'Ubicación no disponible',
                    style: TextStyle(color: AppTheme.textoSuave, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => _abrirOpcionesMapa(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: AppTheme.colorFondoMapa),
                    CustomPaint(painter: _PintorMapa()),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
                          ],
                        ),
                        child: Text(
                          destino.nombre,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textoOscuro),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.open_in_new, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Ver mapa',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OpcionMapa extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Uri url;
  const _OpcionMapa({required this.icon, required this.label, required this.color, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        Navigator.pop(context);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }
}

class _PintorMapa extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFB8CDE8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (double y = 20; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (double x = 30; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..cubicTo(
          size.width * 0.3, size.height * 0.4,
          size.width * 0.6, size.height * 0.7,
          size.width, size.height * 0.5,
        ),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
