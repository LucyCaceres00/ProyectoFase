import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../servicios/registro_service.dart';
import '../inicio_sesion/inicio_sesion.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = RegistrarService();
    final nombre = service.nombre ?? 'Usuario';
    final correo = service.correo ?? '';
    final nivel = service.nivelExplorador ?? 'Explorador';
    final turiPuntos = service.turiPuntos ?? 0;

    final partes = nombre.trim().split(' ');
    final iniciales = partes.length >= 2
        ? '${partes[0][0]}${partes[1][0]}'.toUpperCase()
        : nombre.substring(0, nombre.length >= 2 ? 2 : 1).toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título ──────────────────────────────────────────────────────
              const Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),

              // ── Tarjeta de avatar ────────────────────────────────────────────
              _avatarCard(iniciales, nombre, correo, nivel),
              const SizedBox(height: 16),

              // ── Estadísticas ─────────────────────────────────────────────────
              _statsRow(turiPuntos),
              const SizedBox(height: 28),

              // ── Mi Cuenta ────────────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'MI CUENTA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textoSuave,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _menuCard([
                _menuItem(Icons.place_rounded, 'Mis visitas'),
                _divider(),
                _menuItem(Icons.stars_rounded, 'Mis TuriPuntos'),
                _divider(),
                _menuItem(Icons.settings_outlined, 'Configuración'),
              ]),

              const SizedBox(height: 16),

              // ── Cerrar sesión ────────────────────────────────────────────────
              _cerrarSesionCard(context),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar Card ─────────────────────────────────────────────────────────────

  Widget _avatarCard(
    BuildContext context,
    String iniciales,
    String nombre,
    String correo,
    String nivel,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.colorBorde),
      ),
      child: Column(
        children: [
          // Avatar circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.secondaryColor,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Nombre
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textoOscuro,
            ),
            textAlign: TextAlign.center,
          ),
          if (correo.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              correo,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textoSuave,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          // Badge de nivel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.explore_rounded,
                  size: 15,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 5),
                Text(
                  nivel.isNotEmpty ? nivel : 'Explorador',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ───────────────────────────────────────────────────────────────

  Widget _statsRow(int turiPuntos) {
    return Row(
      children: [
        _statCard(Icons.place_rounded, 'Visitas', '—'),
        const SizedBox(width: 10),
        _statCard(Icons.stars_rounded, 'TuriPuntos', '$turiPuntos'),
        const SizedBox(width: 10),
        _statCard(Icons.rate_review_rounded, 'Reseñas', '—'),
      ],
    );
  }

  Widget _statCard(IconData icono, String label, String valor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.colorBorde),
        ),
        child: Column(
          children: [
            Icon(icono, color: AppTheme.primaryColor, size: 22),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textoOscuro,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textoSuave,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Menu Card ───────────────────────────────────────────────────────────────

  Widget _menuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colorBorde),
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem(IconData icono, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textoOscuro,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textoSuave,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      indent: 68,
      endIndent: 0,
      color: AppTheme.colorBorde,
    );
  }

  // ── Cerrar Sesión ────────────────────────────────────────────────────────────

  Widget _cerrarSesionCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        RegistrarService().cerrarSesion();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.colorBorde),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.red,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
