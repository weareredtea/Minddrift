// lib/models/premium_purchase.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumPurchase {
  final String userId;
  final bool isActive;
  final DateTime? purchaseDate;
  final String? purchaseToken;
  final String platform; // 'google_play' or 'app_store'
  final List<String> features;

  const PremiumPurchase({
    required this.userId,
    required this.isActive,
    this.purchaseDate,
    this.purchaseToken,
    required this.platform,
    required this.features,
  });

  // Premium features list
  static const List<String> premiumFeatures = [
    'avatar_customization',
    'group_chat',
    'voice_chat',
    'online_matchmaking',
    'bundle_suggestions',
    'custom_username',
  ];

  // Check if user has a specific premium feature
  bool hasFeature(String feature) {
    return isActive && features.contains(feature);
  }

  // Check if purchase is active (one-time purchase never expires)
  bool get isExpired => false; // One-time purchases don't expire

  // Get remaining days (always -1 for one-time purchase)
  int get remainingDays => -1; // One-time purchases don't have remaining days

  // Create from Firestore document
  factory PremiumPurchase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PremiumPurchase(
      userId: data['userId'] ?? '',
      isActive: data['isActive'] ?? false,
      purchaseDate: data['purchaseDate']?.toDate(),
      purchaseToken: data['purchaseToken'],
      platform: data['platform'] ?? 'google_play',
      features: List<String>.from(data['features'] ?? []),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'isActive': isActive,
      'purchaseDate': purchaseDate,
      'purchaseToken': purchaseToken,
      'platform': platform,
      'features': features,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  PremiumPurchase copyWith({
    String? userId,
    bool? isActive,
    DateTime? purchaseDate,
    String? purchaseToken,
    String? platform,
    List<String>? features,
  }) {
    return PremiumPurchase(
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      platform: platform ?? this.platform,
      features: features ?? this.features,
    );
  }
}
