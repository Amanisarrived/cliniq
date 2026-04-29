import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CliniqTheme {
  // ── Light Colors ──
  static const Color lightBg = Color(0xFFF5F3FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFEEEDFE);
  static const Color lightPrimary = Color(0xFF534AB7);
  static const Color lightAccent = Color(0xFF7C75D8);
  static const Color lightText = Color(0xFF1A1535);
  static const Color lightTextMuted = Color(0xFF8880C0);
  static const Color lightBorder = Color(0xFFE8E4F5);

  // ── Dark Colors ──
  static const Color darkBg = Color(0xFF141218);
  static const Color darkSurface = Color(0xFF1E1B2C);
  static const Color darkSurface2 = Color(0xFF2C2842);
  static const Color darkPrimary = Color(0xFF7C75D8);
  static const Color darkAccent = Color(0xFFC0BAF0);
  static const Color darkText = Color(0xFFF2F0FF);
  static const Color darkTextMuted = Color(0xFF5A5570);
  static const Color darkBorder = Color(0xFF2C2842);

  // ── Semantic Colors ──
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFFF4757);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF378ADD);

  // ── Light Theme ──
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        primaryColor: lightPrimary,
        colorScheme: const ColorScheme.light(
          primary: lightPrimary,
          secondary: lightAccent,
          surface: lightSurface,
          error: danger,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
              color: lightText,
              fontWeight: FontWeight.w800,
            ),
            displayMedium: TextStyle(
              color: lightText,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: TextStyle(color: lightText),
            bodyMedium: TextStyle(color: lightTextMuted),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightSurface,
          elevation: 0,
          centerTitle: false,
          foregroundColor: lightText,
          titleTextStyle: TextStyle(
            color: lightText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: lightBorder,
              width: 0.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: lightBorder,
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: lightBorder,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: lightPrimary,
              width: 1.5,
            ),
          ),
          hintStyle: const TextStyle(
            color: lightTextMuted,
            fontSize: 14,
          ),
        ),
        dividerColor: lightBorder,
        dividerTheme: const DividerThemeData(
          color: lightBorder,
          thickness: 0.5,
        ),
      );

  // ── Dark Theme ──
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        primaryColor: darkPrimary,
        colorScheme: const ColorScheme.dark(
          primary: darkPrimary,
          secondary: darkAccent,
          surface: darkSurface,
          error: danger,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w800,
            ),
            displayMedium: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: TextStyle(color: darkText),
            bodyMedium: TextStyle(color: darkTextMuted),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkSurface,
          elevation: 0,
          centerTitle: false,
          foregroundColor: darkText,
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: darkBorder,
              width: 0.5,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: darkBorder,
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: darkBorder,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: darkPrimary,
              width: 1.5,
            ),
          ),
          hintStyle: const TextStyle(
            color: darkTextMuted,
            fontSize: 14,
          ),
        ),
        dividerColor: darkBorder,
        dividerTheme: const DividerThemeData(
          color: darkBorder,
          thickness: 0.5,
        ),
      );
}
