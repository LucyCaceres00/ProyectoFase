import 'package:flutter/material.dart';
import '../../modelos/paises.dart';

class SelectorPaisDialog extends StatefulWidget {
  const SelectorPaisDialog({super.key});

  @override
  State<SelectorPaisDialog> createState() => _SelectorPaisDialogState();
}

class _SelectorPaisDialogState extends State<SelectorPaisDialog> {
  final TextEditingController _busquedaController = TextEditingController();
  List<Pais> _paisesFiltrados = Paises.listaPaises;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _filtrarPaises(String query) {
    setState(() {
      if (query.isEmpty) {
        _paisesFiltrados = Paises.listaPaises;
      } else {
        _paisesFiltrados = Paises.listaPaises
            .where((pais) =>
                pais.nombre.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Título
            Text(
              'Selecciona tu país',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Campo de búsqueda
            TextField(
              controller: _busquedaController,
              onChanged: _filtrarPaises,
              decoration: InputDecoration(
                hintText: 'Buscar país...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busquedaController.clear();
                          _filtrarPaises('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lista de países filtrados
            Expanded(
              child: _paisesFiltrados.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron países',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _paisesFiltrados.length,
                      itemBuilder: (context, index) {
                        final pais = _paisesFiltrados[index];
                        return ListTile(
                          leading: Text(
                            pais.bandera,
                            style: const TextStyle(fontSize: 32),
                          ),
                          title: Text(
                            pais.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(pais.nombre);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hoverColor: colors.primary.withValues(alpha: 0.1),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            // Botón cancelar
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
