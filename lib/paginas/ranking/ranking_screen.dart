import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../modelos/ranking_usuario.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  static final List<RankingUsuario> _datosPrueba = [
    RankingUsuario(
      posicion: 1,
      usuarioId: 1,
      nombre: 'María González',
      turiPuntos: 3580,
      totalVisitas: 28,
    ),
    RankingUsuario(
      posicion: 2,
      usuarioId: 2,
      nombre: 'Carlos Mejía',
      turiPuntos: 3420,
      totalVisitas: 25,
    ),
    RankingUsuario(
      posicion: 3,
      usuarioId: 3,
      nombre: 'Ana Rodríguez',
      turiPuntos: 3150,
      totalVisitas: 22,
    ),
    RankingUsuario(
      posicion: 4,
      usuarioId: 4,
      nombre: 'Luis Hernández',
      turiPuntos: 2890,
      totalVisitas: 22,
    ),
    RankingUsuario(
      posicion: 5,
      usuarioId: 5,
      nombre: 'Sofia Martínez',
      turiPuntos: 2650,
      totalVisitas: 20,
    ),
    RankingUsuario(
      posicion: 6,
      usuarioId: 6,
      nombre: 'Diego Torres',
      turiPuntos: 2420,
      totalVisitas: 18,
    ),
    RankingUsuario(
      posicion: 7,
      usuarioId: 7,
      nombre: 'Valentina López',
      turiPuntos: 2180,
      totalVisitas: 16,
    ),
    RankingUsuario(
      posicion: 8,
      usuarioId: 8,
      nombre: 'Roberto Díaz',
      turiPuntos: 1950,
      totalVisitas: 15,
    ),
    RankingUsuario(
      posicion: 9,
      usuarioId: 9,
      nombre: 'Nayeli Guillen',
      turiPuntos: 260,
      totalVisitas: 16,
    ),
    RankingUsuario(
      posicion: 10,
      usuarioId: 10,
      nombre: 'Luis Ochoa',
      turiPuntos: 1950,
      totalVisitas: 15,
    ),
  ];

  List<RankingUsuario> _lista = [];

  @override
  void initState() {
    super.initState();
    _lista = _datosPrueba;
  }

  void _refrescar() {
    setState(() => _lista = List.from(_datosPrueba));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top exploradores',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor,
                      height: 1.2,
                    ),
                  ),
                  IconButton(
                    onPressed: _refrescar,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Contenido ─────────────────────────────────────────────────
            Expanded(
              child: Builder(
                builder: (context) {
                  final top3 = _lista.take(3).toList();
                  final resto = _lista.skip(3).toList();

                  return RefreshIndicator(
                    onRefresh: () async => _refrescar(),
                    color: AppTheme.secondaryColor,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      children: [
                        // ── Podio Top 3 ──────────────────────────────────
                        _podio(top3),
                        const SizedBox(height: 20),

                        // ── Lista posiciones 4+ ──────────────────────────
                        ...resto.map((u) => _filaRanking(u)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Podio ────────────────────────────────────────────────────────────────

  Widget _podio(List<RankingUsuario> top3) {
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
          // 2do lugar (izquierda)
          if (segundo != null) _tarjetaPodio(segundo, medalla: 2, escala: 0.85),
          const SizedBox(width: 4),
          // 1er lugar (centro, más grande)
          if (primero != null) _tarjetaPodio(primero, medalla: 1, escala: 1.0),
          const SizedBox(width: 4),
          // 3er lugar (derecha)
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
    final iconoMedalla = _iconoMedalla(medalla);

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
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
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
            ],
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:Colors.white ,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Fila de ranking (posición 4+) ────────────────────────────────────────

  Widget _filaRanking(RankingUsuario usuario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colorBorde),
      ),
      child: Row(
        children: [
          // Número de posición
          SizedBox(
            width: 28,
            child: Text(
              '${usuario.posicion}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textoSuave,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                usuario.iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nombre y visitas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textoOscuro,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${usuario.totalVisitas} visitas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textoSuave,
                  ),
                ),
              ],
            ),
          ),
          // Puntos
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${usuario.turiPuntos}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Text(
                'puntos',
                style: TextStyle(fontSize: 10, color: AppTheme.textoSuave),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

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

  IconData _iconoMedalla(int posicion) {
    switch (posicion) {
      case 1:
        return Icons.workspace_premium_rounded;
      case 2:
        return Icons.workspace_premium_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.circle;
    }
  }
}
