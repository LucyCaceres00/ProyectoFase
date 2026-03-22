import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../modelos/usuario_perfil.dart';
import '../../servicios/perfil_service.dart';
import '../../servicios/registro_service.dart';
import '../inicio_sesion/inicio_sesion.dart';
import 'resenas_screen.dart';
import 'turipuntos_screen.dart';
import 'visitas_screen.dart';

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
                        onTap: () => _mostrarModalCambiarContrasenia(context),
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
                  const SizedBox(height: 10),
                  // ── Tarjeta de avatar ──────────────────────────────────────
                  _avatarCard(
                    iniciales: perfil?.iniciales ?? '—',
                    nombre: perfil?.nombre ?? '—',
                    correo: perfil?.correo ?? '',
                    nivel: perfil?.nivelExplorador ?? '',
                    cargando: cargando,
                  ),
                  const SizedBox(height: 12),
                  // ── Estadísticas ───────────────────────────────────────────
                  _statsRow(
                    visitas: perfil?.totalVisitas,
                    puntos: perfil?.turiPuntos,
                    resenias: perfil?.totalResenias,
                  ),
                  const SizedBox(height: 12),

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
                    _menuItem(Icons.place_rounded, 'Mis visitas', onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitasScreen()));
                    }),
                    _divider(),
                    _menuItem(Icons.stars_rounded, 'Mis TuriPuntos', onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TuriPuntosScreen()));
                    }),
                    _divider(),
                    _menuItem(Icons.rate_review_rounded, 'Mis reseñas', onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ResenasScreen()));
                    }),
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

  // ── Modal Cambiar Contraseña ─────────────────────────────────────────────────

  void _mostrarModalCambiarContrasenia(BuildContext context) {
    
    final nuevaCtrl = TextEditingController();
    final confirmarCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool cargando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.colorBorde,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Cambiar contraseña',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textoOscuro,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nuevaCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Nueva contraseña',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: confirmarCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                          if (v != nuevaCtrl.text) return 'Las contraseñas no coinciden';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: cargando
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => cargando = true);
                                  final response = await RegistrarService().cambiarContrasenia(
                                    nuevaContrasenia: nuevaCtrl.text,
                                  );
                                  setModalState(() => cargando = false);
                                  if (!ctx.mounted) return;
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.success
                                          ? 'Contraseña actualizada correctamente'
                                          : response.message),
                                      backgroundColor: response.success ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                          child: cargando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Guardar',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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

  Widget _menuItem(IconData icono, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
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
