class RankingUsuario {
  final int posicion;
  final int usuarioId;
  final String nombre;
  final int turiPuntos;
  final int totalVisitas;
  final String? foto;

  RankingUsuario({
    required this.posicion,
    required this.usuarioId,
    required this.nombre,
    required this.turiPuntos,
    required this.totalVisitas,
    this.foto,
  });

  String get iniciales {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.substring(0, nombre.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory RankingUsuario.fromJson(Map<String, dynamic> json) {
    return RankingUsuario(
      posicion: json['posicion'] ?? 0,
      usuarioId: json['usuarioId'] ?? json['UsuarioId'] ?? 0,
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      turiPuntos: json['turiPuntos'] ?? json['TuriPuntos'] ?? 0,
      totalVisitas: json['totalVisitas'] ?? json['TotalVisitas'] ?? 0,
      foto: json['foto'] ?? json['Foto'],
    );
  }
}
