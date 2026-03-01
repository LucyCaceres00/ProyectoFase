import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../modelos/destino.dart';
import '../../modelos/resena.dart';
import '../../servicios/resena_service.dart';
import '../../servicios/registro_service.dart';
import '../../servicios/visita_service.dart';
import '../../widgets/app_dialogo.dart';

class ResenaScreen extends StatefulWidget {
  final Destino destino;
  const ResenaScreen({super.key, required this.destino});

  @override
  State<ResenaScreen> createState() => _ResenaScreenState();
}

class _ResenaScreenState extends State<ResenaScreen> {
  int _acceso = 0;
  int _estadoLugar = 0;
  int _comida = 0;
  int _servicio = 0;
  final _comentarioCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  bool get _formularioValido => _acceso > 0 && _estadoLugar > 0;

  Future<void> _enviarResena() async {
    if (!_formularioValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes calificar Acceso y Estado del lugar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      final usuarioId = RegistrarService().usuarioId ?? 0;

      await ResenaService.guardarResena(
        Resena(
          usuarioId: usuarioId,
          destinoId: widget.destino.destinoid,
          puntuacionAcceso: _acceso,
          puntuacionEstadoLugar: _estadoLugar,
          puntuacionComida: _comida > 0 ? _comida : null,
          puntuacionServicio: _servicio > 0 ? _servicio : null,
          comentario: _comentarioCtrl.text.trim(),
        ),
      );

      // Limpiar cache: ya puede hacer otro check-in
      await VisitaService.guardarCachePendiente(usuarioId, widget.destino.destinoid, false);

      if (!mounted) return;

      AppDialogo.mostrarExito(
        context,
        titulo: '¡Reseña enviada!',
        mensaje: 'Gracias por compartir tu experiencia en ${widget.destino.nombre}.',
        alCerrar: () => Navigator.pop(context, true), // true = reseña guardada
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);

      final esNoAutorizado = e.toString().contains('No autorizado') || e.toString().contains('sesión');
      AppDialogo.mostrar(
        context,
        icono: esNoAutorizado ? Icons.lock_outline : Icons.error_outline,
        titulo: esNoAutorizado ? 'Sesión requerida' : 'Error al enviar',
        mensaje: esNoAutorizado
            ? 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'
            : e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textoOscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Escribir reseña',
          style: TextStyle(
            color: AppTheme.textoOscuro,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Encabezado del destino ───────────────────────────────
                  _encabezadoDestino(),
                  const SizedBox(height: 28),

                  // ── Categorías obligatorias ──────────────────────────────
                  _seccionTitulo('Calificaciones obligatorias'),
                  const SizedBox(height: 16),
                  _filaCategoriaEstrellas(
                    icono: Icons.accessibility_new_rounded,
                    label: 'Acceso',
                    descripcion: 'Facilidad para llegar y moverse',
                    valor: _acceso,
                    onChanged: (v) => setState(() => _acceso = v),
                    obligatorio: true,
                  ),
                  const SizedBox(height: 14),
                  _filaCategoriaEstrellas(
                    icono: Icons.landscape_rounded,
                    label: 'Estado del lugar',
                    descripcion: 'Conservación e instalaciones',
                    valor: _estadoLugar,
                    onChanged: (v) => setState(() => _estadoLugar = v),
                    obligatorio: true,
                  ),

                  const SizedBox(height: 28),

                  // ── Categorías opcionales ────────────────────────────────
                  _seccionTitulo('Calificaciones opcionales'),
                  const SizedBox(height: 4),
                  const Text(
                    'Califica solo si aplica al destino',
                    style: TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                  ),
                  const SizedBox(height: 16),
                  _filaCategoriaEstrellas(
                    icono: Icons.restaurant_rounded,
                    label: 'Comida',
                    descripcion: 'Restaurantes o vendedores cercanos',
                    valor: _comida,
                    onChanged: (v) => setState(() => _comida = v),
                    obligatorio: false,
                  ),
                  const SizedBox(height: 14),
                  _filaCategoriaEstrellas(
                    icono: Icons.support_agent_rounded,
                    label: 'Servicio',
                    descripcion: 'Atención al visitante',
                    valor: _servicio,
                    onChanged: (v) => setState(() => _servicio = v),
                    obligatorio: false,
                  ),

                  const SizedBox(height: 28),

                  // ── Comentario ───────────────────────────────────────────
                  _seccionTitulo('Comentario'),
                  const SizedBox(height: 4),
                  const Text(
                    'Opcional — cuéntanos tu experiencia',
                    style: TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _comentarioCtrl,
                    maxLines: 4,
                    maxLength: 500,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textoOscuro),
                    decoration: InputDecoration(
                      hintText: '¿Qué te pareció el destino?',
                      hintStyle: const TextStyle(color: AppTheme.textoSuave, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF8F8FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.colorBorde),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.colorBorde),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Botón enviar ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _enviando ? null : _enviarResena,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.colorBorde,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Enviar reseña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets auxiliares ──────────────────────────────────────────────────────

  Widget _encabezadoDestino() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colorBorde),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.destino.imagenprincipal != null
                ? Image.network(
                    widget.destino.imagenprincipal!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImagen(),
                  )
                : _placeholderImagen(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.destino.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textoOscuro,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 13, color: AppTheme.textoSuave),
                    const SizedBox(width: 3),
                    Text(
                      '${widget.destino.municipio}, ${widget.destino.departamento}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppTheme.colorEstrella),
                    const SizedBox(width: 3),
                    Text(
                      '${widget.destino.calificacionpromedio}  ·  ${widget.destino.categoria}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImagen() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_outlined, color: AppTheme.primaryColor),
    );
  }

  Widget _seccionTitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.textoOscuro,
      ),
    );
  }

  Widget _filaCategoriaEstrellas({
    required IconData icono,
    required String label,
    required String descripcion,
    required int valor,
    required ValueChanged<int> onChanged,
    required bool obligatorio,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: valor > 0 ? AppTheme.surfaceColor.withValues(alpha: 0.4) : AppTheme.colorBorde,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textoOscuro,
                      ),
                    ),
                    if (obligatorio) ...[
                      const SizedBox(width: 4),
                      const Text('*', style: TextStyle(color: Colors.red, fontSize: 13)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textoSuave),
                ),
                const SizedBox(height: 8),
                _estrellas(valor: valor, onChanged: onChanged),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _estrellas({required int valor, required ValueChanged<int> onChanged}) {
    return Row(
      children: List.generate(5, (i) {
        final estrella = i + 1;
        return GestureDetector(
          onTap: () => onChanged(estrella == valor ? 0 : estrella),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              estrella <= valor ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 28,
              color: estrella <= valor ? AppTheme.colorEstrella : AppTheme.colorBorde,
            ),
          ),
        );
      }),
    );
  }
}
