import 'package:flutter/material.dart';
import 'app_theme.dart'; 
import 'paginas/inicio_sesion/inicio_sesion.dart'; 

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Proyecto',
      theme: AppTheme.lightTheme, 
      home: const LoginScreen(),
    );
  }
}