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
  static TextTheme getTextTheme(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    
    // Single debug print for theme generation
    print('DEBUG: Generating theme for locale: ${locale.languageCode}, isArabic: $isArabic');
    
    if (isArabic) {
      // Arabic Typography - Playpen Sans Arabic for headers/titles/buttons, Harmattan for body
      return TextTheme(
        // Headers and Titles - Arabic fonts (ORIGINAL font sizes and weights)
        displayLarge: const TextStyle(fontFamily: 'Beiruti', fontSize: 24, color: AppColors.onBackground),
        displayMedium: const TextStyle(fontFamily: 'Beiruti', fontSize: 20, color: AppColors.onBackground),
        headlineLarge: const TextStyle(fontFamily: 'Beiruti', fontSize: 26, color: AppColors.onBackground),
        headlineMedium: const TextStyle(fontFamily: 'Beiruti', fontSize: 24, color: AppColors.onBackground),
        headlineSmall: const TextStyle(fontFamily: 'Beiruti', fontSize: 20, color: AppColors.onBackground),
        titleLarge: const TextStyle(fontFamily: 'Beiruti', fontSize: 16, color: AppColors.onBackground),
        titleMedium: const TextStyle(fontFamily: 'Beiruti', fontSize: 16, color: AppColors.onBackground),
        titleSmall: const TextStyle(fontFamily: 'Beiruti', fontSize: 14, color: AppColors.onBackground),
        
        // Body Text - Harmattan (ORIGINAL)
        bodyLarge: GoogleFonts.harmattan(fontSize: 16, color: AppColors.onSurface),
        bodyMedium: GoogleFonts.harmattan(fontSize: 14, color: AppColors.onSurface),
        bodySmall: GoogleFonts.harmattan(fontSize: 12, color: AppColors.onSurface),
        
        // Labels and Buttons - Beiruti (ORIGINAL font sizes and weights)
        labelLarge: const TextStyle(fontFamily: 'Beiruti', fontSize: 16, color: AppColors.onPrimary), // For buttons
        labelMedium: GoogleFonts.harmattan(fontSize: 14, color: Colors.grey[400]),
        labelSmall: GoogleFonts.harmattan(fontSize: 12, color: Colors.grey[400]),
      );
    } else {
      // English Typography - Luckiest Guy for headers/titles/buttons, Chewy for body
      return TextTheme(
        // Headers and Titles - Luckiest Guy (ORIGINAL font sizes and weights)
        displayLarge: GoogleFonts.luckiestGuy(fontSize: 24, color: AppColors.onBackground),
        displayMedium: GoogleFonts.luckiestGuy(fontSize: 20, color: AppColors.onBackground),
        headlineLarge: GoogleFonts.luckiestGuy(fontSize: 26, color: AppColors.onBackground),
        headlineMedium: GoogleFonts.luckiestGuy(fontSize: 24, color: AppColors.onBackground),
        headlineSmall: GoogleFonts.luckiestGuy(fontSize: 20, color: AppColors.onBackground),
        titleLarge: GoogleFonts.luckiestGuy(fontSize: 16, color: AppColors.onBackground),
        titleMedium: GoogleFonts.luckiestGuy(fontSize: 16, color: AppColors.onBackground),
        titleSmall: GoogleFonts.luckiestGuy(fontSize: 14, color: AppColors.onBackground),
        
        // Body Text - Chewy (ORIGINAL)
        bodyLarge: GoogleFonts.chewy(fontSize: 16, color: AppColors.onSurface),
        bodyMedium: GoogleFonts.chewy(fontSize: 14, color: AppColors.onSurface),
        bodySmall: GoogleFonts.chewy(fontSize: 12, color: AppColors.onSurface),
        
        // Labels and Buttons - Luckiest Guy (ORIGINAL font sizes and weights)
        labelLarge: GoogleFonts.luckiestGuy(fontSize: 16, color: AppColors.onPrimary), // For buttons
        labelMedium: GoogleFonts.chewy(fontSize: 14, color: Colors.grey[400]),
        labelSmall: GoogleFonts.chewy(fontSize: 12, color: Colors.grey[400]),
      );
    }
  }

  // Legacy static getter for backward compatibility
  static TextTheme get textTheme => TextTheme(
    // Headers and Titles - Luckiest Guy (default English) - ORIGINAL font sizes and weights
    displayLarge: GoogleFonts.luckiestGuy(fontSize: 24, color: AppColors.onBackground),
    displayMedium: GoogleFonts.luckiestGuy(fontSize: 20, color: AppColors.onBackground),
    headlineLarge: GoogleFonts.luckiestGuy(fontSize: 26, color: AppColors.onBackground),
    headlineMedium: GoogleFonts.luckiestGuy(fontSize: 24, color: AppColors.onBackground),
    headlineSmall: GoogleFonts.luckiestGuy(fontSize: 20, color: AppColors.onBackground),
    titleLarge: GoogleFonts.luckiestGuy(fontSize: 16, color: AppColors.onBackground),
    titleMedium: GoogleFonts.luckiestGuy(fontSize: 16, color: AppColors.onBackground),
    titleSmall: GoogleFonts.luckiestGuy(fontSize: 14, color: AppColors.onBackground),
    
    // Body Text - Chewy (ORIGINAL)
    bodyLarge: GoogleFonts.chewy(fontSize: 16, color: AppColors.onSurface),
    bodyMedium: GoogleFonts.chewy(fontSize: 14, color: AppColors.onSurface),
    bodySmall: GoogleFonts.chewy(fontSize: 12, color: AppColors.onSurface),
    
    // Labels and Buttons - Luckiest Guy (DOUBLED font sizes and weights)
    labelLarge: GoogleFonts.luckiestGuy(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.onPrimary), // For buttons
    labelMedium: GoogleFonts.chewy(fontSize: 14, color: Colors.grey[400]),
    labelSmall: GoogleFonts.chewy(fontSize: 12, color: Colors.grey[400]),
  );
  
  // Helper method to create TextStyle with correct font family
  static TextStyle createTextStyle(BuildContext context, {
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    bool isHeader = false,
  }) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final fontFamily = isHeader 
        ? (isArabic ? 'Beiruti' : 'Luckiest Guy')
        : (isArabic ? 'Harmattan' : 'Chewy');
    
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}

// --- 3. Build the Master ThemeData ---
class AppTheme {
  static ThemeData getDarkTheme(BuildContext context) {
    final textTheme = AppTypography.getTextTheme(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onPrimary,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      
      // Override default text styles to ensure font family inheritance
      primaryTextTheme: textTheme,
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        titleTextStyle: textTheme.headlineSmall,
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
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: textTheme.labelLarge,
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
        labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      ),

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
        inactiveTrackColor: AppColors.surface.withValues(alpha: 0.5),
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accent.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary),
      )
    );
  }

  // Legacy static getter for backward compatibility
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onPrimary,
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
        textStyle: AppTypography.textTheme.labelLarge,
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
      inactiveTrackColor: AppColors.surface.withValues(alpha: 0.5),
      thumbColor: AppColors.accent,
      overlayColor: AppColors.accent.withValues(alpha: 0.2),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary),
    )
  );
}
