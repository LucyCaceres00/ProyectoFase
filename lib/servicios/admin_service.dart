import 'package:shared_preferences/shared_preferences.dart';

/// Guarda localmente si la sesión activa pertenece a un administrador.
///
/// La fuente de verdad es la columna `esadministrador` del usuario en el
/// backend (se recibe al iniciar sesión o registrarse); esto solo cachea
/// ese valor para que la UI pueda consultarlo de forma síncrona (por
/// ejemplo, al reabrir la app).
class AdminService {
  static const _keySesionEsAdmin = 'sesion_es_administrador';

  /// Guarda si la sesión actual (ya iniciada) pertenece a un administrador.
  static Future<void> establecerSesionAdministrador(bool esAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySesionEsAdmin, esAdmin);
  }

  /// Consulta si la sesión actual pertenece a un administrador.
  static Future<bool> esSesionAdministrador() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySesionEsAdmin) ?? false;
  }

  /// Limpia la bandera de sesión (usar al cerrar sesión).
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySesionEsAdmin);
  }
}
