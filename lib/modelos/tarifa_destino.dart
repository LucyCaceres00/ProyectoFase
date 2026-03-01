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
    return TarifaDestino(
      tarifaId: json['tarifaId'] ?? 0,
      visitante: json['Visitante'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      moneda: json['moneda'] ?? '',
      descripcion: json['descripcion'] ?? '',
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
