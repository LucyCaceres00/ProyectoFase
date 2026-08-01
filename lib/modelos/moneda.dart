class Moneda {
  final String codigo;
  final String nombre;
  final String simbolo;

  const Moneda({
    required this.codigo,
    required this.nombre,
    required this.simbolo,
  });
}

class Monedas {
  static const List<Moneda> lista = [
    Moneda(codigo: 'HNL', nombre: 'Lempira hondureño', simbolo: 'L'),
    Moneda(codigo: 'USD', nombre: 'Dólar estadounidense', simbolo: '\$'),
    Moneda(codigo: 'EUR', nombre: 'Euro', simbolo: '€'),
  ];
}
