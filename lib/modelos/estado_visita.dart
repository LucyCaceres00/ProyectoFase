class EstadoVisita {
  final bool tieneVisitaPendiente; // visitó pero aún no escribió reseña
  final int? visitaId;

  EstadoVisita({
    required this.tieneVisitaPendiente,
    this.visitaId,
  });

  factory EstadoVisita.fromJson(Map<String, dynamic> json) {
    return EstadoVisita(
      tieneVisitaPendiente: json['tieneVisitaPendiente'] ?? false,
      visitaId: json['visitaId'],
    );
  }
}
