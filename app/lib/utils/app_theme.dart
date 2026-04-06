import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────────────
  static const Color bgPrimary    = Color(0xFF0A0F0A);  // deep forest black
  static const Color bgSecondary  = Color(0xFF111811);  // dark green-black
  static const Color bgCard       = Color(0xFF162116);  // card background
  static const Color bgInput      = Color(0xFF0E160E);  // input bg

  static const Color neonGreen    = Color(0xFF39FF14);  // neon green
  static const Color primaryGreen = Color(0xFF00C853);  // emerald green
  static const Color accentGreen  = Color(0xFF1DE9B6);  // teal accent
  static const Color dimGreen     = Color(0xFF2E7D32);  // dim green

  static const Color incomeColor  = Color(0xFF00E676);  // income line
  static const Color expenseColor = Color(0xFFFF1744);  // expense line

  static const Color textPrimary   = Color(0xFFE8F5E9);
  static const Color textSecondary = Color(0xFF81C784);
  static const Color textHint      = Color(0xFF4CAF50);
  static const Color borderColor   = Color(0xFF1B5E20);

  // ── Theme ──────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary:    primaryGreen,
        secondary:  accentGreen,
        surface:    bgCard,
        onPrimary:  Colors.black,
        onSecondary: Colors.black,
        onSurface:  textPrimary,
        error:      expenseColor,
      ),
      textTheme: TextTheme(
        displayLarge:  _mono(32, FontWeight.w700, textPrimary),
        displayMedium: _mono(28, FontWeight.w700, textPrimary),
        displaySmall:  _mono(24, FontWeight.w600, textPrimary),
        headlineMedium: _mono(20, FontWeight.w600, textPrimary),
        headlineSmall:  _mono(18, FontWeight.w600, textPrimary),
        titleLarge:  _mono(16, FontWeight.w600, textPrimary),
        titleMedium: _sans(14, FontWeight.w500, textPrimary),
        titleSmall:  _sans(12, FontWeight.w500, textSecondary),
        bodyLarge:   _sans(16, FontWeight.w400, textPrimary),
        bodyMedium:  _sans(14, FontWeight.w400, textSecondary),
        bodySmall:   _sans(12, FontWeight.w400, textSecondary),
        labelLarge:  _mono(14, FontWeight.w600, Colors.black),
        labelMedium: _mono(12, FontWeight.w500, textSecondary),
        labelSmall:  _mono(10, FontWeight.w400, textHint),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgSecondary,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInput,
        hintStyle: _sans(14, FontWeight.w400, textHint),
        labelStyle: _sans(14, FontWeight.w400, textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: expenseColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: expenseColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: _mono(15, FontWeight.w700, Colors.black),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _mono(15, FontWeight.w600, primaryGreen),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCard,
        contentTextStyle: _sans(14, FontWeight.w500, textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
    );
  }

  static TextStyle _mono(double size, FontWeight weight, Color color) =>
      GoogleFonts.robotoMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle _sans(double size, FontWeight weight, Color color) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );
}
