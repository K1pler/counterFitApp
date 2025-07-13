import 'package:flutter/material.dart';

class AppColors {
  // Colores principales - Rojo y Negro elegante
  static const Color primaryRed = Color(0xFFDC143C); // Crimson elegante
  static const Color darkRed = Color(0xFF8B0000); // Rojo oscuro
  static const Color lightRed = Color(0xFFFF6B6B); // Rojo claro
  
  static const Color primaryBlack = Color(0xFF1C1C1C); // Negro principal
  static const Color darkBlack = Color(0xFF0D0D0D); // Negro más oscuro
  static const Color lightBlack = Color(0xFF2D2D2D); // Negro claro
  
  // Colores de superficie
  static const Color backgroundColor = Color(0xFF121212); // Fondo negro
  static const Color surfaceColor = Color(0xFF1E1E1E); // Superficie
  static const Color cardColor = Color(0xFF2A2A2A); // Tarjetas
  
  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF); // Texto principal blanco
  static const Color textSecondary = Color(0xFFB3B3B3); // Texto secundario gris
  static const Color textHint = Color(0xFF666666); // Texto de pista
  
  // Colores de acento
  static const Color accentColor = Color(0xFFFF4757); // Acento rojo vibrante
  static const Color successColor = Color(0xFF2ED573); // Verde para éxito
  static const Color warningColor = Color(0xFFFFA726); // Amarillo para advertencia
  static const Color errorColor = Color(0xFFFF5252); // Rojo para error
  
  // Colores de navegación
  static const Color bottomNavBackground = primaryBlack;
  static const Color bottomNavSelected = primaryRed;
  static const Color bottomNavUnselected = Color(0xFF707070);
  
  // Gradientes elegantes
  static const LinearGradient redGradient = LinearGradient(
    colors: [darkRed, primaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blackGradient = LinearGradient(
    colors: [darkBlack, lightBlack],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient redBlackGradient = LinearGradient(
    colors: [darkRed, primaryBlack],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 