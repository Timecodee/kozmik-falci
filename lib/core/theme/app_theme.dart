import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Mistik Renk Paleti
  static const Color spaceDark = Color(0xFF070B19);       // Derin Uzay Siyahı/Mavisi
  static const Color deepNavy = Color(0xFF0F162E);        // Koyu Gece Mavisi
  static const Color midnightBlue = Color(0xFF1D264F);    // Gece Mavisi (Kartlar vb. için)
  static const Color goldLight = Color(0xFFF3E5AB);       // Soft Altın Sarısı
  static const Color gold = Color(0xFFD4AF37);            // Mistik Altın Sarısı
  static const Color goldDark = Color(0xFFAA7C11);         // Koyu Altın/Bronz
  static const Color cosmicPurple = Color(0xFF3F2B96);    // Kozmik Mor (Detaylar için)

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: spaceDark,
      primaryColor: gold,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldLight,
        tertiary: cosmicPurple,
        surface: deepNavy,
        background: spaceDark,
        onPrimary: spaceDark,
        onSecondary: spaceDark,
        onSurface: Colors.white,
      ),
      cardTheme: const CardTheme(
        color: deepNavy,
        shadowColor: gold,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: midnightBlue, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: gold,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: gold),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: gold,
          letterSpacing: 2.0,
        ),
        titleLarge: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: goldLight,
        ),
        bodyLarge: GoogleFonts.lora(
          fontSize: 16,
          color: Colors.white75,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.lora(
          fontSize: 14,
          color: Colors.white60,
          height: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: gold,
          shadowColor: gold.withOpacity(0.5),
          elevation: 5,
          side: const BorderSide(color: gold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
