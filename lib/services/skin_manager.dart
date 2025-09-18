// lib/services/skin_manager.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spectrum_skin.dart';
import '../services/wallet_service.dart';

/// Manages spectrum skin selection and application
class SkinManager {
  static const String _collection = 'player_wallets';
  static const String _activeSkinsField = 'activeSpectrumSkin';
  static const String _ownedSkinsField = 'ownedSpectrumSkins';

  /// Get current user's active skin
  static Future<SpectrumSkin> getCurrentSkin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SpectrumSkinCatalog.defaultSkin;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return SpectrumSkinCatalog.defaultSkin;

      final data = doc.data() as Map<String, dynamic>;
      final activeSkinId = data[_activeSkinsField] as String? ?? 'default';
      
      return SpectrumSkinCatalog.getSkinById(activeSkinId);
    } catch (e) {
      return SpectrumSkinCatalog.defaultSkin;
    }
  }

  /// Get current user's active skin ID (synchronous for UI)
  static String _cachedActiveSkinId = 'default';
  
  static String getCurrentSkinId() {
    return _cachedActiveSkinId;
  }

  /// Initialize and cache the current skin
  static Future<void> initializeSkin() async {
    final skin = await getCurrentSkin();
    _cachedActiveSkinId = skin.id;
  }

  /// Apply a skin (user must own it or it must be free)
  static Future<bool> applySkin(String skinId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // Check if user owns the skin or it's the default
      if (skinId != 'default') {
        final wallet = await WalletService.getWallet();
        final ownedSkins = wallet.ownedSpectrumSkins ?? [];
        
        if (!ownedSkins.contains(skinId)) {
          throw Exception('User does not own this skin');
        }
      }

      // Apply the skin
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .update({
        _activeSkinsField: skinId,
      });

      // Update cache
      _cachedActiveSkinId = skinId;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Purchase a skin with gems
  static Future<bool> purchaseSkin(String skinId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final skin = SpectrumSkinCatalog.getSkinById(skinId);
      if (skin.id == 'default') return false; // Can't purchase default

      // Check if user has enough gems
      final wallet = await WalletService.getWallet();
      if (wallet.mindGems < skin.gemPrice) {
        throw Exception('Insufficient gems');
      }

      // Check if already owned
      final ownedSkins = wallet.ownedSpectrumSkins ?? [];
      if (ownedSkins.contains(skinId)) {
        throw Exception('Skin already owned');
      }

      // Perform transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final walletRef = FirebaseFirestore.instance
            .collection(_collection)
            .doc(user.uid);

        final walletDoc = await transaction.get(walletRef);
        if (!walletDoc.exists) {
          throw Exception('Wallet not found');
        }

        final walletData = walletDoc.data() as Map<String, dynamic>;
        final currentGems = walletData['mindGems'] as int? ?? 0;
        final currentOwnedSkins = List<String>.from(walletData[_ownedSkinsField] ?? []);

        if (currentGems < skin.gemPrice) {
          throw Exception('Insufficient gems');
        }

        if (currentOwnedSkins.contains(skinId)) {
          throw Exception('Skin already owned');
        }

        // Update wallet
        transaction.update(walletRef, {
          'mindGems': currentGems - skin.gemPrice,
          _ownedSkinsField: [...currentOwnedSkins, skinId],
          'totalGemsSpent': (walletData['totalGemsSpent'] as int? ?? 0) + skin.gemPrice,
        });

        // Add transaction record
        final transactionRef = walletRef.collection('transactions').doc();
        transaction.set(transactionRef, {
          'type': 'purchase',
          'itemType': 'spectrum_skin',
          'itemId': skinId,
          'itemName': skin.name,
          'gemsSpent': skin.gemPrice,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user's owned skins
  static Future<List<String>> getOwnedSkins() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return ['default'];

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return ['default'];

      final data = doc.data() as Map<String, dynamic>;
      final ownedSkins = List<String>.from(data[_ownedSkinsField] ?? []);
      
      // Always include default skin
      if (!ownedSkins.contains('default')) {
        ownedSkins.insert(0, 'default');
      }
      
      return ownedSkins;
    } catch (e) {
      return ['default'];
    }
  }

  /// Check if user owns a specific skin
  static Future<bool> ownsSkin(String skinId) async {
    if (skinId == 'default') return true; // Default is always owned
    
    final ownedSkins = await getOwnedSkins();
    return ownedSkins.contains(skinId);
  }

  /// Get available skins for purchase (not owned)
  static Future<List<SpectrumSkin>> getAvailableForPurchase() async {
    final ownedSkins = await getOwnedSkins();
    return SpectrumSkinCatalog.premiumSkins
        .where((skin) => !ownedSkins.contains(skin.id))
        .toList();
  }
}
