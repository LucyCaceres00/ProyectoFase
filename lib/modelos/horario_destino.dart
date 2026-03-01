class HorarioDestino {
  final int horarioId;
  final String diaSemana;
  final String horaApertura;
  final String horaCierre;
  final bool esCerrado;

  HorarioDestino({
    required this.horarioId,
    required this.diaSemana,
    required this.horaApertura,
    required this.horaCierre,
    required this.esCerrado,
  });

  factory HorarioDestino.fromJson(Map<String, dynamic> json) {
    return HorarioDestino(
      horarioId: json['horarioId'] ?? 0,
      diaSemana: json['diaSemana'] ?? '',
      horaApertura: json['horaApertura'] ?? '',
      horaCierre: json['horaCierre'] ?? '',
      esCerrado: json['esCerrado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'horarioId': horarioId,
      'diaSemana': diaSemana,
      'horaApertura': horaApertura,
      'horaCierre': horaCierre,
      'esCerrado': esCerrado,
    };
  }
}
