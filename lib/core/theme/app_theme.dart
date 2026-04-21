import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0F),
      primaryColor: Colors.cyan,
      colorScheme: const ColorScheme.dark(
        primary: Colors.cyan,
        surface: Color(0xFF0A0A0F),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        // Terminal font config (can be used later)
        bodySmall: GoogleFonts.jetBrainsMono(
          color: Colors.white70,
        ),
      ),
      useMaterial3: true,
    );
  }
}
