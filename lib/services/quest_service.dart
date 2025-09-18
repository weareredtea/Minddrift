// lib/services/quest_service.dart

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/quest_models.dart';
import '../data/quest_catalog.dart';
import '../services/wallet_service.dart';

class QuestService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get user's current quest progress
  static Future<List<QuestProgress>> getUserQuestProgress() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _db
          .collection('quest_progress')
          .doc(user.uid)
          .collection('active_quests')
          .get();

      return querySnapshot.docs
          .map((doc) => QuestProgress.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching quest progress: $e');
      return [];
    }
  }

  /// Get user's quest statistics
  static Future<QuestStats> getUserQuestStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      return QuestStats(
        userId: '',
        lastDailyQuestDate: DateTime(2000),
        lastWeeklyQuestDate: DateTime(2000),
        lastUpdated: DateTime.now(),
      );
    }

    try {
      final doc = await _db
          .collection('quest_stats')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return QuestStats.fromFirestore(doc);
      } else {
        // Create initial stats
        final initialStats = QuestStats(
          userId: user.uid,
          lastDailyQuestDate: DateTime(2000),
          lastWeeklyQuestDate: DateTime(2000),
          lastUpdated: DateTime.now(),
        );
        
        await _db
            .collection('quest_stats')
            .doc(user.uid)
            .set(initialStats.toFirestore());
        
        return initialStats;
      }
    } catch (e) {
      print('Error fetching quest stats: $e');
      return QuestStats(
        userId: user.uid,
        lastDailyQuestDate: DateTime(2000),
        lastWeeklyQuestDate: DateTime(2000),
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Initialize or refresh daily quests for user
  static Future<void> refreshDailyQuests() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final stats = await getUserQuestStats();
      final today = DateTime.now();
      
      // Check if daily quests need refresh (new day)
      if (stats.lastDailyQuestDate.day != today.day ||
          stats.lastDailyQuestDate.month != today.month ||
          stats.lastDailyQuestDate.year != today.year) {
        
        print('Refreshing daily quests for user: ${user.uid}');
        
        // Clear old daily quests
        await _clearQuestsByType(QuestType.daily);
        
        // Generate new daily quests
        final dailyQuests = QuestCatalog.getDailyQuestPool(count: 3);
        
        // Create quest progress for each daily quest
        for (final quest in dailyQuests) {
          await _createQuestProgress(quest);
        }
        
        // Update last daily quest date
        await _updateQuestStats(stats.copyWith(
          lastDailyQuestDate: today,
        ));
        
        print('Created ${dailyQuests.length} new daily quests');
      }
    } catch (e) {
      print('Error refreshing daily quests: $e');
    }
  }

  /// Initialize or refresh weekly quests for user
  static Future<void> refreshWeeklyQuests() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final stats = await getUserQuestStats();
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final lastWeekStart = stats.lastWeeklyQuestDate.subtract(
          Duration(days: stats.lastWeeklyQuestDate.weekday - 1));
      
      // Check if weekly quests need refresh (new week)
      if (weekStart.isAfter(lastWeekStart)) {
        print('Refreshing weekly quests for user: ${user.uid}');
        
        // Clear old weekly quests
        await _clearQuestsByType(QuestType.weekly);
        
        // Generate new weekly quests
        final weeklyQuests = QuestCatalog.getWeeklyQuestPool(count: 2);
        
        // Create quest progress for each weekly quest
        for (final quest in weeklyQuests) {
          await _createQuestProgress(quest);
        }
        
        // Update last weekly quest date
        await _updateQuestStats(stats.copyWith(
          lastWeeklyQuestDate: now,
        ));
        
        print('Created ${weeklyQuests.length} new weekly quests');
      }
    } catch (e) {
      print('Error refreshing weekly quests: $e');
    }
  }

  /// Initialize achievement quests for new users
  static Future<void> initializeAchievementQuests() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Check if achievement quests are already initialized
      final existingProgress = await getUserQuestProgress();
      final hasAchievements = existingProgress.any(
          (progress) => QuestCatalog.getQuestById(progress.questId)?.type == QuestType.achievement);
      
      if (!hasAchievements) {
        print('Initializing achievement quests for user: ${user.uid}');
        
        // Get all available achievement quests
        final achievementQuests = QuestCatalog.getAvailableAchievements();
        
        // Create quest progress for each achievement quest
        for (final quest in achievementQuests) {
          await _createQuestProgress(quest);
        }
        
        print('Initialized ${achievementQuests.length} achievement quests');
      }
    } catch (e) {
      print('Error initializing achievement quests: $e');
    }
  }

  /// Track progress for a specific action
  static Future<void> trackProgress(String action, {
    int amount = 1,
    Map<String, dynamic>? metadata,
    BuildContext? context,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      print('Tracking progress for action: $action (amount: $amount)');
      
      // Get all active quest progress
      final progressList = await getUserQuestProgress();
      
      // Track progress for each matching quest
      for (final progress in progressList) {
        final quest = QuestCatalog.getQuestById(progress.questId);
        if (quest == null || progress.isCompleted) continue;
        
        // Check if this action matches the quest target
        if (quest.targetAction == action) {
          // Check metadata conditions if specified
          if (!_checkMetadataConditions(quest, metadata)) continue;
          
          // Update progress
          final newProgress = math.min(
              progress.currentProgress + amount,
              quest.targetCount);
          
          final updatedProgress = progress.copyWith(
            currentProgress: newProgress,
            isCompleted: newProgress >= quest.targetCount,
            completedAt: newProgress >= quest.targetCount ? DateTime.now() : null,
            progressData: {...progress.progressData, ...?metadata},
          );
          
          // Save updated progress
          await _saveQuestProgress(updatedProgress);
          
          // Check if quest is completed
          if (updatedProgress.isCompleted && !progress.isCompleted) {
            print('Quest completed: ${quest.title}');
            
            // Show completion notification (optional)
            if (context != null && context.mounted) {
              _showQuestCompletionNotification(context, quest);
            }
          }
        }
      }
    } catch (e) {
      print('Error tracking quest progress: $e');
    }
  }

  /// Claim quest rewards
  static Future<bool> claimQuestReward(String questId, {BuildContext? context}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Get quest progress
      final progressDoc = await _db
          .collection('quest_progress')
          .doc(user.uid)
          .collection('active_quests')
          .doc(questId)
          .get();

      if (!progressDoc.exists) return false;
      
      final progress = QuestProgress.fromFirestore(progressDoc);
      final quest = QuestCatalog.getQuestById(questId);
      
      if (quest == null || !progress.canClaimReward) return false;

      print('Claiming rewards for quest: ${quest.title}');

      // Award rewards
      int totalGems = 0;
      for (final reward in quest.rewards) {
        switch (reward.type) {
          case 'gems':
            totalGems += reward.amount;
            break;
          case 'xp':
            // Award XP (implement XP system later)
            print('Awarded ${reward.amount} XP');
            break;
          case 'badge':
            // Award badge (integrate with cosmetic system)
            if (reward.itemId != null) {
              print('Awarded badge: ${reward.itemId}');
              // TODO: Add badge to player's collection
            }
            break;
          case 'item':
            // Award cosmetic item
            if (reward.itemId != null) {
              print('Awarded item: ${reward.itemId}');
              // TODO: Add item to player's collection
            }
            break;
        }
      }

      // Award gems if any
      if (totalGems > 0) {
        await WalletService.awardGems(totalGems, 'quest_completion',
            context: context,
            metadata: {
              'questId': questId,
              'questTitle': quest.title,
              'questType': quest.type.toString(),
            });
      }

      // Mark reward as claimed
      final updatedProgress = progress.copyWith(
        isRewardClaimed: true,
        claimedAt: DateTime.now(),
      );
      
      await _saveQuestProgress(updatedProgress);

      // Update quest stats
      await _updateQuestStatsOnCompletion(quest);

      print('Successfully claimed rewards for quest: ${quest.title}');
      return true;
    } catch (e) {
      print('Error claiming quest reward: $e');
      return false;
    }
  }

  /// Get quests organized by type for UI display
  static Future<Map<QuestType, List<QuestWithProgress>>> getOrganizedQuests() async {
    final progressList = await getUserQuestProgress();
    final Map<QuestType, List<QuestWithProgress>> organized = {};

    for (final progress in progressList) {
      final quest = QuestCatalog.getQuestById(progress.questId);
      if (quest == null || !quest.isAvailable) continue;

      organized[quest.type] ??= [];
      organized[quest.type]!.add(QuestWithProgress(quest: quest, progress: progress));
    }

    return organized;
  }

  /// Private helper methods

  static Future<void> _createQuestProgress(Quest quest) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final progress = QuestProgress(
      questId: quest.id,
      userId: user.uid,
      currentProgress: 0,
      targetProgress: quest.targetCount,
      startedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    await _db
        .collection('quest_progress')
        .doc(user.uid)
        .collection('active_quests')
        .doc(quest.id)
        .set(progress.toFirestore());
  }

  static Future<void> _saveQuestProgress(QuestProgress progress) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('quest_progress')
        .doc(user.uid)
        .collection('active_quests')
        .doc(progress.questId)
        .set(progress.toFirestore());
  }

  static Future<void> _clearQuestsByType(QuestType type) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final progressList = await getUserQuestProgress();
    
    for (final progress in progressList) {
      final quest = QuestCatalog.getQuestById(progress.questId);
      if (quest?.type == type) {
        await _db
            .collection('quest_progress')
            .doc(user.uid)
            .collection('active_quests')
            .doc(progress.questId)
            .delete();
      }
    }
  }

  static Future<void> _updateQuestStats(QuestStats stats) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('quest_stats')
        .doc(user.uid)
        .set(stats.toFirestore());
  }

  static Future<void> _updateQuestStatsOnCompletion(Quest quest) async {
    final stats = await getUserQuestStats();
    
    QuestStats updatedStats;
    switch (quest.type) {
      case QuestType.daily:
        updatedStats = stats.copyWith(
          totalQuestsCompleted: stats.totalQuestsCompleted + 1,
          dailyQuestsCompleted: stats.dailyQuestsCompleted + 1,
        );
        break;
      case QuestType.weekly:
        updatedStats = stats.copyWith(
          totalQuestsCompleted: stats.totalQuestsCompleted + 1,
          weeklyQuestsCompleted: stats.weeklyQuestsCompleted + 1,
        );
        break;
      case QuestType.achievement:
        updatedStats = stats.copyWith(
          totalQuestsCompleted: stats.totalQuestsCompleted + 1,
          achievementQuestsCompleted: stats.achievementQuestsCompleted + 1,
        );
        break;
      case QuestType.special:
        updatedStats = stats.copyWith(
          totalQuestsCompleted: stats.totalQuestsCompleted + 1,
        );
        break;
    }
    
    await _updateQuestStats(updatedStats);
  }

  static bool _checkMetadataConditions(Quest quest, Map<String, dynamic>? metadata) {
    if (quest.metadata.isEmpty || metadata == null) return true;
    
    // Check minimum accuracy condition
    if (quest.metadata.containsKey('minAccuracy')) {
      final requiredAccuracy = quest.metadata['minAccuracy'] as int;
      final actualAccuracy = metadata['accuracy'] as double? ?? 0.0;
      return (actualAccuracy * 100) >= requiredAccuracy;
    }
    
    // Check section number condition
    if (quest.metadata.containsKey('sectionNumber')) {
      final requiredSection = quest.metadata['sectionNumber'] as int;
      final actualSection = metadata['sectionNumber'] as int? ?? 0;
      return actualSection == requiredSection;
    }
    
    return true;
  }

  static void _showQuestCompletionNotification(BuildContext context, Quest quest) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Quest Completed: ${quest.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.withAlpha(200),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Helper class to combine quest and progress data
class QuestWithProgress {
  final Quest quest;
  final QuestProgress progress;

  const QuestWithProgress({
    required this.quest,
    required this.progress,
  });
}

/// Extension to add copyWith method to QuestStats
extension QuestStatsExtension on QuestStats {
  QuestStats copyWith({
    int? totalQuestsCompleted,
    int? dailyQuestsCompleted,
    int? weeklyQuestsCompleted,
    int? achievementQuestsCompleted,
    int? currentDailyStreak,
    int? longestDailyStreak,
    int? currentWeeklyStreak,
    int? longestWeeklyStreak,
    DateTime? lastDailyQuestDate,
    DateTime? lastWeeklyQuestDate,
    Map<String, int>? categoryProgress,
  }) {
    return QuestStats(
      userId: userId,
      totalQuestsCompleted: totalQuestsCompleted ?? this.totalQuestsCompleted,
      dailyQuestsCompleted: dailyQuestsCompleted ?? this.dailyQuestsCompleted,
      weeklyQuestsCompleted: weeklyQuestsCompleted ?? this.weeklyQuestsCompleted,
      achievementQuestsCompleted: achievementQuestsCompleted ?? this.achievementQuestsCompleted,
      currentDailyStreak: currentDailyStreak ?? this.currentDailyStreak,
      longestDailyStreak: longestDailyStreak ?? this.longestDailyStreak,
      currentWeeklyStreak: currentWeeklyStreak ?? this.currentWeeklyStreak,
      longestWeeklyStreak: longestWeeklyStreak ?? this.longestWeeklyStreak,
      lastDailyQuestDate: lastDailyQuestDate ?? this.lastDailyQuestDate,
      lastWeeklyQuestDate: lastWeeklyQuestDate ?? this.lastWeeklyQuestDate,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      lastUpdated: DateTime.now(),
    );
  }
}
