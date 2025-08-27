
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_functions/cloud_functions.dart';

// --- NEW IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/category_service.dart';

class PurchaseProvider extends ChangeNotifier {
  final _iap = InAppPurchase.instance;
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // --- NEW: Firestore listener subscription ---
  StreamSubscription? _firestoreSubscription;
  late StreamSubscription<List<PurchaseDetails>> _purchaseStreamSubscription;

  static const _kProductIds = <String>[
    'bundle.horror',
    'bundle.kids',
    'bundle.food',
    'bundle.nature',
    'bundle.fantasy',
    'all_access',
  ];

  List<ProductDetails> products = [];
  final Set<String> _owned = {'bundle.free'};

  PurchaseProvider() {
    _purchaseStreamSubscription = _iap.purchaseStream.listen(_onPurchaseUpdated);
    _init();
  }

  Future<void> _init() async {
    // Listen to auth changes to set up the Firestore listener for the current user
    _auth.authStateChanges().listen((user) {
      _firestoreSubscription?.cancel(); // Cancel any previous listener
      if (user != null) {
        _listenForOwnedSkus(user.uid);
      } else {
        // User logged out, clear owned items (except free)
        _owned.clear();
        _owned.add('bundle.free');
        notifyListeners();
      }
    });

    final response = await _iap.queryProductDetails(_kProductIds.toSet());
    products = response.productDetails;
    await _iap.restorePurchases();
    notifyListeners();
  }

  // --- NEW: This function listens to Firestore for secure entitlements ---
  void _listenForOwnedSkus(String uid) {
    _firestoreSubscription = _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final skus = List<String>.from(snapshot.data()!['owned_skus'] ?? []);
        _owned.clear();
        _owned.add('bundle.free'); // Always own the free bundle
        _owned.addAll(skus);
        print('✅ Firestore owned SKUs updated: $_owned');
        
        // Clear category cache when owned bundles change
        CategoryService.clearCache();
        
        notifyListeners();
      }
    });
  }

  bool isOwned(String sku) => _owned.contains(sku) || _owned.contains('all_access');
  Set<String> get ownedBundles => _owned;

  Future<void> buy(String sku) async {
    final product = products.firstWhereOrNull((p) => p.id == sku);
    if (product == null) return;
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> updates) async {
    for (var pd in updates) {
      if (pd.status == PurchaseStatus.purchased) {
        // Purchase is successful on the device. Call our Cloud Function to verify.
        try {
          final callable = FirebaseFunctions.instance.httpsCallable('verifyPurchase');
          await callable.call({
            'token': pd.verificationData.serverVerificationData,
            'sku': pd.productID,
            'platform': 'android', // Or 'ios'
          });
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

  @override
  void dispose() {
    _purchaseStreamSubscription.cancel();
    _firestoreSubscription?.cancel(); // <-- Don't forget to cancel the new listener
    super.dispose();
  }
}

