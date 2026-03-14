import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color.fromARGB(255, 40, 69, 214);
  static const Color secondaryColor = Color.fromARGB(255, 156, 207, 255);
  static const Color surfaceColor = Color.fromARGB(255, 139, 195, 74);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textoOscuro = Color(0xFF1A1A2E);
  static const Color textoSuave = Color(0xFF7B7B8F);
  static const Color colorEstrella = Color(0xFFFFC107);
  static const Color colorBorde = Color(0xFFE8E8F0);
  static const Color colorBordeChip = Color(0xFFE0E0E0);
  static const Color colorGoogleMaps = Color(0xFF4285F4);
  static const Color colorWaze = Color(0xFF00C0FF);
  static const Color colorFondoMapa = Color(0xFFDDE8F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: const Color.fromARGB(255, 206, 221, 93),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Color.fromARGB(255, 135, 14, 14),
      ),
    );
  }
}
