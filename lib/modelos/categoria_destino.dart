class CategoriaDestino {
  final int categoriaId;
  final String nombre;

  const CategoriaDestino({required this.categoriaId, required this.nombre});
}

class CategoriasDestino {
  // Debe coincidir con "categoriadestinoenum" del backend.
  static const List<CategoriaDestino> lista = [
    CategoriaDestino(categoriaId: 1, nombre: 'Cultural'),
    CategoriaDestino(categoriaId: 2, nombre: 'Natural'),
    CategoriaDestino(categoriaId: 3, nombre: 'Gastronómico'),
    CategoriaDestino(categoriaId: 4, nombre: 'Aventura'),
    CategoriaDestino(categoriaId: 5, nombre: 'Histórico'),
  ];
}
