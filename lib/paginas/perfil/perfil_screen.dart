import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../modelos/usuario_perfil.dart';
import '../../servicios/perfil_service.dart';
import '../../servicios/registro_service.dart';
import '../inicio_sesion/inicio_sesion.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Future<UsuarioPerfil> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = PerfilService.obtenerInformacionUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FutureBuilder<UsuarioPerfil>(
          future: _perfilFuture,
          builder: (context, snapshot) {
            final perfil = snapshot.data;
            final cargando = snapshot.connectionState == ConnectionState.waiting;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Título ────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Perfil',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                          height: 1.2,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Tarjeta de avatar ──────────────────────────────────────
                  _avatarCard(
                    iniciales: perfil?.iniciales ?? '—',
                    nombre: perfil?.nombre ?? '—',
                    correo: perfil?.correo ?? '',
                    nivel: perfil?.nivelExplorador ?? '',
                    cargando: cargando,
                  ),
                  const SizedBox(height: 16),

                  // ── Estadísticas ───────────────────────────────────────────
                  _statsRow(
                    visitas: perfil?.totalVisitas,
                    puntos: perfil?.turiPuntos,
                    resenias: perfil?.totalResenias,
                  ),
                  const SizedBox(height: 28),

                  // ── Mi Cuenta ──────────────────────────────────────────────
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
                    _menuItem(Icons.rate_review_rounded, 'Mis reseñas'),
                  ]),

                  const SizedBox(height: 16),

                  // ── Cerrar sesión ──────────────────────────────────────────
                  _cerrarSesionCard(context),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Avatar Card ─────────────────────────────────────────────────────────────

  Widget _avatarCard({
    required String iniciales,
    required String nombre,
    required String correo,
    required String nivel,
    required bool cargando,
  }) {
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.secondaryColor, width: 3),
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
                  style: const TextStyle(fontSize: 13, color: AppTheme.textoSuave),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
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
                    const Icon(Icons.explore_rounded, size: 15, color: AppTheme.primaryColor),
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

  Widget _statsRow({int? visitas, int? puntos, int? resenias}) {
    return Row(
      children: [
        _statCard(Icons.place_rounded, 'Visitas', visitas != null ? '$visitas' : '—'),
        const SizedBox(width: 10),
        _statCard(Icons.stars_rounded, 'TuriPuntos', puntos != null ? '$puntos' : '—'),
        const SizedBox(width: 10),
        _statCard(Icons.rate_review_rounded, 'Reseñas', resenias != null ? '$resenias' : '—'),
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
              style: const TextStyle(fontSize: 11, color: AppTheme.textoSuave),
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
          const Icon(Icons.chevron_right_rounded, color: AppTheme.textoSuave, size: 22),
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
              child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
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
            const Icon(Icons.chevron_right_rounded, color: Colors.red, size: 22),
          ],
        ),
      ),
    );
  }
}
