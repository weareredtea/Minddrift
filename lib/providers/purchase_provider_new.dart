// lib/providers/purchase_provider_new.dart
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/purchase_service.dart';

/// New simplified PurchaseProvider that delegates to PurchaseService
class PurchaseProviderNew extends ChangeNotifier {
  final PurchaseService _purchaseService = PurchaseService();
  
  // State
  bool _isInitialized = false;
  String? _error;

  // Getters
  List<ProductDetails> get products => _purchaseService.products;
  Set<String> get ownedBundles => _purchaseService.ownedBundles;
  Set<String> get availableBundles => _purchaseService.getAvailableBundles();
  bool get isInitialized => _isInitialized;
  String? get error => _error ?? _purchaseService.error;
  bool get isBillingAvailable => _purchaseService.isInitialized && _purchaseService.products.isNotEmpty;
  bool get hasAllAccess => _purchaseService.hasAllAccess;
  
  /// Check if a bundle is owned (including all access logic)
  bool isOwned(String bundleId) {
    if (bundleId == 'all_access') {
      return _purchaseService.isOwned(bundleId);
    }
    // If user has all access, they own all bundles
    if (hasAllAccess) {
      return true;
    }
    return _purchaseService.isOwned(bundleId);
  }

  PurchaseProviderNew() {
    _initialize();
  }

  /// Initialize the provider
  Future<void> _initialize() async {
    try {
      // Initialize the purchase service
      await _purchaseService.initialize();
      
      // Listen to owned bundles changes
      _purchaseService.ownedBundlesStream.listen((bundles) {
        notifyListeners();
      });
      
      // Listen to error changes
      _purchaseService.errorStream.listen((error) {
        _error = error;
        notifyListeners();
      });
      
      _isInitialized = true;
      notifyListeners();
      
    } catch (e) {
      _error = 'Failed to initialize: $e';
      notifyListeners();
    }
  }

  /// Buy a product
  Future<void> buy(String productId) async {
    try {
      await _purchaseService.buyProduct(productId);
    } catch (e) {
      _error = 'Purchase failed: $e';
      notifyListeners();
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _purchaseService.restorePurchases();
    } catch (e) {
      _error = 'Restore failed: $e';
      notifyListeners();
    }
  }


  /// Get product details by ID
  ProductDetails? getProduct(String productId) {
    return _purchaseService.getProduct(productId);
  }

  /// Ensure user is authenticated (for testing)
  Future<bool> ensureAuthentication() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      return true;
    } catch (e) {
      _error = 'Authentication failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get ID token for testing
  Future<String?> getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      _error = 'Failed to get ID token: $e';
      notifyListeners();
      return null;
    }
  }

  /// Check billing availability
  Future<bool> checkBillingAvailability() async {
    try {
      final isAvailable = await InAppPurchase.instance.isAvailable();
      print('🔍 Billing availability check: $isAvailable');
      return isAvailable;
    } catch (e) {
      print('❌ Billing availability check failed: $e');
      return false;
    }
  }


  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}
