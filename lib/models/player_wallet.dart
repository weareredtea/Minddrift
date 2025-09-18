// lib/models/player_wallet.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a player's wallet containing Mind Gems and owned cosmetic items
class PlayerWallet {
  final String userId;
  final int mindGems;
  final List<String> ownedSliderSkins;
  final List<String> ownedBadges;
  final List<String> ownedAvatarPacks;
  final int usernameChangesUsed;
  final DateTime lastDailyBonus;
  final int totalGemsEarned; // Lifetime Gems earned for statistics
  final int totalGemsSpent;   // Lifetime Gems spent for statistics

  const PlayerWallet({
    required this.userId,
    this.mindGems = 0,
    this.ownedSliderSkins = const [],
    this.ownedBadges = const [],
    this.ownedAvatarPacks = const [],
    this.usernameChangesUsed = 0,
    required this.lastDailyBonus,
    this.totalGemsEarned = 0,
    this.totalGemsSpent = 0,
  });

  /// Create from Firestore document
  factory PlayerWallet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlayerWallet(
      userId: doc.id,
      mindGems: data['mindGems'] ?? 0,
      ownedSliderSkins: List<String>.from(data['ownedSliderSkins'] ?? []),
      ownedBadges: List<String>.from(data['ownedBadges'] ?? []),
      ownedAvatarPacks: List<String>.from(data['ownedAvatarPacks'] ?? []),
      usernameChangesUsed: data['usernameChangesUsed'] ?? 0,
      lastDailyBonus: data['lastDailyBonus']?.toDate() ?? DateTime(2000),
      totalGemsEarned: data['totalGemsEarned'] ?? 0,
      totalGemsSpent: data['totalGemsSpent'] ?? 0,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'mindGems': mindGems,
      'ownedSliderSkins': ownedSliderSkins,
      'ownedBadges': ownedBadges,
      'ownedAvatarPacks': ownedAvatarPacks,
      'usernameChangesUsed': usernameChangesUsed,
      'lastDailyBonus': Timestamp.fromDate(lastDailyBonus),
      'totalGemsEarned': totalGemsEarned,
      'totalGemsSpent': totalGemsSpent,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  PlayerWallet copyWith({
    String? userId,
    int? mindGems,
    List<String>? ownedSliderSkins,
    List<String>? ownedBadges,
    List<String>? ownedAvatarPacks,
    int? usernameChangesUsed,
    DateTime? lastDailyBonus,
    int? totalGemsEarned,
    int? totalGemsSpent,
  }) {
    return PlayerWallet(
      userId: userId ?? this.userId,
      mindGems: mindGems ?? this.mindGems,
      ownedSliderSkins: ownedSliderSkins ?? this.ownedSliderSkins,
      ownedBadges: ownedBadges ?? this.ownedBadges,
      ownedAvatarPacks: ownedAvatarPacks ?? this.ownedAvatarPacks,
      usernameChangesUsed: usernameChangesUsed ?? this.usernameChangesUsed,
      lastDailyBonus: lastDailyBonus ?? this.lastDailyBonus,
      totalGemsEarned: totalGemsEarned ?? this.totalGemsEarned,
      totalGemsSpent: totalGemsSpent ?? this.totalGemsSpent,
    );
  }

  /// Check if player owns a specific cosmetic item
  bool ownsSliderSkin(String skinId) => ownedSliderSkins.contains(skinId);
  bool ownsBadge(String badgeId) => ownedBadges.contains(badgeId);
  bool ownsAvatarPack(String packId) => ownedAvatarPacks.contains(packId);
  
  /// Check if player can afford an item
  bool canAfford(int gemCost) => mindGems >= gemCost;
  
  /// Check if player has free username change available
  bool get hasFreeUsernameChange => usernameChangesUsed == 0;
  
  /// Get username change cost (0 for first change, 1000 for subsequent)
  int get usernameChangeCost => hasFreeUsernameChange ? 0 : 1000;
}

/// Represents a cosmetic item available for purchase
class CosmeticItem {
  final String id;
  final String name;
  final String description;
  final CosmeticType type;
  final int gemPrice;
  final String iconPath;
  final bool isAnimated;
  final String rarity; // 'common', 'rare', 'epic', 'legendary'

  const CosmeticItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.gemPrice,
    required this.iconPath,
    this.isAnimated = false,
    this.rarity = 'common',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.toString(),
    'gemPrice': gemPrice,
    'iconPath': iconPath,
    'isAnimated': isAnimated,
    'rarity': rarity,
  };
}

/// Types of cosmetic items available for purchase
enum CosmeticType {
  sliderSkin,
  badge,
  avatarPack,
}

/// Represents an avatar pack containing multiple avatars
class AvatarPack {
  final String packId;
  final String name;
  final String description;
  final List<String> avatarIds; // List of 6 avatar IDs in the pack
  final int gemPrice;
  final String themeColor; // Hex color for UI theming
  final String previewIcon; // Icon to show in store

  const AvatarPack({
    required this.packId,
    required this.name,
    required this.description,
    required this.avatarIds,
    required this.gemPrice,
    required this.themeColor,
    required this.previewIcon,
  });

  Map<String, dynamic> toMap() => {
    'packId': packId,
    'name': name,
    'description': description,
    'avatarIds': avatarIds,
    'gemPrice': gemPrice,
    'themeColor': themeColor,
    'previewIcon': previewIcon,
  };
}

/// Represents a transaction in the player's Gem history
class GemTransaction {
  final String transactionId;
  final String userId;
  final int amount; // Positive for earning, negative for spending
  final String reason; // 'daily_bonus', 'campaign_star', 'badge_purchase', etc.
  final DateTime timestamp;
  final Map<String, dynamic> metadata; // Additional context (level completed, item purchased, etc.)

  const GemTransaction({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.timestamp,
    this.metadata = const {},
  });

  factory GemTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GemTransaction(
      transactionId: doc.id,
      userId: data['userId'] ?? '',
      amount: data['amount'] ?? 0,
      reason: data['reason'] ?? '',
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  /// Check if this is an earning transaction
  bool get isEarning => amount > 0;
  
  /// Check if this is a spending transaction
  bool get isSpending => amount < 0;
}
