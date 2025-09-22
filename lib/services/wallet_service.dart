// lib/services/wallet_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/player_wallet.dart';
import '../widgets/gems_reward_animation.dart';
import '../services/quest_service.dart';
import '../data/cosmetic_catalog.dart';

class WalletService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get user's wallet, creating one if it doesn't exist
  static Future<PlayerWallet> getWallet() async {
    final user = _auth.currentUser;
    if (user == null) {
      // Return default wallet for unauthenticated users
      return PlayerWallet(
        userId: '',
        mindGems: 0,
        totalGemsEarned: 0,
        totalGemsSpent: 0,
        lastDailyBonus: DateTime(2000), // Default old date
        ownedBadges: const [],
        ownedSpectrumSkins: const [],
        activeSpectrumSkin: 'default',
      );
    }

    try {
      final doc = await _db
          .collection('player_wallets')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return PlayerWallet.fromFirestore(doc);
      } else {
        // Create initial wallet for new user
        final initialWallet = PlayerWallet(
          userId: user.uid,
          lastDailyBonus: DateTime(2000), // Ensures first daily bonus is available
        );
        
        await _db
            .collection('player_wallets')
            .doc(user.uid)
            .set(initialWallet.toFirestore());
        
        return initialWallet;
      }
    } catch (e) {
      print('Error fetching wallet: $e');
      rethrow;
    }
  }

  /// Award Mind Gems to the user with transaction logging
  static Future<void> awardGems(int amount, String reason, {Map<String, dynamic>? metadata, BuildContext? context}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      print('Awarding $amount Gems to ${user.uid} for: $reason');

      await _db.runTransaction((transaction) async {
        // Get current wallet
        final walletRef = _db.collection('player_wallets').doc(user.uid);
        final walletDoc = await transaction.get(walletRef);
        
        PlayerWallet currentWallet;
        if (walletDoc.exists) {
          currentWallet = PlayerWallet.fromFirestore(walletDoc);
        } else {
          currentWallet = PlayerWallet(
            userId: user.uid,
            lastDailyBonus: DateTime(2000),
          );
        }

        // Update wallet with new Gems
        final updatedWallet = currentWallet.copyWith(
          mindGems: currentWallet.mindGems + amount,
          totalGemsEarned: currentWallet.totalGemsEarned + amount,
        );

        // Save updated wallet
        transaction.set(walletRef, updatedWallet.toFirestore());

        // Log transaction
        final transactionRef = _db
            .collection('gem_transactions')
            .doc(user.uid)
            .collection('transactions')
            .doc();

        final gemTransaction = GemTransaction(
          transactionId: transactionRef.id,
          userId: user.uid,
          amount: amount,
          reason: reason,
          timestamp: DateTime.now(),
          metadata: metadata ?? {},
        );

        transaction.set(transactionRef, gemTransaction.toFirestore());
      });

      print('Successfully awarded $amount Gems for: $reason');
      
      // Show gems reward animation if context is provided
      if (context != null && context.mounted) {
        GemsRewardOverlay.show(
          context,
          gemsEarned: amount,
          reason: reason,
        );
      }

      // Track gem earning for quests (avoid circular dependency)
      if (reason != 'quest_completion') {
        await QuestService.trackProgress('earn_gems', 
          amount: amount,
          context: context,
          metadata: {
            'reason': reason,
            'amount': amount,
            ...?metadata,
          });

        // Track total gems earned for lifetime achievements
        await QuestService.trackProgress('earn_gems_total', 
          amount: amount,
          context: context,
          metadata: {
            'reason': reason,
            'amount': amount,
            ...?metadata,
          });
      }
    } catch (e) {
      print('Error awarding Gems: $e');
      rethrow;
    }
  }

  /// Spend Mind Gems for a purchase with transaction logging
  static Future<bool> spendGems(int amount, String reason, String itemId, {Map<String, dynamic>? metadata}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      print('Attempting to spend $amount Gems for: $reason ($itemId)');

      bool success = false;

      await _db.runTransaction((transaction) async {
        // Get current wallet
        final walletRef = _db.collection('player_wallets').doc(user.uid);
        final walletDoc = await transaction.get(walletRef);
        
        if (!walletDoc.exists) {
          throw Exception('Wallet not found');
        }

        final currentWallet = PlayerWallet.fromFirestore(walletDoc);

        // Check if user can afford the purchase
        if (currentWallet.mindGems < amount) {
          success = false;
          return;
        }

        // Update wallet with spent Gems
        final updatedWallet = currentWallet.copyWith(
          mindGems: currentWallet.mindGems - amount,
          totalGemsSpent: currentWallet.totalGemsSpent + amount,
        );

        // Save updated wallet
        transaction.set(walletRef, updatedWallet.toFirestore());

        // Log transaction
        final transactionRef = _db
            .collection('gem_transactions')
            .doc(user.uid)
            .collection('transactions')
            .doc();

        final gemTransaction = GemTransaction(
          transactionId: transactionRef.id,
          userId: user.uid,
          amount: -amount, // Negative for spending
          reason: reason,
          timestamp: DateTime.now(),
          metadata: {
            'itemId': itemId,
            ...?metadata,
          },
        );

        transaction.set(transactionRef, gemTransaction.toFirestore());
        success = true;
      });

      if (success) {
        print('Successfully spent $amount Gems for: $reason');
      } else {
        print('Failed to spend Gems: Insufficient balance');
      }

      return success;
    } catch (e) {
      print('Error spending Gems: $e');
      return false;
    }
  }

  /// Check if user is eligible for daily bonus (once per day)
  static Future<bool> canClaimDailyBonus() async {
    final wallet = await getWallet();
    final today = DateTime.now();
    final lastBonus = wallet.lastDailyBonus;
    
    // Check if it's a different day
    return today.year != lastBonus.year ||
           today.month != lastBonus.month ||
           today.day != lastBonus.day;
  }

  /// Award daily bonus if eligible
  static Future<bool> claimDailyBonus({BuildContext? context}) async {
    if (!await canClaimDailyBonus()) {
      return false; // Already claimed today
    }

    try {
      await awardGems(250, 'daily_bonus', 
        context: context,
        metadata: {
          'date': DateTime.now().toIso8601String(),
        });

      // Update last daily bonus timestamp
      final user = _auth.currentUser!;
      await _db
          .collection('player_wallets')
          .doc(user.uid)
          .update({
        'lastDailyBonus': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error claiming daily bonus: $e');
      return false;
    }
  }

  /// Purchase a cosmetic item and add it to the player's collection
  static Future<bool> purchaseItem(CosmeticItem item) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      bool success = false;

      await _db.runTransaction((transaction) async {
        final walletRef = _db.collection('player_wallets').doc(user.uid);
        final walletDoc = await transaction.get(walletRef);
        
        if (!walletDoc.exists) {
          throw Exception('Wallet not found');
        }

        final currentWallet = PlayerWallet.fromFirestore(walletDoc);

        // Check if user can afford and doesn't already own the item
        if (currentWallet.mindGems < item.gemPrice) {
          success = false;
          return;
        }

        // Check if already owned
        bool alreadyOwned = false;
        List<String> updatedOwnedItems = [];

        switch (item.type) {
          case CosmeticType.sliderSkin:
            alreadyOwned = currentWallet.ownedSliderSkins.contains(item.id);
            updatedOwnedItems = [...currentWallet.ownedSliderSkins, item.id];
            break;
          case CosmeticType.badge:
            alreadyOwned = currentWallet.ownedBadges.contains(item.id);
            updatedOwnedItems = [...currentWallet.ownedBadges, item.id];
            break;
          case CosmeticType.avatarPack:
            alreadyOwned = currentWallet.ownedAvatarPacks.contains(item.id);
            updatedOwnedItems = [...currentWallet.ownedAvatarPacks, item.id];
            break;
        }

        if (alreadyOwned) {
          success = false;
          return;
        }

        // Update wallet with purchase
        PlayerWallet updatedWallet;
        switch (item.type) {
          case CosmeticType.sliderSkin:
            updatedWallet = currentWallet.copyWith(
              mindGems: currentWallet.mindGems - item.gemPrice,
              totalGemsSpent: currentWallet.totalGemsSpent + item.gemPrice,
              ownedSliderSkins: updatedOwnedItems,
            );
            break;
          case CosmeticType.badge:
            updatedWallet = currentWallet.copyWith(
              mindGems: currentWallet.mindGems - item.gemPrice,
              totalGemsSpent: currentWallet.totalGemsSpent + item.gemPrice,
              ownedBadges: updatedOwnedItems,
            );
            break;
          case CosmeticType.avatarPack:
            updatedWallet = currentWallet.copyWith(
              mindGems: currentWallet.mindGems - item.gemPrice,
              totalGemsSpent: currentWallet.totalGemsSpent + item.gemPrice,
              ownedAvatarPacks: updatedOwnedItems,
            );
            break;
        }

        // Save updated wallet
        transaction.set(walletRef, updatedWallet.toFirestore());

        // Log purchase transaction
        final transactionRef = _db
            .collection('gem_transactions')
            .doc(user.uid)
            .collection('transactions')
            .doc();

        final gemTransaction = GemTransaction(
          transactionId: transactionRef.id,
          userId: user.uid,
          amount: -item.gemPrice,
          reason: 'purchase_${item.type.toString()}',
          timestamp: DateTime.now(),
          metadata: {
            'itemId': item.id,
            'itemName': item.name,
            'itemType': item.type.toString(),
          },
        );

        transaction.set(transactionRef, gemTransaction.toFirestore());
        success = true;
      });

      if (success) {
        print('Successfully purchased ${item.name} for ${item.gemPrice} Gems');
      }

      return success;
    } catch (e) {
      print('Error purchasing item: $e');
      return false;
    }
  }

  /// Get user's transaction history
  static Future<List<GemTransaction>> getTransactionHistory({int limit = 50}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _db
          .collection('gem_transactions')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => GemTransaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching transaction history: $e');
      return [];
    }
  }

  /// Award Gems for campaign star achievement
  static Future<void> awardCampaignStarGems(String levelId, int starsEarned, bool isFirstTime, {BuildContext? context}) async {
    if (!isFirstTime) return; // Only award Gems for first-time star earning

    int gemAmount = 0;
    switch (starsEarned) {
      case 1:
        gemAmount = 25;
        break;
      case 2:
        gemAmount = 75; // 25 + 50
        break;
      case 3:
        gemAmount = 150; // 25 + 50 + 75
        break;
    }

    if (gemAmount > 0) {
      await awardGems(gemAmount, 'campaign_stars', 
        context: context,
        metadata: {
          'levelId': levelId,
          'starsEarned': starsEarned,
          'isFirstTime': isFirstTime,
        });
    }
  }

  /// Award Gems for campaign achievement
  static Future<void> awardAchievementGems(String achievementId) async {
    int gemAmount = 0;
    switch (achievementId) {
      case 'firstLevel':
        gemAmount = 50;
        break;
      case 'firstSection':
        gemAmount = 100;
        break;
      case 'perfectLevel':
        gemAmount = 150;
        break;
      case 'speedRunner':
        gemAmount = 200;
        break;
      case 'starCollector':
        gemAmount = 300;
        break;
      case 'campaignMaster':
        gemAmount = 1000;
        break;
    }

    if (gemAmount > 0) {
      await awardGems(gemAmount, 'achievement', metadata: {
        'achievementId': achievementId,
      });
    }
  }

  // --- NEW: Real-time Wallet Stream ---
  static Stream<PlayerWallet> getWalletStream() {
    final user = _auth.currentUser;
    if (user == null) {
      // Return a stream with default wallet for unauthenticated users
      return Stream.value(PlayerWallet(
        userId: '',
        mindGems: 0,
        totalGemsEarned: 0,
        totalGemsSpent: 0,
        lastDailyBonus: DateTime(2000),
        ownedBadges: const [],
        ownedSpectrumSkins: const [],
        activeSpectrumSkin: 'default',
      ));
    }

    return _db
        .collection('player_wallets')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return PlayerWallet.fromFirestore(snapshot);
      } else {
        // Return default wallet if document doesn't exist
        return PlayerWallet(
          userId: user.uid,
          lastDailyBonus: DateTime(2000),
        );
      }
    });
  }

  // --- NEW: Owned Avatar Packs Stream (derived from the wallet stream) ---
  static Stream<List<String>> getOwnedAvatarPacksStream() {
    return getWalletStream().map((wallet) => wallet.ownedAvatarPacks);
  }

  // --- NEW: Avatar Pack Purchase Method ---
  static Future<bool> purchaseAvatarPack(String packId) async {
    final pack = CosmeticCatalog.getAvatarPackById(packId);
    if (pack == null) {
      print('Error: Pack not found: $packId');
      return false;
    }

    final user = _auth.currentUser;
    if (user == null) {
      print('Error: User not authenticated');
      return false;
    }

    try {
      bool success = false;

      await _db.runTransaction((transaction) async {
        final walletRef = _db.collection('player_wallets').doc(user.uid);
        final walletDoc = await transaction.get(walletRef);
        
        if (!walletDoc.exists) {
          throw Exception('Wallet not found');
        }

        final currentWallet = PlayerWallet.fromFirestore(walletDoc);

        // Check if user can afford the purchase
        if (currentWallet.mindGems < pack.gemPrice) {
          success = false;
          return;
        }

        // Check if already owned
        if (currentWallet.ownedAvatarPacks.contains(pack.packId)) {
          success = false;
          return;
        }

        // Update wallet with purchase
        final updatedWallet = currentWallet.copyWith(
          mindGems: currentWallet.mindGems - pack.gemPrice,
          totalGemsSpent: currentWallet.totalGemsSpent + pack.gemPrice,
          ownedAvatarPacks: [...currentWallet.ownedAvatarPacks, pack.packId],
        );

        // Save updated wallet
        transaction.set(walletRef, updatedWallet.toFirestore());

        // Log purchase transaction
        final transactionRef = _db
            .collection('gem_transactions')
            .doc(user.uid)
            .collection('transactions')
            .doc();

        final gemTransaction = GemTransaction(
          transactionId: transactionRef.id,
          userId: user.uid,
          amount: -pack.gemPrice,
          reason: 'purchase_avatar_pack',
          timestamp: DateTime.now(),
          metadata: {
            'itemId': pack.packId,
            'itemName': pack.name,
            'itemType': 'avatar_pack',
          },
        );

        transaction.set(transactionRef, gemTransaction.toFirestore());
        success = true;
      });

      if (success) {
        print('Successfully purchased ${pack.name} for ${pack.gemPrice} Gems');
      } else {
        print('Failed to purchase ${pack.name}: Insufficient balance or already owned');
      }

      return success;
    } catch (e) {
      print('Error purchasing avatar pack: $e');
      return false;
    }
  }

  // --- NEW: Username Change Spend Method ---
  static Future<bool> spendGemsForUsernameChange({required int cost}) async {
    return await spendGems(
      cost,
      'username_change',
      'username_change',
      metadata: {
        'cost': cost,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
