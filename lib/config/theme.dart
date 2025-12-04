import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🌿 Brand Colors
  static const Color primary = Color(0xFF2ECC71);
  static const Color secondary = Color(0xFF1A1A1A);
  static const Color accent = Color(0xFFFFB74D);

  // 🖊️ Text Theme Helper
  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: color),
      displayMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: color),
      displaySmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      bodyLarge: GoogleFonts.dmSans(fontSize: 16, height: 1.5, color: color),
      bodyMedium: GoogleFonts.dmSans(fontSize: 14, height: 1.4, color: color.withOpacity(0.7)),
      labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: color),
    );
  }

  // ☀️ LIGHT THEME
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFFF2F4F7),
      cardColor: Colors.white,
      textTheme: _buildTextTheme(secondary),
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
      iconTheme: const IconThemeData(color: secondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: secondary),
      ),
    );
  }

  // 🌙 DARK THEME (FIXED)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFF121212), // True Black
      cardColor: const Color(0xFF1E1E1E), // Dark Grey Surface
      textTheme: _buildTextTheme(Colors.white), // Force White Text
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      dialogBackgroundColor: const Color(0xFF1E1E1E),
    );
  }
}