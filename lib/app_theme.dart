import 'package:flutter/material.dart';

class AppTheme {
  // Definimos los colores constantes
  static const Color primaryColor = Color.fromARGB(255, 40, 69, 214); // Morado
  static const Color secondaryColor = Color.fromARGB(255, 156, 207, 255); // Cian
  static const Color backgroundColor = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: const Color.fromARGB(255, 50, 127, 90),
      ),
      // También puedes personalizar botones aquí
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Color.fromARGB(255, 135, 14, 14),
      ),
    );
  }
}