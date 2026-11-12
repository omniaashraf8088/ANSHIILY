import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepNavy,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.champagneGold,
        onPrimary: AppColors.deepNavy,
        secondary: AppColors.burgundy,
        onSecondary: AppColors.warmIvory,
        surface: AppColors.deepNavyMid,
        onSurface: AppColors.warmIvory,
        error: Color(0xFFCF6679),
        onError: Colors.white,
        primaryContainer: AppColors.deepNavyLight,
        onPrimaryContainer: AppColors.champagneGold,
        secondaryContainer: AppColors.burgundy,
        onSecondaryContainer: AppColors.warmIvory,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: AppColors.champagneGold,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
        iconTheme: const IconThemeData(color: AppColors.champagneGold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.champagneGold,
          foregroundColor: AppColors.deepNavy,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.champagneGold,
          side: const BorderSide(color: AppColors.champagneGold, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.deepNavyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.transparentGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.transparentGold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.champagneGold,
            width: 1.5,
          ),
        ),
        labelStyle: const TextStyle(color: AppColors.champagneGold),
        hintStyle: TextStyle(color: AppColors.warmIvory.withValues(alpha: 0.5)),
      ),
      iconTheme: const IconThemeData(color: AppColors.champagneGold),
      dividerTheme: const DividerThemeData(
        color: AppColors.transparentGold,
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        color: AppColors.champagneGold,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        color: AppColors.champagneGold,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
      displaySmall: GoogleFonts.cormorantGaramond(
        color: AppColors.champagneGold,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
      headlineLarge: GoogleFonts.tajawal(
        color: AppColors.champagneGold,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.tajawal(
        color: AppColors.champagneGold,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.tajawal(
        color: AppColors.champagneGold,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.tajawal(
        color: AppColors.warmIvory,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.tajawal(
        color: AppColors.warmIvory,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.tajawal(
        color: AppColors.warmIvory,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.tajawal(
        color: AppColors.warmIvory,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.tajawal(
        color: AppColors.warmIvory,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.tajawal(
        color: AppColors.warmIvory,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.tajawal(
        color: AppColors.deepNavy,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}
