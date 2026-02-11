import 'package:flutter/material.dart';
import '../../modelos/destino.dart';
import '../inicio_sesion/inicio_sesion.dart';
import 'destino_card.dart';

class ExplorarDestinosScreen extends StatefulWidget {
  const ExplorarDestinosScreen({super.key});

  @override
  State<ExplorarDestinosScreen> createState() => _ExplorarDestinosScreenState();
}

class _ExplorarDestinosScreenState extends State<ExplorarDestinosScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Lista de ejemplo basada en tu imagen
    final destinos = [
      Destino(
        'Ruinas de Copán',
        'Arqueología',
        'https://images.unsplash.com/photo-1591551963955-9487b4973e84?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxDb3BhbiUyMHJ1aW5zJTIwSG9uZHVyYXMlMjBhcmNoYWVvbG9naWNhbHxlbnwxfHx8fDE3Njk5NzAyMzJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
        4.8,
      ),
      Destino(
        'Islas de la Bahía',
        'Playas',
        'https://images.unsplash.com/photo-1600273970168-c3db62dcf905?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxSb2F0YW4lMjBiZWFjaCUyMEhvbmR1cmFzJTIwdHJvcGljYWx8ZW58MXx8fHwxNzY5OTcwMjMyfDA&ixlib=rb-4.1.0&q=80&w=1080',
        4.9,
      ),
      Destino(
        'Parque Nacional La Tigra',
        'Naturaleza',
        'https://images.unsplash.com/photo-1656186349076-01691a1018db?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0cm9waWNhbCUyMGZvcmVzdCUyMHdhdGVyZmFsbCUyMEhvbmR1cmFzfGVufDF8fHx8MTc2OTk3MDIzNnww&ixlib=rb-4.1.0&q=80&w=1080',
        4.6,
      ),
      Destino(
        'Centro Histórico',
        'Cultura',
        'https://images.unsplash.com/photo-1635687202393-b7591bdaaafa?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2xvbmlhbCUyMGFyY2hpdGVjdHVyZSUyMENlbnRyYWwlMjBBbWVyaWNhfGVufDF8fHx8MTc2OTk3MDIzNnww&ixlib=rb-4.1.0&q=80&w=1080',
        4.5,
      ),
      Destino(
        'Ruinas de Copán',
        'Arqueología',
        'https://images.unsplash.com/photo-1645512483786-42b653b0a923?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxUZWd1Y2lnYWxwYSUyMGNpdHklMjBIb25kdXJhc3xlbnwxfHx8fDE3Njk5NzAyMzN8MA&ixlib=rb-4.1.0&q=80&w=1080',
        4.8,
      ),
      Destino(
        'Islas de la Bahía',
        'Playas',
        'https://images.unsplash.com/photo-1591551963955-9487b4973e84?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxDb3BhbiUyMHJ1aW5zJTIwSG9uZHVyYXMlMjBhcmNoYWVvbG9naWNhbHxlbnwxfHx8fDE3Njk5NzAyMzJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
        4.9,
      ),
      Destino(
        'Parque Nacional La Tigra',
        'Naturaleza',
        'https://images.unsplash.com/photo-1600273970168-c3db62dcf905?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxSb2F0YW4lMjBiZWFjaCUyMEhvbmR1cmFzJTIwdHJvcGljYWx8ZW58MXx8fHwxNzY5OTcwMjMyfDA&ixlib=rb-4.1.0&q=80&w=1080',
        4.6,
      ),
      Destino(
        'Centro Histórico',
        'Cultura',
        'https://images.unsplash.com/photo-1656186349076-01691a1018db?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0cm9waWNhbCUyMGZvcmVzdCUyMHdhdGVyZmFsbCUyMEhvbmR1cmFzfGVufDF8fHx8MTc2OTk3MDIzNnww&ixlib=rb-4.1.0&q=80&w=1080',
        4.5,
      ),
      Destino(
        'Ruinas de Copán',
        'Arqueología',
        'https://images.unsplash.com/photo-1635687202393-b7591bdaaafa?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2xvbmlhbCUyMGFyY2hpdGVjdHVyZSUyMENlbnRyYWwlMjBBbWVyaWNhfGVufDF8fHx8MTc2OTk3MDIzNnww&ixlib=rb-4.1.0&q=80&w=1080',
        4.8,
      ),
      Destino(
        'Islas de la Bahía',
        'Playas',
        'https://images.unsplash.com/photo-1645512483786-42b653b0a923?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxUZWd1Y2lnYWxwYSUyMGNpdHklMjBIb25kdXJhc3xlbnwxfHx8fDE3Njk5NzAyMzN8MA&ixlib=rb-4.1.0&q=80&w=1080',
        4.9,
      ),
      Destino(
        'Parque Nacional La Tigra',
        'Naturaleza',
        'https://images.unsplash.com/photo-1591551963955-9487b4973e84?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxDb3BhbiUyMHJ1aW5zJTIwSG9uZHVyYXMlMjBhcmNoYWVvbG9naWNhbHxlbnwxfHx8fDE3Njk5NzAyMzJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
        4.6,
      ),
      Destino(
        'Centro Histórico',
        'Cultura',
        'https://images.unsplash.com/photo-1600273970168-c3db62dcf905?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxSb2F0YW4lMjBiZWFjaCUyMEhvbmR1cmFzJTIwdHJvcGljYWx8ZW58MXx8fHwxNzY5OTcwMjMyfDA&ixlib=rb-4.1.0&q=80&w=1080',
        4.5,
      ),
    ];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explorar destinos',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          // Lógica para destino aleatorio
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.logout_outlined,
                          color: theme.colorScheme.primary,
                        ),
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
                ],
              ),
              const SizedBox(height: 5),
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
                    return DestinoCard(destino: destinos[index]);
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
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(40),
        ),
        child: SizedBox(
          height: 100,
          child: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(0, 99, 4, 4),
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                label: 'Inicio',
                icon: const Icon(Icons.home_filled),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home_filled,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: 'Ranking',
                icon: const Icon(Icons.workspace_premium_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: 'Perfil',
                icon: const Icon(Icons.person_outline),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
