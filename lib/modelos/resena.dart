class Resena {
  final int usuarioId;
  final int destinoId;
  final int puntuacionAcceso;
  final int? puntuacionComida;
  final int puntuacionEstadoLugar;
  final int? puntuacionServicio;
  final double? puntuacionFinal;
  final String? comentario;
  final String? fechaResena;

  Resena({
    required this.usuarioId,
    required this.destinoId,
    required this.puntuacionAcceso,
    this.puntuacionComida,
    required this.puntuacionEstadoLugar,
    this.puntuacionServicio,
    this.puntuacionFinal,
    this.comentario,
    this.fechaResena,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      usuarioId: json['usuarioid'] ?? 0,
      destinoId: json['destinoid'] ?? 0,
      puntuacionAcceso: json['puntuacionacceso'] ?? 0,
      puntuacionComida: json['puntuacioncomida'],
      puntuacionEstadoLugar: json['puntuacionestadolugar'] ?? 0,
      puntuacionServicio: json['puntuacionservicio'],
      puntuacionFinal: (json['puntuacionfinal'] as num?)?.toDouble(),
      comentario: json['comentario'],
      fechaResena: json['fecharesena'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destinoid': destinoId,
      'puntuacionacceso': puntuacionAcceso,
      'puntuacioncomida': puntuacionComida ?? 0,
      'puntuacionestadolugar': puntuacionEstadoLugar,
      'puntuacionservicio': puntuacionServicio ?? 0,
      if (comentario != null && comentario!.isNotEmpty) 'comentario': comentario,
    };
  }
}
