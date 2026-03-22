import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../app_theme.dart';
import '../../modelos/destino.dart';
import '../../servicios/destino_service.dart';
import '../perfil/perfil_screen.dart';
import '../ranking/ranking_screen.dart';
import 'destino_card.dart';
import 'modal_destino_aleatorio.dart';

class ExplorarDestinosScreen extends StatefulWidget {
  const ExplorarDestinosScreen({super.key});

  @override
  State<ExplorarDestinosScreen> createState() => _ExplorarDestinosScreenState();
}

class _ExplorarDestinosScreenState extends State<ExplorarDestinosScreen> {
  int _selectedIndex = 0;
  late Future<List<Destino>> _destinosFuture;
  String? _categoriaSeleccionada;
  String? _departamentoSeleccionado;
  List<Destino> _destinosCargados = [];

  BannerAd? _bannerAd;
  bool _bannerListo = false;

  // En producción reemplaza este ID por el tuyo de AdMob
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _destinosFuture = DestinoService.obtenerDestinos();
    _cargarBanner();
  }

  void _cargarBanner() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _bannerListo = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _refrescarDestinos() async {
    setState(() {
      _destinosFuture = DestinoService.obtenerDestinos();
    });
    await _destinosFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _pantallaInicio(theme),
          const RankingScreen(),
          const PerfilScreen(),
        ],
      ),
      bottomNavigationBar: _navBar(theme),
    );
  }

  Widget _navBar(ThemeData theme) {
    return Container(
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
    );
  }

  Widget _filtroDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(
          hint,
          style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        isDense: true,
        dropdownColor: Colors.white,
        iconEnabledColor: AppTheme.primaryColor,
        style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _pantallaInicio(ThemeData theme) {
    return SafeArea(
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
                        if (_destinosCargados.length >= 2) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black87,
                            builder: (_) => ModalDestinoAleatorio(
                              destinos: _destinosCargados,
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: _refrescarDestinos,
                    ),
                  ],
                ),
              ],
            ),
            if (_bannerListo && _bannerAd != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
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
                  _destinosCargados = destinos;

                  if (destinos.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay destinos disponibles',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  final categorias = destinos
                      .map((d) => d.categoria)
                      .toSet()
                      .toList();
                  final departamentos = destinos
                      .map((d) => d.departamento)
                      .toSet()
                      .toList();

                  final filtrados = destinos.where((d) {
                    if (_categoriaSeleccionada != null &&
                        d.categoria != _categoriaSeleccionada) {
                      return false;
                    }
                    if (_departamentoSeleccionado != null &&
                        d.departamento != _departamentoSeleccionado) {
                      return false;
                    }
                    return true;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _filtroDropdown<String>(
                              value: _categoriaSeleccionada,
                              hint: 'Categoría',
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Todas'),
                                ),
                                ...categorias.map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _categoriaSeleccionada = value,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _filtroDropdown<String>(
                              value: _departamentoSeleccionado,
                              hint: 'Departamento',
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Todos'),
                                ),
                                ...departamentos.map(
                                  (dep) => DropdownMenuItem(
                                    value: dep,
                                    child: Text(dep),
                                  ),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _departamentoSeleccionado = value,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtrados.isEmpty
                            ? Center(
                                child: Text(
                                  'No hay destinos con estos filtros',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 15,
                                      mainAxisSpacing: 15,
                                      childAspectRatio: 0.8,
                                    ),
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  return DestinoCard(destino: filtrados[index]);
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
