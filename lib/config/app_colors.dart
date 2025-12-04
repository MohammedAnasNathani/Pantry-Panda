import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryDark = Color(0xFF27AE60);
  static const Color accent = Color(0xFFFFB74D);
  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
