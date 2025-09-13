
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

// --- NEW IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Added for kDebugMode

class PurchaseProvider extends ChangeNotifier {
  final _iap = InAppPurchase.instance;
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // --- NEW: Firestore listener subscription ---
  StreamSubscription? _firestoreSubscription;
  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSubscription;
  
  // --- NEW: Billing availability tracking ---
  bool _isBillingAvailable = false;
  String? _billingError;

  static const _kProductIds = <String>[
    'com.redtea.minddrift.bundle.horror',
    'com.redtea.minddrift.bundle.kids',
    'com.redtea.minddrift.bundle.food',
    'com.redtea.minddrift.bundle.nature',
    'com.redtea.minddrift.bundle.fantasy',
    'com.redtea.minddrift.all_access',
  ];

  List<ProductDetails> products = [];
  final Set<String> _owned = {'bundle.free'};

  PurchaseProvider() {
    _init();
  }

  Future<void> _init() async {
    // In debug mode, point to local Firebase emulators
    if (kDebugMode) {
      print('🐛 DEBUG MODE: Using local Firebase emulators');
      // Replace 'localhost' with your computer's IP if testing on a physical device
      const host = '10.0.2.2'; // Use '10.0.2.2' for Android Emulator, 'localhost' for iOS/web
      
      try {
        _auth.useAuthEmulator(host, 9099);
        _db.useFirestoreEmulator(host, 8080);
        FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
      } catch (e) {
        print('⚠️ Error connecting to emulators: $e');
        print('Emulator setup might have already been initialized.');
      }
    }
    // Check if billing is available on this device
    try {
      _isBillingAvailable = await _iap.isAvailable();
      if (_isBillingAvailable) {
        _purchaseStreamSubscription = _iap.purchaseStream.listen(_onPurchaseUpdated);
        
        // ❌ REMOVED: This was causing race condition - _restorePurchases() called too early
      } else {
        _billingError = 'In-app billing is not available on this device';
        print('⚠️ In-app billing not available: $_billingError');
      }
    } catch (e) {
      _isBillingAvailable = false;
      _billingError = 'Failed to initialize billing: $e';
      print('❌ Billing initialization failed: $_billingError');
    }

    // Listen to auth changes to set up the Firestore listener for the current user
    _auth.authStateChanges().listen((user) {
      print('🔄 Auth state changed: ${user?.uid ?? "null"}');
      _firestoreSubscription?.cancel(); // Cancel any previous listener
      if (user != null) {
        print('✅ User authenticated: ${user.uid}');
        _listenForOwnedSkus(user.uid);
        // Restore purchases after user is authenticated
        _restorePurchases();
      } else {
        print('❌ User not authenticated, clearing owned items');
        // User logged out, clear owned items (except free)
        _owned.clear();
        _owned.add('bundle.free');
        notifyListeners();
      }
    });

    // Only try to query products if billing is available
    if (_isBillingAvailable) {
      try {
        final response = await _iap.queryProductDetails(_kProductIds.toSet());
        products = response.productDetails;
        // Notify listeners here AFTER products are loaded
        notifyListeners();
      } catch (e) {
        print('❌ Failed to query product details: $e');
        _billingError = 'Failed to load products: $e';
        notifyListeners();
      }
    } else {
      notifyListeners();
    }
    
    // ❌ REMOVED: Final notifyListeners() call that was causing race condition
  }

