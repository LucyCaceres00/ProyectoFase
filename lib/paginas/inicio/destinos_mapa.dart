import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../app_theme.dart';
import '../../modelos/destino.dart';
import '../../servicios/destino_service.dart';
import 'destino_detalle.dart';

class DestinosMapaScreen extends StatefulWidget {
  final List<Destino> destinos;

  const DestinosMapaScreen({super.key, required this.destinos});

  @override
  State<DestinosMapaScreen> createState() => _DestinosMapaScreenState();
}

class _DestinosMapaScreenState extends State<DestinosMapaScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Destino? _destinoSeleccionado;
  bool _cargandoUbicacion = true;
  bool _ubicacionPermitida = false;
  bool _cargandoDestinos = false;

  // Posición inicial centrada en Honduras
  static const CameraPosition _posicionInicial = CameraPosition(
    target: LatLng(14.8, -86.8),
    zoom: 7.5,
  );

  @override
  void initState() {
    super.initState();
    if (widget.destinos.isNotEmpty) {
      _crearMarkers(widget.destinos);
    } else {
      _cargarDestinos();
    }
    _obtenerUbicacion();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _crearMarkers(List<Destino> destinos) {
    final markers = destinos.map((destino) {
      return Marker(
        markerId: MarkerId('destino_${destino.destinoid}'),
        position: LatLng(destino.latitud, destino.longitud),
        infoWindow: InfoWindow(
          title: destino.nombre,
          snippet: '${destino.categoria} · ${destino.municipio}',
        ),
        onTap: () {
          setState(() => _destinoSeleccionado = destino);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(destino.latitud, destino.longitud),
              13,
            ),
          );
        },
      );
    }).toSet();

    setState(() => _markers = markers);
  }

  Future<void> _cargarDestinos() async {
    setState(() => _cargandoDestinos = true);
    try {
      final destinos = await DestinoService.obtenerDestinos();
      if (mounted) _crearMarkers(destinos);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _cargandoDestinos = false);
    }
  }

  Future<void> _obtenerUbicacion() async {
    try {
      bool activo = await Geolocator.isLocationServiceEnabled();
      if (!activo) {
        setState(() => _cargandoUbicacion = false);
        return;
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        setState(() {
          _cargandoUbicacion = false;
          _ubicacionPermitida = false;
        });
        return;
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _cargandoUbicacion = false;
        _ubicacionPermitida = true;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(posicion.latitude, posicion.longitude),
          10,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _cargandoUbicacion = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Destinos en el mapa',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_markers.length} destinos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _posicionInicial,
            myLocationEnabled: _ubicacionPermitida,
            myLocationButtonEnabled: _ubicacionPermitida,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            onTap: (_) => setState(() => _destinoSeleccionado = null),
          ),

          // Indicador de carga de ubicación
          if (_cargandoUbicacion || _cargandoDestinos)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _cargandoDestinos
                            ? 'Cargando destinos...'
                            : 'Obteniendo ubicación...',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Tarjeta del destino seleccionado
          if (_destinoSeleccionado != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _tarjetaDestino(_destinoSeleccionado!),
            ),
        ],
      ),
    );
  }

  Widget _tarjetaDestino(Destino destino) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (destino.imagenprincipal != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                destino.imagenprincipal!,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destino.nombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${destino.municipio}, ${destino.departamento}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              destino.categoria,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            destino.calificacionpromedio.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DestinoDetalleScreen(destino: destino),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ver',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
