// lib/data/cosmetic_catalog.dart

import '../models/player_wallet.dart';

/// Catalog of all cosmetic items available for purchase with Mind Gems
class CosmeticCatalog {
  
  /// All available slider skins
  static const List<CosmeticItem> sliderSkins = [
    // Basic Slider Skins (500 Gems)
    CosmeticItem(
      id: 'skin_rainbow',
      name: 'Rainbow Spectrum',
      description: 'A colorful rainbow gradient for your spectrum slider',
      type: CosmeticType.sliderSkin,
      gemPrice: 500,
      iconPath: 'assets/skins/rainbow_preview.png',
      rarity: 'common',
    ),
    CosmeticItem(
      id: 'skin_neon',
      name: 'Neon Glow',
      description: 'Electric neon colors with a glowing effect',
      type: CosmeticType.sliderSkin,
      gemPrice: 500,
      iconPath: 'assets/skins/neon_preview.png',
      rarity: 'common',
    ),
    CosmeticItem(
      id: 'skin_sunset',
      name: 'Sunset Vibes',
      description: 'Warm sunset colors for a relaxing experience',
      type: CosmeticType.sliderSkin,
      gemPrice: 500,
      iconPath: 'assets/skins/sunset_preview.png',
      rarity: 'common',
    ),
    
    // Premium Slider Skins (2,500 Gems)
    CosmeticItem(
      id: 'skin_galaxy',
      name: 'Galaxy Explorer',
      description: 'Deep space colors with twinkling star effects',
      type: CosmeticType.sliderSkin,
      gemPrice: 2500,
      iconPath: 'assets/skins/galaxy_preview.png',
      rarity: 'epic',
    ),
    CosmeticItem(
      id: 'skin_fire',
      name: 'Flame Master',
      description: 'Fiery animated spectrum with flame particles',
      type: CosmeticType.sliderSkin,
      gemPrice: 2500,
      iconPath: 'assets/skins/fire_preview.png',
      isAnimated: true,
      rarity: 'epic',
    ),
    CosmeticItem(
      id: 'skin_ice',
      name: 'Frozen Crystal',
      description: 'Icy blue spectrum with crystalline effects',
      type: CosmeticType.sliderSkin,
      gemPrice: 2500,
      iconPath: 'assets/skins/ice_preview.png',
      isAnimated: true,
      rarity: 'epic',
    ),
  ];

  /// All available profile badges
  static const List<CosmeticItem> badges = [
    // Static Badges (1,500 Gems)
    CosmeticItem(
      id: 'badge_brain_gold',
      name: 'Golden Brain',
      description: 'A prestigious golden brain badge for smart players',
      type: CosmeticType.badge,
      gemPrice: 1500,
      iconPath: 'assets/badges/brain_gold.png',
      rarity: 'rare',
    ),
    CosmeticItem(
      id: 'badge_mastermind',
      name: 'Mastermind Medal',
      description: 'A medal for players who excel at mind games',
      type: CosmeticType.badge,
      gemPrice: 1500,
      iconPath: 'assets/badges/mastermind.png',
      rarity: 'rare',
    ),
    CosmeticItem(
      id: 'badge_lightning',
      name: 'Lightning Fast',
      description: 'For players who think at the speed of light',
      type: CosmeticType.badge,
      gemPrice: 1500,
      iconPath: 'assets/badges/lightning.png',
      rarity: 'rare',
    ),
    
    // Animated Badges (3,000 Gems)
    CosmeticItem(
      id: 'badge_gem_sparkle',
      name: 'Sparkling Gem',
      description: 'A dazzling animated gem that sparkles with your intelligence',
      type: CosmeticType.badge,
      gemPrice: 3000,
      iconPath: 'assets/badges/gem_sparkle.gif',
      isAnimated: true,
      rarity: 'legendary',
    ),
    CosmeticItem(
      id: 'badge_brain_pulse',
      name: 'Pulsing Brain',
      description: 'An animated brain badge that pulses with mental energy',
      type: CosmeticType.badge,
      gemPrice: 3000,
      iconPath: 'assets/badges/brain_pulse.gif',
      isAnimated: true,
      rarity: 'legendary',
    ),
    CosmeticItem(
      id: 'badge_crown_royal',
      name: 'Royal Crown',
      description: 'An animated golden crown for true champions',
      type: CosmeticType.badge,
      gemPrice: 3000,
      iconPath: 'assets/badges/crown_royal.gif',
      isAnimated: true,
      rarity: 'legendary',
    ),
  ];

