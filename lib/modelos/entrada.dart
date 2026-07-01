class DetalleEntrada {
  final int tarifaId;
  final String tipoVisitante;
  final int cantidad;
  final double precioUnitario;

  DetalleEntrada({
    required this.tarifaId,
    required this.tipoVisitante,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toJson() => {
        'tarifaId': tarifaId,
        'tipoVisitante': tipoVisitante,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
      };
}

class EntradaComprada {
  final int? entradaId;
  final int usuarioId;
  final int destinoId;
  final int cantidadTotal;
  final double montoTotal;
  final String moneda;
  final String codigo;
  final String estado;
  final DateTime fechaCompra;
  final List<DetalleEntrada> detalles;

  EntradaComprada({
    this.entradaId,
    required this.usuarioId,
    required this.destinoId,
    required this.cantidadTotal,
    required this.montoTotal,
    required this.moneda,
    required this.codigo,
    this.estado = 'activa',
    required this.fechaCompra,
    required this.detalles,
  });

  factory EntradaComprada.fromJson(Map<String, dynamic> json) {
    return EntradaComprada(
      entradaId: json['entradaId'],
      usuarioId: json['usuarioId'] ?? 0,
      destinoId: json['destinoId'] ?? 0,
      cantidadTotal: json['cantidadTotal'] ?? 0,
      montoTotal: (json['montoTotal'] ?? 0).toDouble(),
      moneda: json['moneda'] ?? 'HNL',
      codigo: json['codigo'] ?? '',
      estado: json['estado'] ?? 'activa',
      fechaCompra: json['fechaCompra'] != null
          ? DateTime.parse(json['fechaCompra'])
          : DateTime.now(),
      detalles: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'destinoId': destinoId,
        'cantidadTotal': cantidadTotal,
        'montoTotal': montoTotal,
        'moneda': moneda,
        'codigo': codigo,
        'fechaCompra': fechaCompra.toIso8601String(),
        'detalles': detalles.map((d) => d.toJson()).toList(),
      };
}