  // --- NEW: Restore purchases from Firestore ---
  Future<void> _restorePurchases() async {
    try {
      if (_auth.currentUser == null) {
        print('⚠️ No user authenticated, cannot restore purchases');
        return;
      }
      
      print('🔄 Restoring purchases for user: ${_auth.currentUser!.uid}');
      print('🔍 Firestore instance: ${_db.app.name}');
      print('🔍 Firestore settings: ${_db.settings}');
      
      // Get the user document (where Cloud Function stores owned_skus)
      final doc = await _db
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      print('📄 Document exists: ${doc.exists}');
      print('📄 Document ID: ${doc.id}');
      print('📄 Document path: ${doc.reference.path}');
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        print('📄 User document data: $data');
        print('📄 Document fields: ${data.keys.toList()}');
        
        if (data.containsKey('owned_skus')) {
          final List<dynamic> ownedSkus = data['owned_skus'] ?? [];
          print('🎯 Found owned_skus: $ownedSkus');
          print('🎯 owned_skus type: ${ownedSkus.runtimeType}');
          print('🎯 owned_skus length: ${ownedSkus.length}');
          
          _owned.clear();
          _owned.add('bundle.free'); // Always include free bundle
          _owned.addAll(ownedSkus.cast<String>());
          
          print('✅ Restored owned bundles: $_owned');
          print('✅ _owned set size: ${_owned.length}');
          print('✅ Calling notifyListeners()');
          notifyListeners();
          print('✅ notifyListeners() completed');
        } else {
          print('⚠️ No owned_skus field found in user document');
          print('⚠️ Available fields: ${data.keys.toList()}');
        }
      } else {
        print('⚠️ User document does not exist or has no data');
        print('⚠️ Document exists: ${doc.exists}');
        print('⚠️ Document data: ${doc.data()}');
      }
    } catch (e) {
      print('❌ Failed to restore purchases: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  // --- NEW: Check if a bundle is owned ---
  bool isOwned(String sku) {
    final result = _owned.contains(sku);
    print('🔍 isOwned($sku): $result (owned set: $_owned)');
    return result;
  }

  // --- NEW: Get list of owned bundles ---
  Set<String> get ownedBundles => Set.from(_owned);
  
  // --- NEW: Billing status getters ---
  bool get isBillingAvailable => _isBillingAvailable;
  String? get billingError => _billingError;

  // --- NEW: Manual authentication method for testing ---
  Future<bool> ensureAuthentication() async {
    try {
      if (_auth.currentUser != null) {
        print('✅ User already authenticated: ${_auth.currentUser?.uid}');
        return true;
      }
      
      print('🔄 Signing in anonymously...');
      await _auth.signInAnonymously();
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_auth.currentUser != null) {
        print('✅ Authentication successful: ${_auth.currentUser?.uid}');
        return true;
      } else {
        print('❌ Authentication failed: no user after sign-in');
        return false;
      }
    } catch (e) {
      print('❌ Authentication error: $e');
      return false;
    }
  }
  
  // --- NEW: Get ID token for testing ---
  Future<String?> getIdToken() async {
    try {
      if (_auth.currentUser == null) {
        print('❌ No user authenticated');
        return null;
      }
      
      final token = await _auth.currentUser!.getIdToken();
      print('🔑 ID Token obtained: ${token?.substring(0, 50)}...');
      return token;
    } catch (e) {
      print('❌ Failed to get ID token: $e');
      return null;
    }
  }

  // --- NEW: Restore purchases from Google Play ---
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      print('✅ Called restore purchases. The purchase stream will now emit owned items.');
    } catch (e) {
      print('❌ Failed to restore purchases: $e');
    }
  }

  Future<void> buy(String sku) async {
    if (!_isBillingAvailable) {
      print('❌ Cannot purchase $sku: Billing not available');
      return;
    }
    
    final product = products.firstWhereOrNull((p) => p.id == sku);
    if (product == null) {
      print('❌ Product $sku not found');
      return;
    }
    
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('❌ Purchase failed for $sku: $e');
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> updates) async {
    for (var pd in updates) {
      if (pd.status == PurchaseStatus.purchased) {
        // Purchase is successful on the device. Call our Cloud Function to verify.
        try {
          // Ensure user is authenticated before calling Cloud Function
          if (_auth.currentUser == null) {
            print('⚠️ User not authenticated, attempting anonymous sign-in...');
            try {
              await _auth.signInAnonymously();
              print('✅ Anonymous authentication successful: ${_auth.currentUser?.uid}');
            } catch (e) {
              print('❌ Anonymous authentication failed: $e');
              continue; // Skip this purchase if we can't authenticate
            }
          }
          
          print('🔐 Calling Cloud Function for purchase: ${pd.productID}');
          
          // 👇 SPECIFY THE REGION HERE to match your function
          final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
              .httpsCallable('verifyPurchase');
          
          final result = await callable.call({
            'token': pd.verificationData.serverVerificationData,
            'sku': pd.productID,
            'platform': 'android', // Or 'ios'
            'transactionId': pd.purchaseID,
            'originalTransactionId': pd.purchaseID, // For non-consumables, these are the same
          });
          
          print('✅ Cloud Function call successful: ${result.data}');
        } catch (e) {
          print('❌ Server verification failed for ${pd.productID}: $e');
        }
      }
      
      // Always complete the purchase on the device to finalize the transaction.
      if (pd.pendingCompletePurchase) {
        await _iap.completePurchase(pd);
      }
    }
  }

  // --- NEW: Listen for owned SKUs changes in Firestore ---
  void _listenForOwnedSkus(String userId) {
    print('👂 Setting up Firestore listener for user: $userId');
    
    _firestoreSubscription = _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (data.containsKey('owned_skus')) {
          final List<dynamic> ownedSkus = data['owned_skus'] ?? [];
          
          // Update the local owned set
          _owned.clear();
          _owned.add('bundle.free'); // Always include free bundle
          _owned.addAll(ownedSkus.cast<String>());
          
          print('🔄 Firestore update: owned bundles now: $_owned');
          notifyListeners();
        }
      }
    }, onError: (error) {
      print('❌ Firestore listener error: $error');
    });
  }

  @override
  void dispose() {
    _purchaseStreamSubscription?.cancel();
    _firestoreSubscription?.cancel(); // <-- Don't forget to cancel the new listener
    super.dispose();
  }
}

