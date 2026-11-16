import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de Colores Minimalista con Predominancia de Blanco y Tonos Pasteles
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceBorder = Color(0xFFE2E8F0);

  // Tonos Pasteles Artesanales
  static const Color woodPrimary = Color(0xFF456F55); // Verde Mate Pastel Elegante
  static const Color woodLight = Color(0xFF628E73);
  static const Color woodDark = Color(0xFF2E4F3B);

  // Pasteles de Acento y Fondos Suaves
  static const Color pastelSage = Color(0xFFEBF4EE); // Verde mate pastel muy suave
  static const Color pastelCream = Color(0xFFFAF6F0); // Crema pastel cálido
  static const Color pastelSand = Color(0xFFF3EDE3); // Arena pastel
  static const Color pastelCaramel = Color(0xFFD4A373); // Caramelo cuero pastel
  static const Color pastelCaramelSoft = Color(0xFFFDF7F0);

  // Textos para máxima legibilidad sobre blanco y pasteles
  static const Color textLight = Color(0xFF0F172A); // Slate profundo de alta legibilidad
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Estados
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFFE4E6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: woodPrimary,
      colorScheme: const ColorScheme.light(
        primary: woodPrimary,
        secondary: woodLight,
        surface: surface,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textLight,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textLight),
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: woodPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48), // Regla UX: Mínimo 48x48
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: woodPrimary,
          minimumSize: const Size(48, 48), // Regla UX: Mínimo 48x48
          side: const BorderSide(color: surfaceBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: woodPrimary,
          minimumSize: const Size(48, 48), // Regla UX: Mínimo 48x48
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: woodPrimary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 13),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textLight,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Alias para mantener compatibilidad
  static ThemeData get darkTheme => lightTheme;
}