  /// All available avatar packs
  static const List<AvatarPack> avatarPacks = [
    AvatarPack(
      packId: 'pack_robots',
      name: 'Robot Collection',
      description: 'Futuristic robot avatars with metallic designs',
      avatarIds: ['robot_01', 'robot_02', 'robot_03', 'robot_04', 'robot_05', 'robot_06'],
      gemPrice: 2500,
      themeColor: '#00BCD4', // Cyan
      previewIcon: 'assets/avatar_packs/robots_preview.png',
    ),
    AvatarPack(
      packId: 'pack_monsters',
      name: 'Monster Squad',
      description: 'Friendly monster avatars with vibrant colors',
      avatarIds: ['monster_01', 'monster_02', 'monster_03', 'monster_04', 'monster_05', 'monster_06'],
      gemPrice: 2500,
      themeColor: '#9C27B0', // Purple
      previewIcon: 'assets/avatar_packs/monsters_preview.png',
    ),
    AvatarPack(
      packId: 'pack_space',
      name: 'Space Explorers',
      description: 'Cosmic avatars for intergalactic mind games',
      avatarIds: ['space_01', 'space_02', 'space_03', 'space_04', 'space_05', 'space_06'],
      gemPrice: 2500,
      themeColor: '#3F51B5', // Indigo
      previewIcon: 'assets/avatar_packs/space_preview.png',
    ),
    AvatarPack(
      packId: 'pack_fantasy',
      name: 'Fantasy Realm',
      description: 'Magical creatures and fantasy characters',
      avatarIds: ['fantasy_01', 'fantasy_02', 'fantasy_03', 'fantasy_04', 'fantasy_05', 'fantasy_06'],
      gemPrice: 2500,
      themeColor: '#E91E63', // Pink
      previewIcon: 'assets/avatar_packs/fantasy_preview.png',
    ),
  ];

  /// Get all cosmetic items by type
  static List<CosmeticItem> getItemsByType(CosmeticType type) {
    switch (type) {
      case CosmeticType.sliderSkin:
        return sliderSkins;
      case CosmeticType.badge:
        return badges;
      case CosmeticType.avatarPack:
        return avatarPacks.map((pack) => CosmeticItem(
          id: pack.packId,
          name: pack.name,
          description: pack.description,
          type: CosmeticType.avatarPack,
          gemPrice: pack.gemPrice,
          iconPath: pack.previewIcon,
          rarity: 'rare',
        )).toList();
    }
  }

  /// Get all cosmetic items
  static List<CosmeticItem> getAllItems() {
    return [
      ...sliderSkins,
      ...badges,
      ...getItemsByType(CosmeticType.avatarPack),
    ];
  }

  /// Get item by ID
  static CosmeticItem? getItemById(String itemId) {
    try {
      return getAllItems().firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Get avatar pack by ID
  static AvatarPack? getAvatarPackById(String packId) {
    try {
      return avatarPacks.firstWhere((pack) => pack.packId == packId);
    } catch (e) {
      return null;
    }
  }

  /// Get rarity color for UI
  static String getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return '#4CAF50'; // Green
      case 'rare':
        return '#2196F3'; // Blue
      case 'epic':
        return '#9C27B0'; // Purple
      case 'legendary':
        return '#FF9800'; // Orange
      default:
        return '#757575'; // Grey
    }
  }

  /// Get rarity display name
  static String getRarityDisplayName(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return 'Common';
      case 'rare':
        return 'Rare';
      case 'epic':
        return 'Epic';
      case 'legendary':
        return 'Legendary';
      default:
        return 'Unknown';
    }
  }
}
