// lib/services/purchase_service.dart
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple, reliable IAP service with clear separation of concerns
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  // Product IDs
  static const List<String> productIds = [
    'bundle.horror',
    'bundle.kids', 
    'bundle.food',
    'bundle.nature',
    'bundle.fantasy',
    'all_access',
  ];

  // State
  List<ProductDetails> _products = [];
  Set<String> _ownedBundles = {'bundle.free'};
  bool _isInitialized = false;
  bool _isBillingAvailable = false;
  String? _error;

  // Stream controllers for reactive updates
  final StreamController<Set<String>> _ownedBundlesController = StreamController<Set<String>>.broadcast();
  final StreamController<String?> _errorController = StreamController<String?>.broadcast();

  // Getters
  List<ProductDetails> get products => List.unmodifiable(_products);
  Set<String> get ownedBundles => Set.unmodifiable(_ownedBundles);
  bool get isInitialized => _isInitialized;
  bool get isBillingAvailable => _isBillingAvailable;
  String? get error => _error;
  bool get hasAllAccess => _ownedBundles.contains('all_access');
  
  // Streams
  Stream<Set<String>> get ownedBundlesStream => _ownedBundlesController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  /// Initialize the purchase service
  Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ PurchaseService already initialized');
      return;
    }

    try {
      print('🚀 Initializing PurchaseService...');
      
      // Check billing availability
      final isAvailable = await _iap.isAvailable();
      _isBillingAvailable = isAvailable;
      print('🔍 Billing available: $isAvailable');
      
      if (!isAvailable) {
        print('⚠️ In-app billing not available on this device');
        print('⚠️ This could be due to:');
        print('   - Device doesn\'t support Google Play Billing');
        print('   - Google Play Services not installed/updated');
        print('   - Running on emulator without Google Play');
        print('   - Device not certified by Google');
        
        // Set up auth listener anyway so users can still use the app
        _auth.authStateChanges().listen(_handleAuthChange);
        print('👂 Auth state listener set up (billing disabled)');
        
        _isInitialized = true;
        _clearError(); // Don't show error, just disable billing features
        print('✅ PurchaseService initialized (billing disabled)');
        return;
      }

      // Load products
      await _loadProducts();
      
      // Set up purchase stream listener
      _iap.purchaseStream.listen(_handlePurchaseUpdate);
      print('👂 Purchase stream listener set up');
      
      // Set up auth listener
      _auth.authStateChanges().listen(_handleAuthChange);
      print('👂 Auth state listener set up');
      
      _isInitialized = true;
      _clearError();
      print('✅ PurchaseService initialized successfully');
      
    } catch (e) {
      _setError('Failed to initialize purchase service: $e');
      print('❌ PurchaseService initialization failed: $e');
    }
  }

  /// Load available products from Google Play
  Future<void> _loadProducts() async {
    try {
      final response = await _iap.queryProductDetails(productIds.toSet());
      _products = response.productDetails;
      print('📦 Loaded ${_products.length} products');
    } catch (e) {
      _setError('Failed to load products: $e');
      print('❌ Failed to load products: $e');
    }
  }

  /// Handle authentication state changes
  void _handleAuthChange(User? user) {
    if (user != null) {
      print('👤 User authenticated: ${user.uid}');
      _loadOwnedBundles(user.uid);
      _setupFirestoreListener(user.uid);
    } else {
      print('👤 User signed out');
      _ownedBundles = {'bundle.free'};
      _ownedBundlesController.add(_ownedBundles);
    }
  }

  /// Load owned bundles from Firestore
  Future<void> _loadOwnedBundles(String userId) async {
    try {
      print('📥 Loading owned bundles for user: $userId');
      
      // Check if user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user, cannot load owned bundles');
        _setError('User not authenticated');
        return;
      }
      
      if (currentUser.uid != userId) {
        print('❌ User ID mismatch: current=${currentUser.uid}, requested=$userId');
        _setError('User ID mismatch');
        return;
      }
      
      print('🔍 Current user: ${currentUser.uid}, isAnonymous: ${currentUser.isAnonymous}');
      
      // First, ensure the user document exists by calling the Cloud Function
      try {
        print('🔧 Ensuring user document exists...');
        final callable = _functions.httpsCallable('ensureUserDocument');
        await callable.call().timeout(const Duration(seconds: 10));
        print('✅ User document ensured');
      } catch (ensureError) {
        print('⚠️ Could not ensure user document: $ensureError');
        // Continue anyway - create user document locally if needed
        try {
          await _createUserDocumentLocally(currentUser);
        } catch (localError) {
          print('⚠️ Could not create user document locally: $localError');
        }
      }
      
      // Now load the owned bundles
      final doc = await _db.collection('users').doc(userId).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final ownedSkus = List<String>.from(data['owned_skus'] ?? []);
        
        _ownedBundles = {'bundle.free', ...ownedSkus};
        _ownedBundlesController.add(_ownedBundles);
        
        print('✅ Loaded owned bundles: $_ownedBundles');
      } else {
        // This should not happen now that we ensure the document exists
        print('⚠️ User document not found for $userId, this is unexpected!');
        _ownedBundles = {'bundle.free'};
        _ownedBundlesController.add(_ownedBundles);
      }
    } catch (e) {
      // An error here is now a REAL problem (like network loss), not a permission issue.
      print('❌ CRITICAL: Failed to load owned bundles: $e');
      _setError('Could not connect to game services. Please check your internet connection.');
    }
  }

  /// Set up Firestore listener for real-time updates
  void _setupFirestoreListener(String userId) {
    print('👂 Setting up Firestore listener for user: $userId');
    
    _db.collection('users').doc(userId).snapshots().listen(
      (snapshot) {
        print('🔄 Firestore snapshot received: exists=${snapshot.exists}');
        
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          final ownedSkus = List<String>.from(data['owned_skus'] ?? []);
          
          _ownedBundles = {'bundle.free', ...ownedSkus};
          _ownedBundlesController.add(_ownedBundles);
          
          print('🔄 Firestore update: owned bundles: $_ownedBundles');
        } else {
          print('⚠️ Firestore snapshot: document does not exist or has no data');
          _ownedBundles = {'bundle.free'};
          _ownedBundlesController.add(_ownedBundles);
        }
      },
      onError: (error) {
        _setError('Firestore listener error: $error');
        print('❌ Firestore listener error: $error');
        print('❌ Error details: ${error.toString()}');
      },
    );
  }

  /// Handle purchase updates from Google Play
  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _verifyPurchase(purchase);
      }
    }
  }

  /// Verify purchase with Cloud Function
  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      print('🔍 Verifying purchase: ${purchase.productID}');
      
      final user = _auth.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return;
      }

      final callable = _functions.httpsCallable('verifyPurchase');
      final result = await callable.call({
        'token': purchase.purchaseID,
        'sku': purchase.productID,
        'platform': 'google_play',
      });

      print('✅ Purchase verified: ${result.data}');
      
    } catch (e) {
      _setError('Failed to verify purchase: $e');
      print('❌ Purchase verification failed: $e');
    }
  }

  /// Buy a product
  Future<void> buyProduct(String productId) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final purchaseParam = PurchaseParam(productDetails: product);
      
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      print('🛒 Purchase initiated for: $productId');
      
    } catch (e) {
      _setError('Failed to initiate purchase: $e');
      print('❌ Purchase initiation failed: $e');
    }
  }

  /// Restore purchases from Google Play
  Future<void> restorePurchases() async {
    try {
      print('🔄 Restoring purchases...');
      await _iap.restorePurchases();
      print('✅ Restore purchases completed');
    } catch (e) {
      _setError('Failed to restore purchases: $e');
      print('❌ Restore purchases failed: $e');
    }
  }


  /// Check if a bundle is owned
  bool isOwned(String bundleId) {
    return _ownedBundles.contains(bundleId);
  }

  /// Get all available bundles for the user (includes all bundles if all access is owned)
  Set<String> getAvailableBundles() {
    if (hasAllAccess) {
      // If user has all access, return all bundle IDs
      return {
        'bundle.free',
        'bundle.horror',
        'bundle.kids',
        'bundle.food',
        'bundle.nature',
        'bundle.fantasy',
      };
    }
    return _ownedBundles;
  }

  /// Get product details by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Error handling
  void _setError(String error) {
    _error = error;
    _errorController.add(_error);
  }

  void _clearError() {
    _error = null;
    _errorController.add(_error);
  }

  /// Dispose resources
  void dispose() {
    _ownedBundlesController.close();
    _errorController.close();
  }

  /// Create user document locally when Firebase Functions are unavailable
  Future<void> _createUserDocumentLocally(User user) async {
    try {
      final userDoc = _db.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'Anonymous',
          'isAnonymous': user.isAnonymous,
          'createdAt': FieldValue.serverTimestamp(),
          'ownedBundles': ['bundle.free'], // Default free bundle
          'lastSeen': FieldValue.serverTimestamp(),
        });
        print('✅ User document created locally');
      }
    } catch (e) {
      print('❌ Failed to create user document locally: $e');
      rethrow;
    }
  }
}
