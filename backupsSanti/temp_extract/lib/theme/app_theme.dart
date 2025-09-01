// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. Define Your Playful Color Palette ---
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6A1B9A); // Deep, playful purple
  static const Color primaryVariant = Color(0xFF4A148C); // Darker purple

  // Accent Colors for interactive elements
  static const Color accent = Color(0xFF00BFA5); // Vibrant Teal
  static const Color accentVariant = Color(0xFFF50057); // Electric Pink/Magenta

  // Neutrals for backgrounds and surfaces
  static const Color background = Color(0xFF121212); // Dark background for a premium feel
  static const Color surface = Color(0xFF1E1E1E); // Slightly lighter for cards
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Color(0xFFE0E0E0); // Light grey for text

  // State Colors
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFD50000);
}

// --- 2. Create the Typography Hierarchy ---
class AppTypography {
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.onBackground),
    displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.onBackground),
    headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onBackground),
    headlineSmall: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onBackground),
    titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.onBackground),
    
    bodyLarge: GoogleFonts.lato(fontSize: 16, color: AppColors.onSurface),
    bodyMedium: GoogleFonts.lato(fontSize: 14, color: AppColors.onSurface),
    
    labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onPrimary), // For buttons
    labelMedium: GoogleFonts.lato(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[400]),
  );
}

// --- 3. Build the Master ThemeData ---
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        background: AppColors.background,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onPrimary,
        onBackground: AppColors.onBackground,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme,
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        titleTextStyle: AppTypography.textTheme.headlineSmall,
        elevation: 0,
        centerTitle: true,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        )
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      ),

      // *** FIX: Use CardThemeData instead of CardTheme ***
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: AppColors.onSurface,
      ),
      
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.surface.withOpacity(0.5),
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accent.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary),
      )
    );
  }
}
