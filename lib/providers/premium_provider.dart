// lib/providers/premium_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/premium_subscription.dart';

class PremiumProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  PremiumPurchase? _purchase;
  bool _isLoading = false;
  String? _error;

  // Getters
  PremiumPurchase? get purchase => _purchase;
  bool get isPremium => false; // Temporarily disabled - will be enabled later
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Feature checks - all disabled for now
  bool get hasAvatarCustomization => false; // Temporarily disabled
  bool get hasGroupChat => false; // Temporarily disabled
  bool get hasVoiceChat => false; // Temporarily disabled
  bool get hasOnlineMatchmaking => false; // Temporarily disabled
  bool get hasBundleSuggestions => false; // Temporarily disabled
  bool get hasCustomUsername => false; // Temporarily disabled


  // Initialize premium status
  Future<void> initialize() async {
    if (_auth.currentUser == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadPurchase();
    } catch (e) {
      _error = 'Failed to load premium status: $e';
      if (kDebugMode) {
        print('PremiumProvider error: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load purchase from Firestore
  Future<void> _loadPurchase() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final doc = await _firestore
        .collection('premium_purchases')
        .doc(userId)
        .get();

    if (doc.exists) {
      _purchase = PremiumPurchase.fromFirestore(doc);
    } else {
      // Create default non-premium purchase
      _purchase = PremiumPurchase(
        userId: userId,
        isActive: false,
        platform: 'google_play',
        features: [],
      );
      await _savePurchase();
    }
  }

  // Save purchase to Firestore
  Future<void> _savePurchase() async {
    if (_purchase == null) return;

    await _firestore
        .collection('premium_purchases')
        .doc(_purchase!.userId)
        .set(_purchase!.toFirestore());
  }

  // Activate premium purchase
  Future<void> activatePremium({
    required String purchaseToken,
    required String platform,
  }) async {
    if (_purchase == null) return;

    _purchase = _purchase!.copyWith(
      isActive: true,
      purchaseDate: DateTime.now(),
      purchaseToken: purchaseToken,
      platform: platform,
      features: PremiumPurchase.premiumFeatures,
    );

    await _savePurchase();
    notifyListeners();
  }

  // Refresh purchase status (call this periodically)
  Future<void> refreshStatus() async {
    await _loadPurchase();
    notifyListeners();
  }

  // Check if purchase needs refresh (always false for one-time purchase)
  bool get needsRefresh => false;

  // Get purchase status text
  String get statusText {
    if (_purchase == null) return 'Loading...';
    if (!_purchase!.isActive) return 'Free';
    return 'Premium Active';
  }

  // Get premium features list
  List<String> get activeFeatures {
    if (!isPremium) return [];
    return _purchase!.features;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
