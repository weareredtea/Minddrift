// lib/services/practice_service.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/practice_clue_data.dart';
import '../data/category_data.dart';
import '../models/practice_models.dart';
import '../services/wallet_service.dart';
import '../services/quest_service.dart';

class PracticeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final Random _random = Random();

  /// Generate a random practice challenge
  /// 1. Random category from 4 available
  /// 2. Random range (1-5) 
  /// 3. Random position within that range
  /// 4. Random clue from the specific (category + range) pool
  static PracticeChallenge generateChallenge([String languageCode = 'en']) {
    // Step 1: Pick random category from practice categories
    final categoryId = _pickRandom(PracticeClueDatabase.practiceCategories);
    
    // Step 2: Pick random range (1-5)
    final range = _random.nextInt(5) + 1;
    
    // Step 3: Generate specific position within that range
    final rangeStart = (range - 1) * 0.2;
    final rangeEnd = range * 0.2;
    final secretPosition = rangeStart + (_random.nextDouble() * (rangeEnd - rangeStart));
    
    // Step 4: Get clue pool for this (category + range) combination
    final cluePool = PracticeClueDatabase.getCluePool(categoryId, range, languageCode);
    final clue = _pickRandom(cluePool);
    
    // Get category info for labels
    final categoryInfo = allCategories.firstWhere((cat) => cat.id == categoryId);
    final bundleId = categoryInfo.bundleId;
    final leftLabel = categoryInfo.getPositiveText(languageCode);
    final rightLabel = categoryInfo.getNegativeText(languageCode);
    
    return PracticeChallenge(
      categoryId: categoryId,
      clue: clue,
      secretPosition: secretPosition,
      range: range,
      bundleId: bundleId,
      leftLabel: leftLabel,
      rightLabel: rightLabel,
    );
  }

  /// Calculate score based on guess accuracy (reuse existing scoring logic)
  static int calculateScore(double userGuess, double secretPosition) {
    final difference = (userGuess - secretPosition).abs();
    final accuracy = 1.0 - difference;
    
    // Convert accuracy to score (0-5 points, same as multiplayer)
    if (accuracy >= 0.95) return 5; // Perfect
    if (accuracy >= 0.80) return 4; // Excellent
    if (accuracy >= 0.60) return 3; // Good
    if (accuracy >= 0.40) return 2; // Fair
    if (accuracy >= 0.20) return 1; // Poor
    return 0; // Very poor
  }

  /// Calculate accuracy percentage (0.0 to 1.0)
  static double calculateAccuracy(double userGuess, double secretPosition) {
    final difference = (userGuess - secretPosition).abs();
    return (1.0 - difference).clamp(0.0, 1.0);
  }

  /// Record practice result and update user statistics
  static Future<void> recordPracticeResult(PracticeResult result, {BuildContext? context}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Store individual result
      await _db
          .collection('practice_results')
          .doc(user.uid)
          .collection('results')
          .add(result.toMap());

      // Update user statistics
      await _updatePracticeStats(user.uid, result);

      // Award Mind Gems for practice completion
      await WalletService.awardGems(20, 'practice_completion', 
        context: context,
        metadata: {
          'categoryId': result.challenge.categoryId,
          'score': result.score,
          'accuracy': result.accuracy,
        });

      // Check and award daily bonus if this is the first game today
      final dailyBonusAwarded = await WalletService.claimDailyBonus(context: context);
      if (dailyBonusAwarded) {
        print('Daily bonus awarded: 250 Gems');
      }

      // Track quest progress
      await QuestService.trackProgress('complete_practice', 
        amount: 1,
        context: context,
        metadata: {
          'categoryId': result.challenge.categoryId,
          'score': result.score,
          'accuracy': result.accuracy,
        });

      // Track perfect score achievement
      if (result.accuracy >= 1.0) {
        await QuestService.trackProgress('perfect_score', 
          amount: 1,
          context: context,
          metadata: {
            'categoryId': result.challenge.categoryId,
            'mode': 'practice',
            'accuracy': result.accuracy,
          });
      }

      // Track accuracy-based quests
      await QuestService.trackProgress('achieve_accuracy', 
        amount: 1,
        context: context,
        metadata: {
          'accuracy': result.accuracy,
          'mode': 'practice',
        });

      // Track general game completion
      await QuestService.trackProgress('complete_any_game', 
        amount: 1,
        context: context,
        metadata: {
          'mode': 'practice',
          'score': result.score,
        });
    } catch (e) {
      print('Error recording practice result: $e');
      // Don't throw - practice should work even if recording fails
    }
  }

  /// Get user's practice statistics
  static Future<PracticeStats> getUserStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return PracticeStats.empty();

    try {
      final doc = await _db
          .collection('practice_stats')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return PracticeStats.fromMap(doc.data()!);
      }
      return PracticeStats.empty();
    } catch (e) {
      print('Error fetching practice stats: $e');
      return PracticeStats.empty();
    }
  }

  /// Update user's practice statistics
  static Future<void> _updatePracticeStats(String userId, PracticeResult result) async {
    final docRef = _db.collection('practice_stats').doc(userId);
    
    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      
      PracticeStats currentStats;
      if (doc.exists && doc.data() != null) {
        currentStats = PracticeStats.fromMap(doc.data()!);
      } else {
        currentStats = PracticeStats.empty();
      }

      // Calculate new statistics
      final newTotalChallenges = currentStats.totalChallenges + 1;
      final newPerfectScores = currentStats.perfectScores + (result.score == 5 ? 1 : 0);
      final newAverageScore = ((currentStats.averageScore * currentStats.totalChallenges) + result.score) / newTotalChallenges;
      final newAverageAccuracy = ((currentStats.averageAccuracy * currentStats.totalChallenges) + result.accuracy) / newTotalChallenges;
      final newBestScore = max(currentStats.bestScore, result.score);
      
      // Update category stats
      final newCategoryStats = Map<String, int>.from(currentStats.categoryStats);
      newCategoryStats[result.challenge.categoryId] = (newCategoryStats[result.challenge.categoryId] ?? 0) + 1;
      
      // Calculate streak
      int newCurrentStreak;
      if (result.score >= 3) { // Good score continues streak
        newCurrentStreak = currentStats.currentStreak + 1;
      } else {
        newCurrentStreak = 0; // Break streak
      }
      final newBestStreak = max(currentStats.bestStreak, newCurrentStreak);

      // Update document
      final updatedStats = PracticeStats(
        totalChallenges: newTotalChallenges,
        perfectScores: newPerfectScores,
        averageScore: newAverageScore,
        averageAccuracy: newAverageAccuracy,
        bestScore: newBestScore,
        bestStreak: newBestStreak,
        currentStreak: newCurrentStreak,
        categoryStats: newCategoryStats,
      );

      transaction.set(docRef, updatedStats.toMap());
    });
  }

  /// Helper method to pick random item from list
  static T _pickRandom<T>(List<T> items) {
    if (items.isEmpty) throw ArgumentError('Cannot pick from empty list');
    return items[_random.nextInt(items.length)];
  }

  /// Get practice challenge statistics for insights
  static Map<String, dynamic> getChallengeInsights(PracticeResult result) {
    return {
      'wasCorrectSide': _wasOnCorrectSide(result.userGuess, result.challenge.secretPosition),
      'distanceFromSecret': (result.userGuess - result.challenge.secretPosition).abs(),
      'rangeGuessed': _getRangeFromPosition(result.userGuess),
      'correctRange': result.challenge.range,
      'improvementTip': _getImprovementTip(result),
    };
  }

  /// Check if user guessed on the correct side of center
  static bool _wasOnCorrectSide(double guess, double secret) {
    return (guess < 0.5 && secret < 0.5) || (guess >= 0.5 && secret >= 0.5);
  }

  /// Get range number from position
  static int _getRangeFromPosition(double position) {
    return (position / 0.2).floor() + 1;
  }

  /// Get improvement tip based on result
  static String _getImprovementTip(PracticeResult result) {
    final distance = (result.userGuess - result.challenge.secretPosition).abs();
    
    if (distance < 0.1) return 'Amazing precision! You\'re getting the hang of this!';
    if (distance < 0.2) return 'Good instinct! Try to fine-tune your guesses.';
    if (distance < 0.3) return 'Think about the clue\'s intensity - how extreme is it?';
    if (distance < 0.5) return 'Consider which side of the spectrum the clue represents.';
    return 'Take your time to think about what the clue really means.';
  }
}
