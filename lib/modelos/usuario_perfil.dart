class UsuarioPerfil {
  final String nombre;
  final String pais;
  final String? foto;
  final String? nivelExplorador;
  final int turiPuntos;
  final int totalResenias;
  final int totalVisitas;
  final String? correo;

  UsuarioPerfil({
    required this.nombre,
    required this.pais,
    this.foto,
    this.nivelExplorador,
    required this.turiPuntos,
    required this.totalResenias,
    required this.totalVisitas,
    this.correo
  });

  String get iniciales {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.substring(0, nombre.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory UsuarioPerfil.fromJson(Map<String, dynamic> json) {
    return UsuarioPerfil(
      nombre: json['nombre'] ?? '',
      pais: json['pais'] ?? '',
      foto: json['foto'],
      nivelExplorador: json['nivelExplorador'],
      turiPuntos: (json['turiPuntos'] ?? 0) as int,
      totalResenias: (json['totalResenias'] ?? 0) as int,
      totalVisitas: (json['totalVisitas'] ?? 0) as int,
      correo: (json['correo'])
    );
  }
}
