import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../app_theme.dart';
import '../../servicios/perfil_service.dart';
import '../../servicios/registro_service.dart';

class _Movimiento {
  final String concepto;
  final String detalle;
  final int puntos;
  final bool esIngreso;
  final String fecha;

  const _Movimiento({
    required this.concepto,
    required this.detalle,
    required this.puntos,
    required this.esIngreso,
    required this.fecha,
  });
}

class TuriPuntosScreen extends StatefulWidget {
  const TuriPuntosScreen({super.key});

  @override
  State<TuriPuntosScreen> createState() => _TuriPuntosScreenState();
}

class _TuriPuntosScreenState extends State<TuriPuntosScreen> {
  int? _saldoActual;
  bool _cargando = true;

  static const List<_Movimiento> _movimientos = [
    _Movimiento(
      concepto: 'Visita registrada',
      detalle: 'Cascada El Salto',
      puntos: 25,
      esIngreso: true,
      fecha: '20/03/2026',
    ),
    _Movimiento(
      concepto: 'Canje: Entrada gratis',
      detalle: 'Parque Natural Los Álamos',
      puntos: 80,
      esIngreso: false,
      fecha: '18/03/2026',
    ),
    _Movimiento(
      concepto: 'Visita registrada',
      detalle: 'Laguna de Alegría',
      puntos: 30,
      esIngreso: true,
      fecha: '15/03/2026',
    ),
    _Movimiento(
      concepto: 'Reseña enviada',
      detalle: 'Laguna de Alegría',
      puntos: 10,
      esIngreso: true,
      fecha: '15/03/2026',
    ),
    _Movimiento(
      concepto: 'Visita registrada',
      detalle: 'Volcán Santa Ana',
      puntos: 40,
      esIngreso: true,
      fecha: '10/03/2026',
    ),
    _Movimiento(
      concepto: 'Canje: Descuento 50%',
      detalle: 'Cascada El Salto',
      puntos: 40,
      esIngreso: false,
      fecha: '08/03/2026',
    ),
    _Movimiento(
      concepto: 'Visita registrada',
      detalle: 'Ruta de las Flores',
      puntos: 20,
      esIngreso: true,
      fecha: '01/03/2026',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cargarSaldo();
  }

  Future<void> _cargarSaldo() async {
    try {
      final perfil = await PerfilService.obtenerInformacionUsuario();
      if (mounted) setState(() => _saldoActual = perfil.turiPuntos);
    } catch (_) {
      if (mounted) setState(() => _saldoActual = null);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mis TuriPuntos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          children: [
            // ── Tarjeta de saldo ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF1A37B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white70, size: 36),
                  const SizedBox(height: 10),
                  const Text(
                    'Saldo disponible',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _cargando
                      ? const SizedBox(
                          height: 52,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white60,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : Text(
                          _saldoActual != null ? '$_saldoActual' : '—',
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                  const Text(
                    'TuriPuntos',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Botón canjear ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _cargando || _saldoActual == null
                          ? null
                          : () => _mostrarDialogoCanjear(context),
                      icon: const Icon(Icons.qr_code_rounded, size: 20),
                      label: const Text(
                        'Canjear TuriPuntos',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: Colors.white38,
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Encabezado historial ─────────────────────────────────────
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'HISTORIAL DE MOVIMIENTOS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textoSuave,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // ── Lista de movimientos ─────────────────────────────────────
            ..._movimientos.map((m) => _filaMovimiento(m)),
          ],
        ),
      ),
    );
  }

  Widget _filaMovimiento(_Movimiento m) {
    final color = m.esIngreso ? AppTheme.surfaceColor : Colors.red;

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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              m.esIngreso
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.concepto,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textoOscuro,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  m.detalle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textoSuave,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                m.fecha,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textoSuave,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${m.esIngreso ? '+' : '-'} ${m.puntos} pts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCanjear(BuildContext screenContext) {
    final saldo = _saldoActual!;
    final controller = TextEditingController();
    String? errorTexto;

    showModalBottomSheet(
      context: screenContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
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
                'Canjear TuriPuntos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textoOscuro,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saldo disponible: $saldo pts',
                style: const TextStyle(fontSize: 13, color: AppTheme.textoSuave),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: '¿Cuántos puntos quieres canjear?',
                  hintText: 'Ej: 50',
                  errorText: errorTexto,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.colorBorde),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  suffixText: 'pts',
                ),
                onChanged: (value) {
                  final ingresado = int.tryParse(value);
                  setModalState(() {
                    if (ingresado == null || value.isEmpty) {
                      errorTexto = null;
                    } else if (ingresado <= 0) {
                      errorTexto = 'Ingresa un valor mayor a 0';
                    } else if (ingresado > saldo) {
                      errorTexto = 'No puedes canjear más de $saldo pts';
                    } else {
                      errorTexto = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final ingresado = int.tryParse(controller.text);
                    if (ingresado == null || ingresado <= 0) {
                      setModalState(() => errorTexto = 'Ingresa una cantidad válida');
                      return;
                    }
                    if (ingresado > saldo) {
                      setModalState(() => errorTexto = 'No puedes canjear más de $saldo pts');
                      return;
                    }
                    Navigator.pop(sheetContext);
                    _mostrarQR(screenContext, ingresado);
                  },
                  icon: const Icon(Icons.qr_code_rounded),
                  label: const Text(
                    'Generar código QR',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarQR(BuildContext context, int puntos) {
    final usuarioId = RegistrarService().usuarioId ?? 0;
    final qrData = '{"accion":"canje_turipuntos","puntos":$puntos,"usuarioId":$usuarioId}';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Código QR de Canje',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textoOscuro,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Muestra este código para canjear $puntos TuriPuntos',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textoSuave),
              ),
              const SizedBox(height: 24),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$puntos pts',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
