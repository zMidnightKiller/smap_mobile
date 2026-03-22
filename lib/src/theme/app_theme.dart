import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmapTheme {
  // Cores Base (Fallback)
  // Cores Base - Refinadas estilo Fintech
  static const Color primaryColor = Color(0xFF6366F1); // Indigo vibrante
  static const Color secondaryColor = Color(0xFFFB7185); // Rosa/Coral
  static const Color accentColor = Color(0xFF2DD4BF);   // Teal/Verde água
  static const Color backgroundColor = Color(0xFF0F111A); // Azul escuro profundo
  static const Color surfaceColor = Color(0xFF1E212E);   // Superfície mais clara
  static const Color errorColor = Color(0xFFF43F5E);
  static const Color textColor = Color(0xFFF8FAFC);
  static const Color textSecondaryColor = Color(0xFF94A3B8);
  static const Color cardColor = Color(0xFF1E212E);

  // Efeito Glassmorphism (Helper)
  static BoxDecoration glassDecoration({
    double opacity = 0.05,
    double blur = 15.0,
    double borderRadius = 24.0,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.08)),
    );
  }

  // Gradiente Premium para Cards (Estilo Fintech)
  static BoxDecoration gradientDecoration({
    double borderRadius = 32.0,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static ThemeData getDynamicTheme(Map<String, dynamic>? config) {
    Color dynamicPrimary = primaryColor;
    Color dynamicSecondary = secondaryColor;

    if (config != null) {
      if (config['cor_primaria'] != null) {
        try {
          dynamicPrimary = Color(int.parse(config['cor_primaria'].replaceFirst('#', '0xFF')));
        } catch (e) {
          debugPrint('Invalid primary color: ${config['cor_primaria']}');
        }
      }
      if (config['cor_secundaria'] != null) {
        try {
          dynamicSecondary = Color(int.parse(config['cor_secundaria'].replaceFirst('#', '0xFF')));
        } catch (e) {
          debugPrint('Invalid secondary color: ${config['cor_secundaria']}');
        }
      }
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: dynamicPrimary,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: dynamicPrimary,
        secondary: dynamicSecondary,
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
          borderSide: BorderSide(color: dynamicPrimary, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondaryColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dynamicPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 8,
          shadowColor: dynamicPrimary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: dynamicPrimary,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
      ),
    );
  }

  static ThemeData darkTheme = getDynamicTheme(null);
}
