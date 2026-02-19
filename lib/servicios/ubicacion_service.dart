import 'package:geolocator/geolocator.dart';
import '../modelos/destino.dart';

class ResultadoUbicacion {
  final bool permitido;
  final double distancia;
  final String? error;

  ResultadoUbicacion({required this.permitido, this.distancia = 0, this.error});
}

class UbicacionService {
  static Future<ResultadoUbicacion> verificarCercania(Destino destino) async {
    // Verificar si el servicio de ubicación está habilitado
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      return ResultadoUbicacion(
        permitido: false,
        error: 'El servicio de ubicación está desactivado. Actívelo para continuar.',
      );
    }

    // Verificar y solicitar permisos
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return ResultadoUbicacion(
          permitido: false,
          error: 'Se necesita permiso de ubicación para hacer check-in.',
        );
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return ResultadoUbicacion(
        permitido: false,
        error: 'El permiso de ubicación fue denegado permanentemente. Habilítelo desde la configuración del dispositivo.',
      );
    }

    // Obtener posición actual
    final posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    // Calcular distancia en metros
    final distancia = Geolocator.distanceBetween(
      posicion.latitude,
      posicion.longitude,
      destino.latitud,
      destino.longitud,
    );

    final permitido = distancia <= destino.distanciacheckinpermitida;

    return ResultadoUbicacion(
      permitido: permitido,
      distancia: distancia,
    );
  }
}
