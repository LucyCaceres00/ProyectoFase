import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';
import '../../modelos/destino.dart';
import '../../modelos/tarifa_destino.dart';
import '../../servicios/registro_service.dart';
import '../../servicios/ubicacion_service.dart';
import '../../servicios/visita_service.dart';
import '../../widgets/app_dialogo.dart';
import '../../modelos/entrada.dart';
import '../../servicios/entrada_service.dart';

class PagoEntradaScreen extends StatefulWidget {
  final Destino destino;
  final ResultadoUbicacion? resultado;

  const PagoEntradaScreen({
    super.key,
    required this.destino,
    this.resultado,
  });

  @override
  State<PagoEntradaScreen> createState() => _PagoEntradaScreenState();
}

class _PagoEntradaScreenState extends State<PagoEntradaScreen> {
  // Mapa tarifaId → cantidad seleccionada
  final Map<int, int> _cantidades = {};

  final _formKey = GlobalKey<FormState>();
  final _tarjetaCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();

  bool _procesando = false;
  bool _pagado = false;
  String? _codigo;
  int? _entradaId;

  static const int _maxPorTipo = 10;

  List<TarifaDestino> get _tarifas => widget.destino.tarifasDestino ?? [];

  double get _total => _tarifas.asMap().entries.fold(
        0.0,
        (sum, e) => sum + e.value.precio * (_cantidades[e.key] ?? 0),
      );

  int get _totalEntradas =>
      _cantidades.values.fold(0, (sum, c) => sum + c);

  bool get _esPago => _total > 0;

  // Retorna pares (índice, tarifa) donde se seleccionó al menos 1 entrada
  List<MapEntry<int, TarifaDestino>> get _entradasSeleccionadas =>
      _tarifas.asMap().entries
          .where((e) => (_cantidades[e.key] ?? 0) > 0)
          .toList();

