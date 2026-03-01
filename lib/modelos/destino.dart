import 'horario_destino.dart';
import 'tarifa_destino.dart';

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
  final int? tiempopromediovisita;
  final int distanciacheckinpermitida;
  final bool esgratis;
  final List<HorarioDestino>? horariosDestino;
  final List<TarifaDestino>? tarifasDestino;

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
    required this.distanciacheckinpermitida,
    required this.esgratis,
    this.horariosDestino,
    this.tarifasDestino,
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
      distanciacheckinpermitida: json['distanciaCheckinPermitida'] ?? 0,
      esgratis: json['esgratis'] ?? false,
      horariosDestino: json['horariosDestino'] != null
          ? (json['horariosDestino'] as List)
              .map((h) => HorarioDestino.fromJson(h))
              .toList()
          : null,
      tarifasDestino: json['tarifasDestino'] != null
          ? (json['tarifasDestino'] as List)
              .map((t) => TarifaDestino.fromJson(t))
              .toList()
          : null,
    );
  }
}
