// lib/models/spectrum_skin.dart

import 'package:flutter/material.dart';

/// Performance-optimized spectrum skin using solid colors
class SpectrumSkin {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;      // Main spectrum color
  final Color needleColor;       // Needle/pointer color  
  final Color backgroundColor;   // Background color
  final Color trackColor;        // Track/rail color
  final int gemPrice;
  final String rarity;
  final String iconPath;

  const SpectrumSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.needleColor,
    required this.backgroundColor,
    required this.trackColor,
    required this.gemPrice,
    required this.rarity,
    required this.iconPath,
  });

  /// Create from cosmetic item data
  factory SpectrumSkin.fromCosmeticItem({
    required String id,
    required String name,
    required String description,
    required Color primaryColor,
    required Color needleColor,
    required Color backgroundColor,
    required Color trackColor,
    required int gemPrice,
    required String rarity,
    required String iconPath,
  }) {
    return SpectrumSkin(
      id: id,
      name: name,
      description: description,
      primaryColor: primaryColor,
      needleColor: needleColor,
      backgroundColor: backgroundColor,
      trackColor: trackColor,
      gemPrice: gemPrice,
      rarity: rarity,
      iconPath: iconPath,
    );
  }
}

/// Catalog of all available spectrum skins
class SpectrumSkinCatalog {
  /// Default free skin (always available)
  static const SpectrumSkin defaultSkin = SpectrumSkin(
    id: 'default',
    name: 'Classic',
    description: 'The original MindDrift spectrum design',
    primaryColor: Color(0xFF4A00E0),     // Purple
    needleColor: Colors.white,
    backgroundColor: Color(0xFF1A1A2E),  // Dark blue
    trackColor: Color(0xFF16213E),       // Darker blue
    gemPrice: 0,
    rarity: 'free',
    iconPath: 'assets/skins/classic_preview.png',
  );

  /// Premium skins available for purchase
  static const List<SpectrumSkin> premiumSkins = [
    // Neon Green Theme - 750 Gems
    SpectrumSkin(
      id: 'skin_neon_green',
      name: 'Neon Matrix',
      description: 'Electric green theme inspired by digital worlds',
      primaryColor: Color(0xFF00FF41),     // Bright green
      needleColor: Color(0xFF00FF41),      // Bright green
      backgroundColor: Color(0xFF0D1B0D),  // Dark green
      trackColor: Color(0xFF1A2E1A),       // Medium green
      gemPrice: 750,
      rarity: 'common',
      iconPath: 'assets/skins/neon_green_preview.png',
    ),

    // Ocean Blue Theme - 750 Gems  
    SpectrumSkin(
      id: 'skin_ocean_blue',
      name: 'Deep Ocean',
      description: 'Calming blue theme like the depths of the sea',
      primaryColor: Color(0xFF0077BE),     // Ocean blue
      needleColor: Color(0xFF00BFFF),      // Light blue
      backgroundColor: Color(0xFF001122),  // Deep blue
      trackColor: Color(0xFF003366),       // Medium blue
      gemPrice: 750,
      rarity: 'common',
      iconPath: 'assets/skins/ocean_blue_preview.png',
    ),

    // Sunset Orange Theme - 750 Gems
    SpectrumSkin(
      id: 'skin_sunset_orange',
      name: 'Sunset Glow',
      description: 'Warm orange theme like a beautiful sunset',
      primaryColor: Color(0xFFFF6B35),     // Orange
      needleColor: Color(0xFFFFD700),      // Gold
      backgroundColor: Color(0xFF2D1B1B),  // Dark red
      trackColor: Color(0xFF4A2C2A),       // Brown
      gemPrice: 750,
      rarity: 'common',
      iconPath: 'assets/skins/sunset_orange_preview.png',
    ),

    // Royal Purple Theme - 1500 Gems
    SpectrumSkin(
      id: 'skin_royal_purple',
      name: 'Royal Majesty',
      description: 'Elegant purple theme fit for royalty',
      primaryColor: Color(0xFF8A2BE2),     // Blue violet
      needleColor: Color(0xFFDAA520),      // Goldenrod
      backgroundColor: Color(0xFF1A0D1A),  // Dark purple
      trackColor: Color(0xFF2D1A2D),       // Medium purple
      gemPrice: 1500,
      rarity: 'rare',
      iconPath: 'assets/skins/royal_purple_preview.png',
    ),

    // Crimson Red Theme - 1500 Gems
    SpectrumSkin(
      id: 'skin_crimson_red',
      name: 'Crimson Fire',
      description: 'Intense red theme with fiery energy',
      primaryColor: Color(0xFFDC143C),     // Crimson
      needleColor: Color(0xFFFFD700),      // Gold
      backgroundColor: Color(0xFF2D0A0A),  // Dark red
      trackColor: Color(0xFF4A1A1A),       // Medium red
      gemPrice: 1500,
      rarity: 'rare',
      iconPath: 'assets/skins/crimson_red_preview.png',
    ),

    // Golden Luxury Theme - 2500 Gems
    SpectrumSkin(
      id: 'skin_golden_luxury',
      name: 'Golden Luxury',
      description: 'Premium gold theme for distinguished players',
      primaryColor: Color(0xFFFFD700),     // Gold
      needleColor: Color(0xFFFFFAF0),      // Ivory
      backgroundColor: Color(0xFF2D2D0A),  // Dark yellow
      trackColor: Color(0xFF4A4A1A),       // Olive
      gemPrice: 2500,
      rarity: 'epic',
      iconPath: 'assets/skins/golden_luxury_preview.png',
    ),
  ];

  /// Get all available skins (free + premium)
  static List<SpectrumSkin> getAllSkins() {
    return [defaultSkin, ...premiumSkins];
  }

  /// Get skin by ID
  static SpectrumSkin getSkinById(String skinId) {
    try {
      return getAllSkins().firstWhere((skin) => skin.id == skinId);
    } catch (e) {
      return defaultSkin; // Fallback to default
    }
  }

  /// Get skins by rarity
  static List<SpectrumSkin> getSkinsByRarity(String rarity) {
    return getAllSkins().where((skin) => skin.rarity == rarity).toList();
  }

  /// Get rarity color for UI
  static Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'free':
        return Colors.grey;
      case 'common':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
