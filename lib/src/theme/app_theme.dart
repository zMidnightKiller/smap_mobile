import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade visual do SMAP Mobile — estilo fintech claro (inspirado em
/// Nubank/Inter/Mercado Pago): fundo claro, cartões brancos com sombra suave,
/// cor de marca (roxo) e verde para valores positivos.
class SmapTheme {
  // Marca
  static const Color primaryColor = Color(0xFF7C3AED); // Roxo (marca)
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color secondaryColor = Color(0xFF9E77ED); // Roxo claro (gradiente)
  static const Color accentColor = Color(0xFF12B76A); // Verde (positivo/dinheiro)

  // Superfícies claras
  static const Color backgroundColor = Color(0xFFF4F5F7); // Fundo
  static const Color surfaceColor = Color(0xFFFFFFFF); // Cartões
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFEAECF0);
  static const Color fieldColor = Color(0xFFF2F4F7);

  // Texto
  static const Color textColor = Color(0xFF101828); // Principal (escuro)
  static const Color textSecondaryColor = Color(0xFF667085); // Secundário
  static const Color errorColor = Color(0xFFF04438);

  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF101828).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Cartão branco padrão do app (fintech): cantos arredondados, borda tênue e
  /// sombra suave.
  static BoxDecoration cardDecoration({double borderRadius = 20}) {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor),
      boxShadow: softShadow,
    );
  }

  /// Compatibilidade: antigo "glass" agora é um cartão branco claro.
  static BoxDecoration glassDecoration({
    double opacity = 0.05,
    double blur = 15.0,
    double borderRadius = 20.0,
    Color? borderColor,
  }) {
    return cardDecoration(borderRadius: borderRadius);
  }

  /// Cartão "hero" com gradiente da marca (ex.: faturamento).
  static BoxDecoration gradientDecoration({double borderRadius = 24.0}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: const LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.28),
          blurRadius: 24,
          offset: const Offset(0, 12),
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
          dynamicPrimary = Color(
            int.parse(config['cor_primaria'].replaceFirst('#', '0xFF')),
          );
        } catch (e) {
          debugPrint('Invalid primary color: ${config['cor_primaria']}');
        }
      }
      if (config['cor_secundaria'] != null) {
        try {
          dynamicSecondary = Color(
            int.parse(config['cor_secundaria'].replaceFirst('#', '0xFF')),
          );
        } catch (e) {
          debugPrint('Invalid secondary color: ${config['cor_secundaria']}');
        }
      }
    }

    final base = ThemeData.light();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: dynamicPrimary,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: dynamicPrimary,
        secondary: dynamicSecondary,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldColor,
        labelStyle: const TextStyle(color: textSecondaryColor),
        floatingLabelStyle: TextStyle(color: dynamicPrimary),
        prefixIconColor: textSecondaryColor,
        suffixIconColor: textSecondaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: dynamicPrimary, width: 1.6),
        ),
        hintStyle: const TextStyle(color: textSecondaryColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dynamicPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: dynamicPrimary),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return dynamicPrimary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: textSecondaryColor, width: 1.5),
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF1D2939),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: dynamicPrimary,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData lightTheme = getDynamicTheme(null);
}
