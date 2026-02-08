class Pais {
  final String nombre;
  final String codigo;
  final String bandera;

  const Pais({
    required this.nombre,
    required this.codigo,
    required this.bandera,
  });
}

class Paises {
  static const List<Pais> listaPaises = [
    Pais(nombre: 'Argentina', codigo: 'AR', bandera: '🇦🇷'),
    Pais(nombre: 'Bolivia', codigo: 'BO', bandera: '🇧🇴'),
    Pais(nombre: 'Brasil', codigo: 'BR', bandera: '🇧🇷'),
    Pais(nombre: 'Canadá', codigo: 'CA', bandera: '🇨🇦'),
    Pais(nombre: 'Chile', codigo: 'CL', bandera: '🇨🇱'),
    Pais(nombre: 'Colombia', codigo: 'CO', bandera: '🇨🇴'),
    Pais(nombre: 'Costa Rica', codigo: 'CR', bandera: '🇨🇷'),
    Pais(nombre: 'Cuba', codigo: 'CU', bandera: '🇨🇺'),
    Pais(nombre: 'Ecuador', codigo: 'EC', bandera: '🇪🇨'),
    Pais(nombre: 'El Salvador', codigo: 'SV', bandera: '🇸🇻'),
    Pais(nombre: 'España', codigo: 'ES', bandera: '🇪🇸'),
    Pais(nombre: 'Estados Unidos', codigo: 'US', bandera: '🇺🇸'),
    Pais(nombre: 'Guatemala', codigo: 'GT', bandera: '🇬🇹'),
    Pais(nombre: 'Honduras', codigo: 'HN', bandera: '🇭🇳'),
    Pais(nombre: 'México', codigo: 'MX', bandera: '🇲🇽'),
    Pais(nombre: 'Nicaragua', codigo: 'NI', bandera: '🇳🇮'),
    Pais(nombre: 'Panamá', codigo: 'PA', bandera: '🇵🇦'),
    Pais(nombre: 'Paraguay', codigo: 'PY', bandera: '🇵🇾'),
    Pais(nombre: 'Perú', codigo: 'PE', bandera: '🇵🇪'),
    Pais(nombre: 'Puerto Rico', codigo: 'PR', bandera: '🇵🇷'),
    Pais(nombre: 'República Dominicana', codigo: 'DO', bandera: '🇩🇴'),
    Pais(nombre: 'Uruguay', codigo: 'UY', bandera: '🇺🇾'),
    Pais(nombre: 'Venezuela', codigo: 'VE', bandera: '🇻🇪'),
    Pais(nombre: 'Otro', codigo: 'XX', bandera: '🌍'),
  ];

  static List<String> get nombresPaises =>
      listaPaises.map((p) => p.nombre).toList();
}
