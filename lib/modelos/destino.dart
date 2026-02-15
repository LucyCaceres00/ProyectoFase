class Destino {
  final int destinoid;
  final String nombre;
  final String descripcion;
  final int categoriaid;
  final String categoria;
  final String departamento;
  final String municipio;
  final double latitud;
  final double longitud;
  final double calificacionpromedio;
  final int totalvisitas;
  final String estado;
  final String? imagenprincipal;
  final List<String>? galeriaimagenes;
  final String? tiempopromediovisita;
  final bool esgratis;

  Destino({
    required this.destinoid,
    required this.nombre,
    required this.descripcion,
    required this.categoriaid,
    required this.categoria,
    required this.departamento,
    required this.municipio,
    required this.latitud,
    required this.longitud,
    required this.calificacionpromedio,
    required this.totalvisitas,
    required this.estado,
    this.imagenprincipal,
    this.galeriaimagenes,
    this.tiempopromediovisita,
    required this.esgratis,
  });

  factory Destino.fromJson(Map<String, dynamic> json) {
    return Destino(
      destinoid: json['destinoid'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoriaid: json['categoriaid'] ?? 0,
      categoria: json['categoria'] ?? '',
      departamento: json['departamento'] ?? '',
      municipio: json['municipio'] ?? '',
      latitud: (json['latitud'] ?? 0).toDouble(),
      longitud: (json['longitud'] ?? 0).toDouble(),
      calificacionpromedio: (json['calificacionpromedio'] ?? 0).toDouble(),
      totalvisitas: json['totalvisitas'] ?? 0,
      estado: json['estado'] ?? '',
      imagenprincipal: json['imagenprincipal'],
      galeriaimagenes: json['galeriaimagenes'] != null
          ? List<String>.from(json['galeriaimagenes'])
          : null,
      tiempopromediovisita: json['tiempopromediovisita'],
      esgratis: json['esgratis'] ?? false,
    );
  }
}
