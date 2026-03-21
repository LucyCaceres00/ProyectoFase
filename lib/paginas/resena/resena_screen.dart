import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_theme.dart';
import '../../modelos/destino.dart';
import '../../modelos/resena.dart';
import '../../servicios/resena_service.dart';
import '../../servicios/registro_service.dart';
import '../../servicios/visita_service.dart';
import '../../widgets/app_dialogo.dart';
import 'widgets/encabezado_resena.dart';
import 'widgets/fila_calificacion.dart';
import 'widgets/selector_imagenes_resena.dart';

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
  final List<XFile> _imagenes = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  bool get _formularioValido => _acceso > 0 && _estadoLugar > 0;

  Future<void> _seleccionarImagenes(ImageSource fuente) async {
    if (fuente == ImageSource.gallery) {
      final picked = await _picker.pickMultiImage(imageQuality: 80, limit: 5);
      if (picked.isNotEmpty) {
        setState(() {
          final restantes = 5 - _imagenes.length;
          _imagenes.addAll(picked.take(restantes));
        });
      }
    } else {
      final picked = await _picker.pickImage(source: fuente, imageQuality: 80);
      if (picked != null && _imagenes.length < 5) {
        setState(() => _imagenes.add(picked));
      }
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.colorBorde,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryColor),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagenes(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryColor),
                title: const Text('Tomar una foto'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagenes(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        imagenes: _imagenes,
      );

      await VisitaService.guardarCachePendiente(usuarioId, widget.destino.destinoid, false);

      if (!mounted) return;

      AppDialogo.mostrarExito(
        context,
        titulo: '¡Reseña enviada!',
        mensaje: 'Gracias por compartir tu experiencia en ${widget.destino.nombre}.',
        alCerrar: () => Navigator.pop(context, true),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);

      final esNoAutorizado =
          e.toString().contains('No autorizado') || e.toString().contains('sesión');
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
                  EncabezadoResena(destino: widget.destino),
                  const SizedBox(height: 28),

                  _seccionTitulo('Calificaciones obligatorias'),
                  const SizedBox(height: 16),
                  FilaCalificacion(
                    icono: Icons.accessibility_new_rounded,
                    label: 'Acceso',
                    descripcion: 'Facilidad para llegar y moverse',
                    valor: _acceso,
                    onChanged: (v) => setState(() => _acceso = v),
                    obligatorio: true,
                  ),
                  const SizedBox(height: 14),
                  FilaCalificacion(
                    icono: Icons.landscape_rounded,
                    label: 'Estado del lugar',
                    descripcion: 'Conservación e instalaciones',
                    valor: _estadoLugar,
                    onChanged: (v) => setState(() => _estadoLugar = v),
                    obligatorio: true,
                  ),

                  const SizedBox(height: 28),

                  _seccionTitulo('Calificaciones opcionales'),
                  const SizedBox(height: 4),
                  const Text(
                    'Califica solo si aplica al destino',
                    style: TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                  ),
                  const SizedBox(height: 16),
                  FilaCalificacion(
                    icono: Icons.restaurant_rounded,
                    label: 'Comida',
                    descripcion: 'Restaurantes o vendedores cercanos',
                    valor: _comida,
                    onChanged: (v) => setState(() => _comida = v),
                    obligatorio: false,
                  ),
                  const SizedBox(height: 14),
                  FilaCalificacion(
                    icono: Icons.support_agent_rounded,
                    label: 'Servicio',
                    descripcion: 'Atención al visitante',
                    valor: _servicio,
                    onChanged: (v) => setState(() => _servicio = v),
                    obligatorio: false,
                  ),

                  const SizedBox(height: 28),

                  _seccionTitulo('Fotos'),
                  const SizedBox(height: 4),
                  const Text(
                    'Opcional — máximo 5 fotos',
                    style: TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                  ),
                  const SizedBox(height: 12),
                  SelectorImagenesResena(
                    imagenes: _imagenes,
                    onAgregar: _mostrarOpcionesImagen,
                    onEliminar: (i) => setState(() => _imagenes.removeAt(i)),
                  ),

                  const SizedBox(height: 28),

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

          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
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
                          Text(
                            'Enviar reseña',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
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
}
