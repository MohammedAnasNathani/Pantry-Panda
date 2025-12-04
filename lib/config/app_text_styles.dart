import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold);
  static TextStyle get h2 => GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600);
  static TextStyle get h3 => GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get bodyLarge => GoogleFonts.openSans(fontSize: 16, height: 1.5);
  static TextStyle get button => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
}
