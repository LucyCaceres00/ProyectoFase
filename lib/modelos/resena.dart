class Resena {
  final int usuarioId;
  final int destinoId;
  final int puntuacionAcceso;
  final int? puntuacionComida;
  final int puntuacionEstadoLugar;
  final int? puntuacionServicio;
  final String? comentario;

  Resena({
    required this.usuarioId,
    required this.destinoId,
    required this.puntuacionAcceso,
    this.puntuacionComida,
    required this.puntuacionEstadoLugar,
    this.puntuacionServicio,
    this.comentario,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'destinoId': destinoId,
      'puntuacionAcceso': puntuacionAcceso,
      if (puntuacionComida != null) 'puntuacionComida': puntuacionComida,
      'puntuacionEstadoLugar': puntuacionEstadoLugar,
      if (puntuacionServicio != null) 'puntuacionServicio': puntuacionServicio,
      if (comentario != null && comentario!.isNotEmpty) 'comentario': comentario,
    };
  }
}
