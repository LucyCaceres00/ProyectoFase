import 'package:flutter/material.dart';
import '../../modelos/destino.dart';
import '../../servicios/destino_service.dart';
import '../inicio_sesion/inicio_sesion.dart';
import 'destino_card.dart';

class ExplorarDestinosScreen extends StatefulWidget {
  const ExplorarDestinosScreen({super.key});

  @override
  State<ExplorarDestinosScreen> createState() => _ExplorarDestinosScreenState();
}

class _ExplorarDestinosScreenState extends State<ExplorarDestinosScreen> {
  int _selectedIndex = 0;
  late Future<List<Destino>> _destinosFuture;

  @override
  void initState() {
    super.initState();
    _destinosFuture = DestinoService.obtenerDestinos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
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
                        onPressed: () {},
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
                child: FutureBuilder<List<Destino>>(
                  future: _destinosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No se pudieron cargar los destinos',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () => setState(() {
                                _destinosFuture =
                                    DestinoService.obtenerDestinos();
                              }),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    final destinos = snapshot.data ?? [];

                    if (destinos.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay destinos disponibles',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: destinos.length,
                      itemBuilder: (context, index) {
                        return DestinoCard(destino: destinos[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 5, 12, 30),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(40),
        ),
        child: SizedBox(
          height: 60,
          child: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(0, 99, 4, 4),
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: const Color.fromARGB(255, 180, 29, 29),
            unselectedItemColor: Colors.white,
            showSelectedLabels: false,
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
