class EstadoVisita {
  final bool tieneReseniaPendiente;
  final int? visitaId;

  EstadoVisita({
    required this.tieneReseniaPendiente,
    this.visitaId,
  });

  factory EstadoVisita.fromJson(Map<String, dynamic> json) {
    return EstadoVisita(
      tieneReseniaPendiente: json['tieneReseniaPendiente'] ?? false,
      visitaId: json['visitaId'],
    );
  }
}
