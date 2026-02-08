import 'package:flutter/material.dart';
import '../../modelos/destino.dart';
import '../inicio_sesion/inicio_sesion.dart';

class ExplorarDestinosScreen extends StatelessWidget {
  const ExplorarDestinosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de ejemplo basada en tu imagen
    final destinos = [
      Destino(
        'Ruinas de Copán',
        'Arqueología',
        'https://via.placeholder.com/150',
        4.8,
      ),
      Destino(
        'Islas de la Bahía',
        'Playas',
        'https://via.placeholder.com/150',
        4.9,
      ),
      Destino(
        'Parque Nacional La Tigra',
        'Naturaleza',
        'https://via.placeholder.com/150',
        4.6,
      ),
      Destino(
        'Centro Histórico',
        'Cultura',
        'https://via.placeholder.com/150',
        4.5,
      ),
      Destino(
        'Ruinas de Copán',
        'Arqueología',
        'https://via.placeholder.com/150',
        4.8,
      ),
      Destino(
        'Islas de la Bahía',
        'Playas',
        'https://via.placeholder.com/150',
        4.9,
      ),
      Destino(
        'Parque Nacional La Tigra',
        'Naturaleza',
        'https://via.placeholder.com/150',
        4.6,
      ),
      Destino(
        'Centro Histórico',
        'Cultura',
        'https://via.placeholder.com/150',
        4.5,
      ),
      Destino(
        'Ruinas de Copán',
        'Arqueología',
        'https://via.placeholder.com/150',
        4.8,
      ),
      Destino(
        'Islas de la Bahía',
        'Playas',
        'https://via.placeholder.com/150',
        4.9,
      ),
      Destino(
        'Parque Nacional La Tigra',
        'Naturaleza',
        'https://via.placeholder.com/150',
        4.6,
      ),
      Destino(
        'Centro Histórico',
        'Cultura',
        'https://via.placeholder.com/150',
        4.5,
      ),
    ];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F8F5,
      ), // Color de fondo suave según la imagen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Título con el icono aleatorio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explorar destinos',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme
                          .colorScheme
                          .surface, // Usando el verde de tu tema
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.shuffle, color: theme.colorScheme.surface),
                    onPressed: () {
                      // Lógica para destino aleatorio
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.logout_outlined, color: theme.colorScheme.surface),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Grid de destinos
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: destinos.length,
                  itemBuilder: (context, index) {
                    return _DestinoCard(destino: destinos[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar estilizada
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // El verde oscuro de tu tema
          borderRadius: BorderRadius.circular(30),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.lightGreenAccent,
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium_outlined),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinoCard extends StatelessWidget {
  final Destino destino;

  const _DestinoCard({required this.destino});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: NetworkImage(destino.imagen),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Detalles
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destino.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen.withValues(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    destino.categoria,
                    style: const TextStyle(color: Colors.green, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      destino.rating.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
