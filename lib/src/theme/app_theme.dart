import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmapTheme {
  // Cores Premium
  static const Color primaryColor = Color(0xFF8B5CF6); // Violeta vibrante
  static const Color secondaryColor = Color(0xFFEC4899); // Rosa vibrante
  static const Color accentColor = Color(0xFF10B981); // Esmeralda
  static const Color backgroundColor = Color(0xFF030712); // Cinza quase preto
  static const Color surfaceColor = Color(0xFF0F172A); // Slate escuro
  static const Color errorColor = Color(0xFFEF4444);
  static const Color textColor = Color(0xFFF9FAFB);
  static const Color textSecondaryColor = Color(0xFF94A3B8);

  // Efeito Glassmorphism (Helper)
  static BoxDecoration glassDecoration({
    double opacity = 0.1,
    double blur = 20.0,
    double borderRadius = 24.0,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withValues(alpha: opacity * 2)),
    );
  }

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textColor,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: textColor,
      displayColor: textColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor.withValues(alpha: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      hintStyle: const TextStyle(color: textSecondaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    ),
  );
}
