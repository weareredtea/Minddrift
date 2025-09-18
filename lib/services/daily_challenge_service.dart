// lib/services/daily_challenge_service.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/daily_challenge_data.dart';
import '../data/category_data.dart';
import '../models/daily_challenge_models.dart';
import '../services/wallet_service.dart';
import '../services/quest_service.dart';

class DailyChallengeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get today's daily challenge with localization support
  /// First tries to fetch from Firestore (server-generated)
  /// Falls back to local generation if server challenge not available
  static Future<DailyChallenge> getTodaysChallenge([String languageCode = 'en']) async {
    final today = DateTime.now();
    final todayId = _formatDate(today);

    try {
      // Try to get server-generated challenge first
      final doc = await _db.collection('daily_challenges').doc(todayId).get();
      
      if (doc.exists && doc.data() != null) {
        final challenge = DailyChallenge.fromFirestore(doc);
        // If server challenge exists but we need localization, create localized version
        if (languageCode != 'en') {
          return _createLocalizedChallenge(challenge, languageCode);
        }
        return challenge;
      }
      
      // Fallback: Generate challenge locally using curated template
      return _generateLocalDailyChallenge(today, languageCode);
      
    } catch (e) {
      print('Error fetching daily challenge, using local generation: $e');
      // Fallback to local generation
      return _generateLocalDailyChallenge(today, languageCode);
    }
  }

  /// Generate daily challenge locally using curated template
  static DailyChallenge _generateLocalDailyChallenge(DateTime date, [String languageCode = 'en']) {
    final template = DailyChallengeDatabase.getChallengeForDay(date);
    
    // Get category info
    final categoryInfo = allCategories.firstWhere(
      (cat) => cat.id == template.categoryId,
      orElse: () => allCategories.first, // Fallback to first category
    );
    
    // Calculate position within the specified range
    final rangeStart = (template.range - 1) * 0.2;
    final rangeEnd = template.range * 0.2;
    final secretPosition = rangeStart + (Random(date.day).nextDouble() * (rangeEnd - rangeStart));
    
    return DailyChallenge(
      id: _formatDate(date),
      categoryId: template.categoryId,
      secretPosition: secretPosition,
      range: template.range,
      clue: template.localizedClue?.getClue(languageCode) ?? template.specificClue,
      difficulty: template.difficulty,
      date: date,
      bundleId: categoryInfo.bundleId,
      leftLabel: categoryInfo.getLeftText(languageCode),
      rightLabel: categoryInfo.getRightText(languageCode),
    );
  }

  /// Create localized version of server challenge
  static DailyChallenge _createLocalizedChallenge(DailyChallenge serverChallenge, String languageCode) {
    // Get category info for localized labels
    final categoryInfo = allCategories.firstWhere(
      (cat) => cat.id == serverChallenge.categoryId,
      orElse: () => allCategories.first,
    );

    // Try to get localized clue from campaign data if available
    final template = DailyChallengeDatabase.getChallengeForDay(serverChallenge.date);
    final localizedClue = template.localizedClue?.getClue(languageCode) ?? serverChallenge.clue;

    return DailyChallenge(
      id: serverChallenge.id,
      categoryId: serverChallenge.categoryId,
      secretPosition: serverChallenge.secretPosition,
      range: serverChallenge.range,
      clue: localizedClue,
      difficulty: serverChallenge.difficulty,
      date: serverChallenge.date,
      bundleId: serverChallenge.bundleId,
      leftLabel: categoryInfo.getLeftText(languageCode),
      rightLabel: categoryInfo.getRightText(languageCode),
    );
  }

  /// Submit daily challenge result
  static Future<DailyResult> submitDailyResult({
    required DailyChallenge challenge,
    required double userGuess,
    required Duration timeSpent,
    BuildContext? context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to submit daily results');
    }

    // Calculate score and accuracy
    final score = _calculateScore(userGuess, challenge.secretPosition);
    final accuracy = _calculateAccuracy(userGuess, challenge.secretPosition);

    final result = DailyResult(
      challengeId: challenge.id,
      userId: user.uid,
      userGuess: userGuess,
      score: score,
      accuracy: accuracy,
      submittedAt: DateTime.now(),
      timeSpent: timeSpent,
      categoryId: challenge.categoryId,
    );

    try {
      print('Submitting daily result for ${challenge.id}, user: ${user.uid}, score: $score');
      
      // Store result in leaderboard collection (for global rankings)
      await _db
          .collection('daily_leaderboard')
          .doc(challenge.id)
          .collection('scores')
          .doc(user.uid)
          .set(result.toFirestore());
      
      print('Successfully saved to leaderboard: daily_leaderboard/${challenge.id}/scores/${user.uid}');

      // Store result in user's personal collection (for statistics)
      await _db
          .collection('daily_results')
          .doc(user.uid)
          .collection('results')
          .doc(challenge.id)
          .set(result.toFirestore());

      // Update user's daily statistics
      await _updateDailyStats(user.uid, result);

      // Award Mind Gems for daily challenge completion
      await WalletService.awardGems(50, 'daily_completion', 
        context: context,
        metadata: {
          'challengeId': challenge.id,
          'score': result.score,
          'accuracy': result.accuracy,
        });

      // Check and award daily bonus if this is the first game today
      final dailyBonusAwarded = await WalletService.claimDailyBonus(context: context);
      if (dailyBonusAwarded) {
        print('Daily bonus awarded: 250 Gems');
      }

      // Track quest progress
      await QuestService.trackProgress('complete_daily_challenge', 
        amount: 1,
        context: context,
        metadata: {
          'challengeId': challenge.id,
          'score': result.score,
          'accuracy': result.accuracy,
          'categoryId': challenge.categoryId,
        });

      // Track perfect score achievement
      if (result.accuracy >= 1.0) {
        await QuestService.trackProgress('perfect_score', 
          amount: 1,
          context: context,
          metadata: {
            'challengeId': challenge.id,
            'mode': 'daily_challenge',
            'accuracy': result.accuracy,
          });
      }

      // Track accuracy-based quests
      await QuestService.trackProgress('achieve_accuracy', 
        amount: 1,
        context: context,
        metadata: {
          'accuracy': result.accuracy,
          'mode': 'daily_challenge',
        });

      // Track daily challenge streak
      await _trackDailyChallengeStreak(context);

      // Track general game completion
      await QuestService.trackProgress('complete_any_game', 
        amount: 1,
        context: context,
        metadata: {
          'mode': 'daily_challenge',
          'score': result.score,
        });

      return result;
    } catch (e) {
      print('Error submitting daily result: $e');
      rethrow;
    }
  }

  /// Check if user has already played today
  static Future<bool> hasPlayedToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final today = _formatDate(DateTime.now());
    
    try {
      final doc = await _db
          .collection('daily_results')
          .doc(user.uid)
          .collection('results')
          .doc(today)
          .get();
      
      return doc.exists;
    } catch (e) {
      print('Error checking daily play status: $e');
      return false;
    }
  }

  /// Get today's result if user has played
  static Future<DailyResult?> getTodaysResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final today = _formatDate(DateTime.now());
    
    try {
      final doc = await _db
          .collection('daily_results')
          .doc(user.uid)
          .collection('results')
          .doc(today)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return DailyResult.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching today\'s result: $e');
      return null;
    }
  }

  /// Get today's leaderboard (top 50 players)
  static Future<List<DailyLeaderboardEntry>> getTodaysLeaderboard() async {
    final today = _formatDate(DateTime.now());
    print('Fetching leaderboard for: $today');
    
    try {
      final querySnapshot = await _db
          .collection('daily_leaderboard')
          .doc(today)
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(50)
          .get();
      
      print('Found ${querySnapshot.docs.length} scores in leaderboard');

      final entries = <DailyLeaderboardEntry>[];
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final data = doc.data();
        
        // Get user profile for display name and avatar
        final userDoc = await _db.collection('users').doc(doc.id).get();
        final userData = userDoc.data() ?? {};
        
        // Check for custom username first
        String displayName = 'Anonymous';
        try {
          final customUsernameQuery = await _db
              .collection('custom_usernames')
              .where('userId', isEqualTo: doc.id)
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();
          
          if (customUsernameQuery.docs.isNotEmpty) {
            displayName = customUsernameQuery.docs.first.data()['username'] ?? 'Anonymous';
          } else {
            displayName = userData['displayName'] ?? 'Anonymous';
          }
        } catch (e) {
          displayName = userData['displayName'] ?? 'Anonymous';
        }
        
        final entry = DailyLeaderboardEntry(
          userId: doc.id,
          displayName: displayName,
          avatarId: userData['avatarId'] ?? 'bear',
          score: data['score'] ?? 0,
          accuracy: data['accuracy']?.toDouble() ?? 0.0,
          timeSpent: Duration(seconds: data['timeSpentSeconds'] ?? 0),
          submittedAt: data['submittedAt']?.toDate() ?? DateTime.now(),
          rank: 0, // Will be set after sorting
        );
        
        entries.add(entry);
      }
      
      // Sort entries: first by score (desc), then by accuracy (desc), then by submission time (asc)
      entries.sort((a, b) {
        // First compare by score (higher is better)
        int scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) return scoreComparison;
        
        // If scores are equal, compare by accuracy (higher is better)
        int accuracyComparison = b.accuracy.compareTo(a.accuracy);
        if (accuracyComparison != 0) return accuracyComparison;
        
        // If accuracy is equal, compare by submission time (earlier is better)
        return a.submittedAt.compareTo(b.submittedAt);
      });
      
      // Assign ranks after sorting
      for (int i = 0; i < entries.length; i++) {
        entries[i] = DailyLeaderboardEntry(
          userId: entries[i].userId,
          displayName: entries[i].displayName,
          avatarId: entries[i].avatarId,
          score: entries[i].score,
          accuracy: entries[i].accuracy,
          timeSpent: entries[i].timeSpent,
          submittedAt: entries[i].submittedAt,
          rank: i + 1,
        );
      }
      
      return entries;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  /// Get user's daily statistics
  static Future<DailyStats> getUserDailyStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return DailyStats.empty();

    try {
      final doc = await _db
          .collection('daily_stats')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return DailyStats.fromFirestore(doc);
      }
      return DailyStats.empty();
    } catch (e) {
      print('Error fetching daily stats: $e');
      return DailyStats.empty();
    }
  }

  /// Update user's daily statistics
  static Future<void> _updateDailyStats(String userId, DailyResult result) async {
    final docRef = _db.collection('daily_stats').doc(userId);
    
    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      
      DailyStats currentStats;
      if (doc.exists && doc.data() != null) {
        currentStats = DailyStats.fromFirestore(doc);
      } else {
        currentStats = DailyStats.empty();
      }

      // Check if this is a new day (for streak calculation)
      final today = DateTime.now();
      final lastPlayed = currentStats.lastPlayedDate;
      final daysDifference = today.difference(lastPlayed).inDays;
      
      int newCurrentStreak;
      if (daysDifference == 1) {
        // Consecutive day - continue streak
        newCurrentStreak = currentStats.currentStreak + 1;
      } else if (daysDifference == 0) {
        // Same day - maintain streak (shouldn't happen with proper checks)
        newCurrentStreak = currentStats.currentStreak;
      } else {
        // Gap in days - reset streak
        newCurrentStreak = 1;
      }

      // Calculate new statistics
      final newTotalDays = currentStats.totalDaysPlayed + 1;
      final newPerfectDays = currentStats.perfectDays + (result.score == 5 ? 1 : 0);
      final newAverageScore = ((currentStats.averageScore * currentStats.totalDaysPlayed) + result.score) / newTotalDays;
      final newAverageAccuracy = ((currentStats.averageAccuracy * currentStats.totalDaysPlayed) + result.accuracy) / newTotalDays;
      final newBestScore = max(currentStats.bestScore, result.score);
      final newBestStreak = max(currentStats.bestStreak, newCurrentStreak);
      
      // Update difficulty stats
      final newDifficultyStats = Map<String, int>.from(currentStats.difficultyStats);
      final template = DailyChallengeDatabase.getChallengeById(result.challengeId);
      if (template != null) {
        newDifficultyStats[template.difficulty] = (newDifficultyStats[template.difficulty] ?? 0) + 1;
      }

      // Create updated stats
      final updatedStats = DailyStats(
        totalDaysPlayed: newTotalDays,
        currentStreak: newCurrentStreak,
        bestStreak: newBestStreak,
        perfectDays: newPerfectDays,
        averageScore: newAverageScore,
        averageAccuracy: newAverageAccuracy,
        bestScore: newBestScore,
        bestRank: currentStats.bestRank, // Will be updated by leaderboard ranking
        lastPlayedDate: today,
        difficultyStats: newDifficultyStats,
      );

      transaction.set(docRef, updatedStats.toFirestore());
    });
  }

  /// Calculate score (reuse existing logic)
  static int _calculateScore(double userGuess, double secretPosition) {
    final difference = (userGuess - secretPosition).abs();
    final accuracy = 1.0 - difference;
    
    if (accuracy >= 0.95) return 5; // Perfect
    if (accuracy >= 0.80) return 4; // Excellent
    if (accuracy >= 0.60) return 3; // Good
    if (accuracy >= 0.40) return 2; // Fair
    if (accuracy >= 0.20) return 1; // Poor
    return 0; // Very poor
  }

  /// Calculate accuracy
  static double _calculateAccuracy(double userGuess, double secretPosition) {
    final difference = (userGuess - secretPosition).abs();
    return (1.0 - difference).clamp(0.0, 1.0);
  }

  /// Format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get user's rank in today's leaderboard
  static Future<int?> getUserRankToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final leaderboard = await getTodaysLeaderboard();
      final userEntry = leaderboard.where((entry) => entry.userId == user.uid).firstOrNull;
      return userEntry?.rank;
    } catch (e) {
      print('Error fetching user rank: $e');
      return null;
    }
  }

  /// Track daily challenge streak for quest progress
  static Future<void> _trackDailyChallengeStreak(BuildContext? context) async {
    try {
      final stats = await getUserDailyStats();
      await QuestService.trackProgress('daily_challenge_streak', 
        amount: stats.currentStreak,
        context: context,
        metadata: {
          'currentStreak': stats.currentStreak,
          'longestStreak': stats.bestStreak,
        });
    } catch (e) {
      print('Error tracking daily challenge streak: $e');
    }
  }
}
