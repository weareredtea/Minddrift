// lib/services/analytics_service.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analytics_data.dart';

/// Service for handling analytics data and Firebase Analytics events
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize analytics with user properties
  static Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _analytics.setUserId(id: user.uid);
      await _analytics.setUserProperty(
        name: 'user_type',
        value: user.isAnonymous ? 'anonymous' : 'registered',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // EVENT TRACKING METHODS
  // ═══════════════════════════════════════════════════════════

  /// Track screen views
  static Future<void> trackScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  /// Track game mode selection
  static Future<void> trackGameModeSelected(String gameMode) async {
    await _analytics.logEvent(
      name: 'game_mode_selected',
      parameters: {
        'game_mode': gameMode,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track game completion
  static Future<void> trackGameCompleted(String gameMode, int score, double accuracy) async {
    await _analytics.logEvent(
      name: 'game_completed',
      parameters: {
        'game_mode': gameMode,
        'score': score,
        'accuracy': (accuracy * 100).round(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track gem transactions
  static Future<void> trackGemTransaction(String type, int amount, String reason) async {
    await _analytics.logEvent(
      name: 'gem_transaction',
      parameters: {
        'transaction_type': type,
        'amount': amount,
        'reason': reason,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Track feature usage
  static Future<void> trackFeatureUsed(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {
        'feature_name': featureName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DATA FETCHING METHODS FOR DASHBOARD
  // ═══════════════════════════════════════════════════════════

  /// Get user overview statistics
  static Future<UserOverviewData> getUserOverview() async {
    try {
      // Get total users
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      // Get active users (last 24 hours)
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final activeUsersSnapshot = await _firestore
          .collection('users')
          .where('lastSeen', isGreaterThanOrEqualTo: yesterday)
          .get();
      final activeToday = activeUsersSnapshot.docs.length;

      // Get active users (last 7 days)
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final weeklyUsersSnapshot = await _firestore
          .collection('users')
          .where('lastSeen', isGreaterThanOrEqualTo: lastWeek)
          .get();
      final activeThisWeek = weeklyUsersSnapshot.docs.length;

      // Get new users (last 7 days)
      final newUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: lastWeek)
          .get();
      final newUsers = newUsersSnapshot.docs.length;

      return UserOverviewData(
        totalUsers: totalUsers,
        activeToday: activeToday,
        activeThisWeek: activeThisWeek,
        newUsers: newUsers,
        retentionRate: totalUsers > 0 ? (activeThisWeek / totalUsers) : 0.0,
      );
    } catch (e) {
      return UserOverviewData.empty();
    }
  }

  /// Get gameplay statistics
  static Future<GameplayStatsData> getGameplayStats() async {
    try {
      // Get practice stats
      final practiceStatsSnapshot = await _firestore.collection('practice_stats').get();
      int totalPracticeGames = 0;
      double totalPracticeScore = 0;
      int perfectPracticeScores = 0;

      for (final doc in practiceStatsSnapshot.docs) {
        final data = doc.data();
        final challenges = data['totalChallenges'] as int? ?? 0;
        final perfect = data['perfectScores'] as int? ?? 0;
        final avgScore = data['averageScore'] as double? ?? 0;
        
        totalPracticeGames += challenges;
        perfectPracticeScores += perfect;
        totalPracticeScore += avgScore * challenges;
      }

      // Get daily challenge stats
      final dailyStatsSnapshot = await _firestore.collection('daily_stats').get();
      int totalDailyGames = 0;
      int perfectDailyScores = 0;

      for (final doc in dailyStatsSnapshot.docs) {
        final data = doc.data();
        final daysPlayed = data['totalDaysPlayed'] as int? ?? 0;
        final perfect = data['perfectDays'] as int? ?? 0;
        
        totalDailyGames += daysPlayed;
        perfectDailyScores += perfect;
      }

      final totalGames = totalPracticeGames + totalDailyGames;
      final averageScore = totalGames > 0 ? totalPracticeScore / totalPracticeGames : 0.0;
      final perfectRate = totalGames > 0 ? (perfectPracticeScores + perfectDailyScores) / totalGames : 0.0;

      return GameplayStatsData(
        totalGames: totalGames,
        averageScore: averageScore,
        perfectScoreRate: perfectRate,
        practiceGames: totalPracticeGames,
        dailyChallengeGames: totalDailyGames,
      );
    } catch (e) {
      return GameplayStatsData.empty();
    }
  }

  /// Get economic data
  static Future<EconomicData> getEconomicData() async {
    try {
      final walletsSnapshot = await _firestore.collection('player_wallets').get();
      
      int totalGemsEarned = 0;
      int totalGemsSpent = 0;
      int totalWallets = walletsSnapshot.docs.length;
      int usersWithPurchases = 0;

      for (final doc in walletsSnapshot.docs) {
        final data = doc.data();
        final earned = data['totalGemsEarned'] as int? ?? 0;
        final spent = data['totalGemsSpent'] as int? ?? 0;
        
        totalGemsEarned += earned;
        totalGemsSpent += spent;
        
        if (spent > 0) usersWithPurchases++;
      }

      final conversionRate = totalWallets > 0 ? usersWithPurchases / totalWallets : 0.0;
      final averageWallet = totalWallets > 0 ? (totalGemsEarned - totalGemsSpent) / totalWallets : 0;

      return EconomicData(
        totalGemsEarned: totalGemsEarned,
        totalGemsSpent: totalGemsSpent,
        averageWallet: averageWallet.round(),
        conversionRate: conversionRate,
        activeSpenders: usersWithPurchases,
      );
    } catch (e) {
      return EconomicData.empty();
    }
  }

  /// Get engagement metrics
  static Future<EngagementData> getEngagementData() async {
    try {
      // Get quest stats
      final questStatsSnapshot = await _firestore.collection('quest_stats').get();
      int totalQuestsCompleted = 0;
      
      for (final doc in questStatsSnapshot.docs) {
        final data = doc.data();
        totalQuestsCompleted += data['totalQuestsCompleted'] as int? ?? 0;
      }

      // Get campaign progress
      final campaignSnapshot = await _firestore.collection('campaign_progress').get();
      int totalStars = 0;
      double averageProgress = 0;
      
      for (final doc in campaignSnapshot.docs) {
        final data = doc.data();
        totalStars += data['totalStars'] as int? ?? 0;
        averageProgress += data['completedLevels'] as int? ?? 0;
      }
      
      averageProgress = campaignSnapshot.docs.isNotEmpty ? averageProgress / campaignSnapshot.docs.length : 0;

      // Get daily streaks
      final dailyStatsSnapshot = await _firestore.collection('daily_stats').get();
      double averageStreak = 0;
      int maxStreak = 0;
      
      for (final doc in dailyStatsSnapshot.docs) {
        final data = doc.data();
        final currentStreak = data['currentStreak'] as int? ?? 0;
        final bestStreak = data['bestStreak'] as int? ?? 0;
        
        averageStreak += currentStreak;
        if (bestStreak > maxStreak) maxStreak = bestStreak;
      }
      
      averageStreak = dailyStatsSnapshot.docs.isNotEmpty ? averageStreak / dailyStatsSnapshot.docs.length : 0;

      return EngagementData(
        totalQuestsCompleted: totalQuestsCompleted,
        totalCampaignStars: totalStars,
        averageCampaignProgress: averageProgress.round(),
        averageDailyStreak: averageStreak,
        maxDailyStreak: maxStreak,
      );
    } catch (e) {
      return EngagementData.empty();
    }
  }

  /// Get top users by different metrics
  static Future<List<TopUserData>> getTopUsersByScore() async {
    try {
      final dailyStatsSnapshot = await _firestore
          .collection('daily_stats')
          .orderBy('averageScore', descending: true)
          .limit(10)
          .get();

      final topUsers = <TopUserData>[];
      
      for (final doc in dailyStatsSnapshot.docs) {
        final data = doc.data();
        final userId = doc.id;
        
        // Get user display name
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData = userDoc.data();
        final displayName = userData?['displayName'] as String? ?? 'Anonymous';
        
        topUsers.add(TopUserData(
          userId: userId,
          displayName: displayName,
          value: data['averageScore'] as double? ?? 0.0,
          metric: 'Average Score',
        ));
      }
      
      return topUsers;
    } catch (e) {
      return [];
    }
  }

  /// Export all analytics data to Map for CSV/JSON export
  static Future<Map<String, dynamic>> exportAllData() async {
    try {
      final overview = await getUserOverview();
      final gameplay = await getGameplayStats();
      final economic = await getEconomicData();
      final engagement = await getEngagementData();
      final topUsers = await getTopUsersByScore();

      return {
        'exportedAt': DateTime.now().toIso8601String(),
        'userOverview': overview.toMap(),
        'gameplayStats': gameplay.toMap(),
        'economicData': economic.toMap(),
        'engagementData': engagement.toMap(),
        'topUsers': topUsers.map((user) => user.toMap()).toList(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    }
  }
}