  @override
  void dispose() {
    _tarjetaCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  // ── Formateo ─────────────────────────────────────────────────────────────────

  String _simbolo(String moneda) => switch (moneda.toUpperCase()) {
        'USD' => '\$',
        'EUR' => '€',
        _ => 'L',
      };

  String _formatMonto(double monto, String moneda) {
    final s = _simbolo(moneda);
    final valor = monto.truncateToDouble() == monto
        ? monto.toInt().toString()
        : monto.toStringAsFixed(2);
    return '$s $valor';
  }

  String _formatPrecioTarifa(TarifaDestino t) =>
      t.precio == 0 ? 'Gratis' : _formatMonto(t.precio, t.moneda);

  String _formatTotal() {
    if (_tarifas.isEmpty) return '—';
    if (_total == 0) return 'Gratis';
    return _formatMonto(_total, _tarifas.first.moneda);
  }

  IconData _iconoVisitante(String tipo) {
    final t = tipo.toLowerCase();
    if (t.contains('niño') || t.contains('child')) return Icons.child_care_outlined;
    if (t.contains('estudiante') || t.contains('student')) return Icons.school_outlined;
    if (t.contains('adulto mayor') || t.contains('senior') || t.contains('tercera edad')) {
      return Icons.elderly_outlined;
    }
    if (t.contains('extranjero') || t.contains('foreign')) return Icons.public_outlined;
    return Icons.person_outline;
  }

  // ── Acciones ─────────────────────────────────────────────────────────────────

  Future<void> _procesarPago() async {
    if (_totalEntradas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una entrada')),
      );
      return;
    }

    if (_esPago && !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _procesando = true);

    if (_esPago) await Future.delayed(const Duration(seconds: 2));

    final codigo = EntradaService.generarCodigo();
    int? entradaId;

    try {
      final entrada = await EntradaService.registrarEntrada(
        destinoId: widget.destino.destinoid,
        cantidadTotal: _totalEntradas,
        montoTotal: _total,
        moneda: _tarifas.isNotEmpty ? _tarifas.first.moneda : 'HNL',
        codigo: codigo,
        detalles: _entradasSeleccionadas
            .map((e) => DetalleEntrada(
                  tarifaId: e.value.tarifaId,
                  tipoVisitante: e.value.visitante,
                  cantidad: _cantidades[e.key]!,
                  precioUnitario: e.value.precio,
                ))
            .toList(),
      );
      entradaId = entrada.entradaId;
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar entrada: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _procesando = false;
      _pagado = true;
      _codigo = codigo;
      _entradaId = entradaId;
    });
  }

  Future<void> _registrarCheckin() async {
    if (widget.resultado == null) {
      Navigator.pop(context);
      return;
    }

    setState(() => _procesando = true);

    try {
      final usuarioId = RegistrarService().usuarioId ?? 0;
      await VisitaService.guardarVisita(
        usuarioId: usuarioId,
        destinoId: widget.destino.destinoid,
        latitud: widget.resultado!.latitud!,
        longitud: widget.resultado!.longitud!,
      );

      if (_entradaId != null) {
        await EntradaService.marcarUsada(_entradaId!);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);

      final esNoAutorizado =
          e.toString().contains('No autorizado') || e.toString().contains('sesión');
      AppDialogo.mostrar(
        context,
        icono: esNoAutorizado ? Icons.lock_outline : Icons.error_outline,
        titulo: esNoAutorizado ? 'Sesión requerida' : 'Error al registrar',
        mensaje: esNoAutorizado
            ? 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'
            : 'No se pudo registrar la visita. Por favor, intente nuevamente.',
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textoOscuro),
          onPressed: _procesando ? null : () => Navigator.pop(context),
        ),
        title: Text(
          _pagado
              ? (widget.resultado == null ? 'Entrada confirmada' : 'Confirmar visita')
              : (widget.resultado == null ? 'Comprar entrada' : 'Pago de entrada'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textoOscuro,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _pagado ? _vistaExito() : _vistaFormulario(),
                ),
              ),
              _pagado ? _botonCheckin() : _botonPagar(),
            ],
          ),
          if (_procesando)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    const SizedBox(height: 16),
                    Text(
                      _pagado ? 'Registrando visita...' : 'Procesando pago...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Vista formulario (fase 1) ─────────────────────────────────────────────────

  Widget _vistaFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _destinoCard(),
        const SizedBox(height: 24),
        _seccionCantidades(),
        if (_esPago) ...[
          const SizedBox(height: 24),
          _seccionTarjeta(),
        ],
        const SizedBox(height: 24),
        _totalCard(),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Vista éxito (fase 2) ──────────────────────────────────────────────────────

  Widget _vistaExito() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Cabecera éxito ───────────────────────────────────────────
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 14),
              Text(
                _esPago ? '¡Pago exitoso!' : '¡Entradas confirmadas!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textoOscuro,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ya puedes ingresar a ${widget.destino.nombre}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textoSuave),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Código de entrada ────────────────────────────────────────
        _tarjetaCodigo(),
        const SizedBox(height: 24),

        // ── Destino ──────────────────────────────────────────────────
        _destinoCard(),
        const SizedBox(height: 24),

        // ── Resumen de entradas ──────────────────────────────────────
        _labelSeccion('RESUMEN DE ENTRADAS'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colorBorde),
          ),
          child: Column(
            children: [
              ..._entradasSeleccionadas.asMap().entries.map((outer) {
                final i = outer.key;
                final idx = outer.value.key;
                final tarifa = outer.value.value;
                final cantidad = _cantidades[idx]!;
                final subtotal = tarifa.precio * cantidad;
                final esUltima = i == _entradasSeleccionadas.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _iconoVisitante(tarifa.visitante),
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tarifa.visitante,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textoOscuro,
                              ),
                            ),
                          ),
                          Text(
                            '${cantidad}x',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textoSuave,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            subtotal == 0
                                ? 'Gratis'
                                : _formatMonto(subtotal, tarifa.moneda),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: subtotal == 0 ? Colors.green : AppTheme.textoOscuro,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!esUltima)
                      const Divider(height: 1, indent: 64, color: AppTheme.colorBorde),
                  ],
                );
              }),
              if (_esPago) ...[
                const Divider(height: 1, color: AppTheme.colorBorde),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total pagado',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textoOscuro,
                        ),
                      ),
                      Text(
                        _formatTotal(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Tarjeta código ────────────────────────────────────────────────────────────

  Widget _tarjetaCodigo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'CÓDIGO DE ENTRADA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _codigo ?? '—',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (_codigo != null) {
                    Clipboard.setData(ClipboardData(text: _codigo!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Código copiado al portapapeles'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Icon(
                  Icons.copy_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Presenta este código al ingresar al destino',
            style: TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Destino card ──────────────────────────────────────────────────────────────

  Widget _destinoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colorBorde),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.place_rounded, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.destino.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textoOscuro,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.destino.municipio}, ${widget.destino.departamento}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textoSuave),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sección cantidades ────────────────────────────────────────────────────────

  Widget _seccionCantidades() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelSeccion('ENTRADAS'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colorBorde),
          ),
          child: Column(
            children: _tarifas.asMap().entries.map((entry) {
              final i = entry.key;
              final tarifa = entry.value;
              final esUltima = i == _tarifas.length - 1;
              return Column(
                children: [
                  _filaCantidad(tarifa, i),
                  if (!esUltima)
                    const Divider(height: 1, indent: 64, color: AppTheme.colorBorde),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _filaCantidad(TarifaDestino tarifa, int index) {
    final cantidad = _cantidades[index] ?? 0;
    final esGratis = tarifa.precio == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cantidad > 0
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.colorBorde.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconoVisitante(tarifa.visitante),
              size: 20,
              color: cantidad > 0 ? AppTheme.primaryColor : AppTheme.textoSuave,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarifa.visitante,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cantidad > 0 ? AppTheme.textoOscuro : AppTheme.textoSuave,
                  ),
                ),
                Text(
                  _formatPrecioTarifa(tarifa),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: esGratis ? Colors.green : AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Selector [-] N [+]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _botonCantidad(
                icon: Icons.remove_rounded,
                activo: cantidad > 0,
                onTap: cantidad > 0
                    ? () => setState(
                          () => _cantidades[index] = cantidad - 1,
                        )
                    : null,
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$cantidad',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: cantidad > 0 ? AppTheme.textoOscuro : AppTheme.textoSuave,
                  ),
                ),
              ),
              _botonCantidad(
                icon: Icons.add_rounded,
                activo: true,
                onTap: cantidad < _maxPorTipo
                    ? () => setState(
                          () => _cantidades[index] = cantidad + 1,
                        )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonCantidad({
    required IconData icon,
    required bool activo,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: activo && onTap != null
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.colorBorde.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: activo && onTap != null ? AppTheme.primaryColor : AppTheme.textoSuave,
        ),
      ),
    );
  }

  // ── Sección tarjeta ───────────────────────────────────────────────────────────

  Widget _seccionTarjeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelSeccion('DATOS DE LA TARJETA'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colorBorde),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Número
                TextFormField(
                  controller: _tarjetaCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_CardNumberFormatter()],
                  style: const TextStyle(fontSize: 16, letterSpacing: 1.5),
                  decoration: _inputDeco(
                    label: 'Número de tarjeta',
                    hint: '1234 5678 9012 3456',
                    icon: Icons.credit_card_rounded,
                  ),
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(' ', '');
                    if (digits.isEmpty) return 'Ingresa el número de tarjeta';
                    if (digits.length != 16) return 'Debe tener 16 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                // Expiración + CVV
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_ExpiryFormatter()],
                        decoration: _inputDeco(
                          label: 'Expiración',
                          hint: 'MM/AA',
                          icon: Icons.calendar_today_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (v.length != 5) return 'MM/AA';
                          final parts = v.split('/');
                          final mes = int.tryParse(parts[0]);
                          final anio = int.tryParse(parts[1]);
                          if (mes == null || anio == null) return 'Inválida';
                          if (mes < 1 || mes > 12) return 'Mes inválido';
                          final ahora = DateTime.now();
                          final anioCompleto = 2000 + anio;
                          if (anioCompleto < ahora.year ||
                              (anioCompleto == ahora.year && mes < ahora.month)) {
                            return 'Tarjeta expirada';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        obscureText: true,
                        decoration: _inputDeco(
                          label: 'CVV',
                          hint: '•••',
                          icon: Icons.lock_outline_rounded,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (v.length < 3) return '3-4 dígitos';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Nombre
                TextFormField(
                  controller: _nombreCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _inputDeco(
                    label: 'Nombre del titular',
                    hint: 'COMO APARECE EN LA TARJETA',
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa el nombre del titular';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Total card ────────────────────────────────────────────────────────────────

  Widget _totalCard() {
    final sinEntradas = _totalEntradas == 0;
    final esGratis = !_esPago && !sinEntradas;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: sinEntradas
            ? AppTheme.colorBorde.withValues(alpha: 0.2)
            : esGratis
                ? Colors.green.withValues(alpha: 0.06)
                : AppTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: sinEntradas
              ? AppTheme.colorBorde
              : esGratis
                  ? Colors.green.withValues(alpha: 0.3)
                  : AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total a pagar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: sinEntradas
                  ? AppTheme.textoSuave
                  : esGratis
                      ? Colors.green.shade700
                      : AppTheme.textoOscuro,
            ),
          ),
          Text(
            sinEntradas ? '—' : _formatTotal(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: sinEntradas
                  ? AppTheme.textoSuave
                  : esGratis
                      ? Colors.green
                      : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Botón pagar (fase 1) ──────────────────────────────────────────────────────

  Widget _botonPagar() {
    final habilitado = _totalEntradas > 0 && !_procesando;

    return _contenedorBoton(
      child: ElevatedButton(
        onPressed: habilitado ? _procesarPago : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _esPago ? AppTheme.surfaceColor : Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.colorBorde,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_esPago ? Icons.payment_rounded : Icons.check_circle_outline, size: 20),
            const SizedBox(width: 8),
            Text(
              _esPago ? 'Pagar' : 'Confirmar entradas',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  // ── Botón check-in (fase 2) ───────────────────────────────────────────────────

  Widget _botonCheckin() {
    return _contenedorBoton(
      child: ElevatedButton(
        onPressed: _procesando ? null : _registrarCheckin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.colorBorde,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _procesando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.resultado == null
                        ? Icons.check_rounded
                        : Icons.check_circle_outline,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.resultado == null ? 'Listo' : 'Hacer Check-In',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _contenedorBoton({required Widget child}) {
    return Container(
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
      child: SizedBox(width: double.infinity, height: 52, child: child),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Widget _labelSeccion(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textoSuave,
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration _inputDeco({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppTheme.textoSuave),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.colorBorde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.colorBorde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F8FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

// ── Formateadores ─────────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(truncated[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 4 ? digits.substring(0, 4) : digits;

    final formatted = truncated.length <= 2
        ? truncated
        : '${truncated.substring(0, 2)}/${truncated.substring(2)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
