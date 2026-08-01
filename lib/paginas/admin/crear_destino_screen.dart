import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_theme.dart';
import '../../modelos/categoria_destino.dart';
import '../../modelos/departamento.dart';
import '../../modelos/moneda.dart';
import '../../modelos/horario_destino.dart';
import '../../modelos/tarifa_destino.dart';
import '../../servicios/destino_service.dart';
import '../resena/widgets/selector_imagenes_resena.dart';

class CrearDestinoScreen extends StatefulWidget {
  const CrearDestinoScreen({super.key});

  @override
  State<CrearDestinoScreen> createState() => _CrearDestinoScreenState();
}

class _HorarioDia {
  final String dia;
  bool abierto = false;
  TimeOfDay horaApertura = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay horaCierre = const TimeOfDay(hour: 17, minute: 0);

  _HorarioDia({required this.dia});
}

class _TarifaForm {
  String tipoVisitante = 'General';
  String moneda = 'HNL';
  final precioController = TextEditingController();
  final descripcionController = TextEditingController();

  void dispose() {
    precioController.dispose();
    descripcionController.dispose();
  }
}

class _CrearDestinoScreenState extends State<CrearDestinoScreen> {
  // Coincide con "diasemanaenum" del backend
  static const _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
    'Festivos',
  ];

  // Coincide con "tipovisitanteenum" del backend
  static const _tiposVisitante = [
    'General',
    'Niño',
    'Estudiante',
    'Adulto Mayor',
    'Extranjero',
    'Local',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _tiempoVisitaController = TextEditingController();
  final _distanciaCheckinController = TextEditingController(text: '30');

  final ImagePicker _picker = ImagePicker();
  XFile? _imagenPortada;
  final List<XFile> _imagenesGaleria = [];

  CategoriaDestino? _categoriaSeleccionada;
  String? _departamentoSeleccionado;
  String? _municipioSeleccionado;
  bool _esGratis = false;
  bool _isLoading = false;
  bool _obteniendoUbicacion = false;

  late final List<_HorarioDia> _horarios = _diasSemana
      .map((d) => _HorarioDia(dia: d))
      .toList();
  final List<_TarifaForm> _tarifas = [_TarifaForm()];

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _tiempoVisitaController.dispose();
    _distanciaCheckinController.dispose();
    for (final t in _tarifas) {
      t.dispose();
    }
    super.dispose();
  }

  Future<void> _usarUbicacionActual() async {
    setState(() => _obteniendoUbicacion = true);
    try {
      final servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        throw 'El servicio de ubicación está desactivado';
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          throw 'Se necesita permiso de ubicación';
        }
      }
      if (permiso == LocationPermission.deniedForever) {
        throw 'El permiso de ubicación fue denegado permanentemente';
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latitudController.text = posicion.latitude.toStringAsFixed(6);
        _longitudController.text = posicion.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _obteniendoUbicacion = false);
    }
  }

  Future<void> _seleccionarPortada() async {
    final imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (imagen != null) setState(() => _imagenPortada = imagen);
  }

  Future<void> _agregarImagenGaleria() async {
    final imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (imagen != null) setState(() => _imagenesGaleria.add(imagen));
  }

  void _quitarImagenGaleria(int index) {
    setState(() => _imagenesGaleria.removeAt(index));
  }

  void _agregarTarifa() {
    setState(() => _tarifas.add(_TarifaForm()));
  }

  void _quitarTarifa(int index) {
    setState(() {
      _tarifas[index].dispose();
      _tarifas.removeAt(index);
    });
  }

  Future<void> _seleccionarHora(
    _HorarioDia horario, {
    required bool esApertura,
  }) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: esApertura ? horario.horaApertura : horario.horaCierre,
    );
    if (hora != null) {
      setState(() {
        if (esApertura) {
          horario.horaApertura = hora;
        } else {
          horario.horaCierre = hora;
        }
      });
    }
  }

  String _formatearHora(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _guardarDestino() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_departamentoSeleccionado == null || _municipioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona departamento y municipio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_latitudController.text.trim().isEmpty ||
        _longitudController.text.trim().isEmpty ||
        double.tryParse(_latitudController.text.trim()) == null ||
        double.tryParse(_longitudController.text.trim()) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una latitud y longitud válidas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tarifasValidas = _tarifas
        .where((t) => t.precioController.text.trim().isNotEmpty)
        .toList();

    if (!_esGratis && tarifasValidas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Agrega al menos una tarifa o marca el destino como gratuito',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final horariosDestino = _horarios
          .map(
            (h) => HorarioDestino(
              horarioId: 0,
              diaSemana: h.dia,
              horaApertura: h.abierto
                  ? _formatearHora(h.horaApertura)
                  : '00:00:00',
              horaCierre: h.abierto
                  ? _formatearHora(h.horaCierre)
                  : '00:00:00',
              esCerrado: !h.abierto,
            ),
          )
          .toList();

      final tarifasDestino = _esGratis
          ? <TarifaDestino>[]
          : tarifasValidas
                .map(
                  (t) => TarifaDestino(
                    tarifaId: 0,
                    visitante: t.tipoVisitante,
                    precio:
                        double.tryParse(t.precioController.text.trim()) ?? 0,
                    moneda: t.moneda,
                    descripcion: t.descripcionController.text.trim(),
                  ),
                )
                .toList();

      final response = await DestinoService.crearDestino(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        categoriaId: _categoriaSeleccionada!.categoriaId,
        categoriaNombre: _categoriaSeleccionada!.nombre,
        departamento: _departamentoSeleccionado!,
        municipio: _municipioSeleccionado!,
        latitud: double.parse(_latitudController.text.trim()),
        longitud: double.parse(_longitudController.text.trim()),
        portada: _imagenPortada,
        imagenes: _imagenesGaleria,
        tiempoPromedioVisita: int.tryParse(
          _tiempoVisitaController.text.trim(),
        ),
        distanciaCheckinPermitida:
            int.tryParse(_distanciaCheckinController.text.trim()) ?? 30,
        esGratis: _esGratis,
        horarios: horariosDestino,
        tarifas: tarifasDestino,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isEmpty
                  ? 'Destino creado con éxito'
                  : response.message,
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isEmpty
                  ? 'No se pudo crear el destino (código ${response.statusCode})'
                  : response.message,
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final municipiosDisponibles = Departamentos.municipiosDe(
      _departamentoSeleccionado,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Crear destino')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _seccion('Información general'),
              _campoTexto(
                _nombreController,
                'Nombre del destino',
                requerido: true,
              ),
              const SizedBox(height: 16),
              _campoTexto(
                _descripcionController,
                'Descripción',
                requerido: true,
                lineas: 4,
              ),
              const SizedBox(height: 16),
              _buildLabel('Categoría', colors.primary),
              DropdownButtonFormField<CategoriaDestino>(
                initialValue: _categoriaSeleccionada,
                dropdownColor: Colors.white,
                decoration: _decoracion('Selecciona una categoría'),
                items: CategoriasDestino.lista
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c, child: Text(c.nombre)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _categoriaSeleccionada = v),
                validator: (v) =>
                    v == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 24),

              _seccion('Ubicación'),
              _buildLabel('Departamento', colors.primary),
              DropdownButtonFormField<String>(
                initialValue: _departamentoSeleccionado,
                dropdownColor: Colors.white,
                decoration: _decoracion('Selecciona un departamento'),
                items: Departamentos.nombresDepartamentos
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _departamentoSeleccionado = v;
                  _municipioSeleccionado = null;
                }),
                validator: (v) =>
                    v == null ? 'Selecciona un departamento' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Municipio', colors.primary),
              DropdownButtonFormField<String>(
                initialValue: _municipioSeleccionado,
                dropdownColor: Colors.white,
                decoration: _decoracion(
                  _departamentoSeleccionado == null
                      ? 'Selecciona primero un departamento'
                      : 'Selecciona un municipio',
                ),
                items: municipiosDisponibles
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.nombre,
                        child: Text(m.nombre),
                      ),
                    )
                    .toList(),
                onChanged: _departamentoSeleccionado == null
                    ? null
                    : (v) => setState(() => _municipioSeleccionado = v),
                validator: (v) =>
                    v == null ? 'Selecciona un municipio' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _campoTexto(
                      _latitudController,
                      'Latitud',
                      requerido: true,
                      teclado: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _campoTexto(
                      _longitudController,
                      'Longitud',
                      requerido: true,
                      teclado: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _obteniendoUbicacion
                      ? null
                      : _usarUbicacionActual,
                  icon: _obteniendoUbicacion
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: const Text('Usar mi ubicación actual'),
                ),
              ),
              const SizedBox(height: 24),

              _seccion('Imágenes'),
              _buildLabel('Portada', colors.primary),
              _selectorPortada(colors.primary),
              const SizedBox(height: 20),
              _buildLabel('Otras imágenes', colors.primary),
              SelectorImagenesResena(
                imagenes: _imagenesGaleria,
                onAgregar: _agregarImagenGaleria,
                onEliminar: _quitarImagenGaleria,
              ),
              const SizedBox(height: 24),

              _seccion('Visita'),
              Row(
                children: [
                  Expanded(
                    child: _campoTexto(
                      _tiempoVisitaController,
                      'Tiempo promedio (min)',
                      teclado: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _campoTexto(
                      _distanciaCheckinController,
                      'Distancia check-in (m)',
                      teclado: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Entrada gratuita'),
                value: _esGratis,
                activeThumbColor: colors.primary,
                onChanged: (v) => setState(() => _esGratis = v),
              ),
              const SizedBox(height: 16),

              _seccion('Horarios'),
              ..._horarios.map((h) => _filaHorario(h, colors.primary)),
              const SizedBox(height: 24),

              if (!_esGratis) ...[
                _seccion('Tarifas'),
                ..._tarifas.asMap().entries.map(
                  (entry) =>
                      _filaTarifa(entry.key, entry.value, colors.primary),
                ),
                TextButton.icon(
                  onPressed: _agregarTarifa,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar tarifa'),
                ),
                const SizedBox(height: 24),
              ],

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarDestino,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Crear destino',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textoOscuro,
        ),
      ),
    );
  }

  InputDecoration _decoracion(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }

  Widget _campoTexto(
    TextEditingController controller,
    String hint, {
    bool requerido = false,
    int lineas = 1,
    TextInputType? teclado,
  }) {
    return TextFormField(
      controller: controller,
      minLines: lineas,
      maxLines: lineas,
      keyboardType: teclado,
      decoration: _decoracion(hint),
      validator: requerido
          ? (v) => (v == null || v.trim().isEmpty)
                ? 'Este campo es obligatorio'
                : null
          : null,
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _selectorPortada(Color color) {
    return GestureDetector(
      onTap: _seleccionarPortada,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.colorBorde),
        ),
        child: _imagenPortada == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded, color: color, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Agregar imagen de portada',
                    style: TextStyle(color: AppTheme.textoSuave, fontSize: 13),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(_imagenPortada!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _imagenPortada = null),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _filaHorario(_HorarioDia horario, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.colorBorde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              horario.dia,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Switch(
            value: horario.abierto,
            activeThumbColor: color,
            onChanged: (v) => setState(() => horario.abierto = v),
          ),
          if (horario.abierto) ...[
            Expanded(
              child: TextButton(
                onPressed: () => _seleccionarHora(horario, esApertura: true),
                child: Text(_formatearHora(horario.horaApertura)),
              ),
            ),
            const Text('-'),
            Expanded(
              child: TextButton(
                onPressed: () => _seleccionarHora(horario, esApertura: false),
                child: Text(_formatearHora(horario.horaCierre)),
              ),
            ),
          ] else
            const Expanded(
              child: Text(
                'Cerrado',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _filaTarifa(int index, _TarifaForm tarifa, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.colorBorde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: tarifa.tipoVisitante,
                  dropdownColor: Colors.white,
                  decoration: _decoracion('Tipo de visitante'),
                  items: _tiposVisitante
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(
                    () => tarifa.tipoVisitante = v ?? tarifa.tipoVisitante,
                  ),
                ),
              ),
              if (_tarifas.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _quitarTarifa(index),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: tarifa.precioController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _decoracion('Precio'),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<String>(
                  initialValue: tarifa.moneda,
                  dropdownColor: Colors.white,
                  decoration: _decoracion('Moneda'),
                  items: Monedas.lista
                      .map(
                        (m) => DropdownMenuItem(
                          value: m.codigo,
                          child: Text(m.codigo),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => tarifa.moneda = v ?? tarifa.moneda),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: tarifa.descripcionController,
            decoration: _decoracion('Descripción (opcional)'),
          ),
        ],
      ),
    );
  }
}
