import 'package:flutter/material.dart';

class AppTheme {
  // Definimos los colores constantes
  static const Color primaryColor = Color(0xFF6200EE); // Morado
  static const Color secondaryColor = Color(0xFF03DAC6); // Cian
  static const Color backgroundColor = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
      ),
      // También puedes personalizar botones aquí
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}