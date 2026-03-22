class Visita {
  final int? visitaId;
  final int? usuarioId;
  final String? usuario;
  final String? destino;
  final String? fechaVisita;
  final String? ubicacionDestino;
  final int? destinoId;
  final int turipuntos;
  final double? latitud;
  final double? longitud;

  Visita({
    this.visitaId,
    this.usuarioId,
    this.usuario,
    this.destino,
    this.fechaVisita,
    this.ubicacionDestino,
    this.destinoId,
    required this.turipuntos,
    this.latitud,
    this.longitud,
  });

  factory Visita.fromJson(Map<String, dynamic> json) {
    return Visita(
      visitaId: json['visitaId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      usuario: json['usuario'],
      destino: json['destino'],
      fechaVisita: json['fechaVisita'],
      ubicacionDestino: json['ubicacionDestino'],
      turipuntos: json['turipuntos'],
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['latitud'] as num?)?.toDouble(),
    );
  }
}
