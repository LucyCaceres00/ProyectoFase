class TarifaDestino {
  final int tarifaId;
  final String visitante;
  final double precio;
  final String moneda;
  final String descripcion;

  TarifaDestino({
    required this.tarifaId,
    required this.visitante,
    required this.precio,
    required this.moneda,
    required this.descripcion,
  });

  factory TarifaDestino.fromJson(Map<String, dynamic> json) {
    final idRaw = json['TarifaId'] ?? json['tarifaId'] ?? json['tarifaid'];
    final precioRaw = json['Precio'] ?? json['precio'];
    return TarifaDestino(
      tarifaId:   idRaw != null ? (idRaw as num).toInt() : 0,
      visitante:  json['Visitante']  ?? json['visitante']  ?? '',
      precio:     precioRaw != null ? (precioRaw as num).toDouble() : 0.0,
      moneda:     json['Moneda']     ?? json['moneda']     ?? 'HNL',
      descripcion: json['Descripcion'] ?? json['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tarifaId': tarifaId,
      'Visitante': visitante,
      'precio': precio,
      'moneda': moneda,
      'descripcion': descripcion,
    };
  }
}
