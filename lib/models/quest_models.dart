// lib/models/quest_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of quests available
enum QuestType {
  daily,
  weekly,
  achievement,
  special,
}

/// Quest difficulty levels
enum QuestDifficulty {
  easy,
  medium,
  hard,
  legendary,
}

/// Quest categories for organization
enum QuestCategory {
  gameplay,
  social,
  progression,
  collection,
  mastery,
}

/// Represents a quest template/definition
class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final QuestCategory category;
  final String targetAction; // e.g., 'complete_practice', 'earn_gems', 'win_streak'
  final int targetCount; // How many times the action needs to be performed
  final List<QuestReward> rewards;
  final Duration? timeLimit; // For timed quests
  final Map<String, dynamic> metadata; // Additional quest-specific data
  final bool isActive;
  final DateTime? startDate; // For special/event quests
  final DateTime? endDate; // For special/event quests

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.category,
    required this.targetAction,
    required this.targetCount,
    required this.rewards,
    this.timeLimit,
    this.metadata = const {},
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  factory Quest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quest(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: QuestType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => QuestType.daily,
      ),
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.toString() == data['difficulty'],
        orElse: () => QuestDifficulty.easy,
      ),
      category: QuestCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => QuestCategory.gameplay,
      ),
      targetAction: data['targetAction'] ?? '',
      targetCount: data['targetCount'] ?? 1,
      rewards: (data['rewards'] as List<dynamic>? ?? [])
          .map((reward) => QuestReward.fromMap(reward as Map<String, dynamic>))
          .toList(),
      timeLimit: data['timeLimit'] != null
          ? Duration(seconds: data['timeLimit'])
          : null,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      isActive: data['isActive'] ?? true,
      startDate: data['startDate']?.toDate(),
      endDate: data['endDate']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.toString(),
      'difficulty': difficulty.toString(),
      'category': category.toString(),
      'targetAction': targetAction,
      'targetCount': targetCount,
      'rewards': rewards.map((reward) => reward.toMap()).toList(),
      'timeLimit': timeLimit?.inSeconds,
      'metadata': metadata,
      'isActive': isActive,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Get difficulty display name
  String get difficultyDisplayName {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 'Easy';
      case QuestDifficulty.medium:
        return 'Medium';
      case QuestDifficulty.hard:
        return 'Hard';
      case QuestDifficulty.legendary:
        return 'Legendary';
    }
  }

  /// Get difficulty color for UI
  String get difficultyColor {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return '#4CAF50'; // Green
      case QuestDifficulty.medium:
        return '#FF9800'; // Orange
      case QuestDifficulty.hard:
        return '#F44336'; // Red
      case QuestDifficulty.legendary:
        return '#9C27B0'; // Purple
    }
  }

  /// Check if quest is currently available
  bool get isAvailable {
    if (!isActive) return false;
    
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    
    return true;
  }
}

/// Represents a quest reward
class QuestReward {
  final String type; // 'gems', 'xp', 'badge', 'item'
  final int amount;
  final String? itemId; // For specific items/badges
  final Map<String, dynamic> metadata;

  const QuestReward({
    required this.type,
    required this.amount,
    this.itemId,
    this.metadata = const {},
  });

  factory QuestReward.fromMap(Map<String, dynamic> map) {
    return QuestReward(
      type: map['type'] ?? 'gems',
      amount: map['amount'] ?? 0,
      itemId: map['itemId'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'itemId': itemId,
      'metadata': metadata,
    };
  }

  /// Get reward display text
  String get displayText {
    switch (type) {
      case 'gems':
        return '$amount Mind Gems';
      case 'xp':
        return '$amount XP';
      case 'badge':
        return 'Special Badge';
      case 'item':
        return 'Cosmetic Item';
      default:
        return '$amount $type';
    }
  }

  /// Get reward icon
  String get iconName {
    switch (type) {
      case 'gems':
        return 'diamond';
      case 'xp':
        return 'star';
      case 'badge':
        return 'military_tech';
      case 'item':
        return 'palette';
      default:
        return 'card_giftcard';
    }
  }
}

/// Represents a player's progress on a quest
class QuestProgress {
  final String questId;
  final String userId;
  final int currentProgress;
  final int targetProgress;
  final bool isCompleted;
  final bool isRewardClaimed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final DateTime lastUpdated;
  final Map<String, dynamic> progressData; // Additional tracking data

  const QuestProgress({
    required this.questId,
    required this.userId,
    required this.currentProgress,
    required this.targetProgress,
    this.isCompleted = false,
    this.isRewardClaimed = false,
    required this.startedAt,
    this.completedAt,
    this.claimedAt,
    required this.lastUpdated,
    this.progressData = const {},
  });

  factory QuestProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestProgress(
      questId: data['questId'] ?? doc.id.split('_')[0],
      userId: data['userId'] ?? '',
      currentProgress: data['currentProgress'] ?? 0,
      targetProgress: data['targetProgress'] ?? 1,
      isCompleted: data['isCompleted'] ?? false,
      isRewardClaimed: data['isRewardClaimed'] ?? false,
      startedAt: data['startedAt']?.toDate() ?? DateTime.now(),
      completedAt: data['completedAt']?.toDate(),
      claimedAt: data['claimedAt']?.toDate(),
      lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
      progressData: Map<String, dynamic>.from(data['progressData'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'questId': questId,
      'userId': userId,
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
      'isCompleted': isCompleted,
      'isRewardClaimed': isRewardClaimed,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'claimedAt': claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'progressData': progressData,
    };
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetProgress == 0) return 0.0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  /// Get progress display text
  String get progressText {
    return '$currentProgress / $targetProgress';
  }

  /// Check if quest can be completed
  bool get canComplete {
    return currentProgress >= targetProgress && !isCompleted;
  }

  /// Check if reward can be claimed
  bool get canClaimReward {
    return isCompleted && !isRewardClaimed;
  }

  /// Create updated progress
  QuestProgress copyWith({
    int? currentProgress,
    int? targetProgress,
    bool? isCompleted,
    bool? isRewardClaimed,
    DateTime? completedAt,
    DateTime? claimedAt,
    Map<String, dynamic>? progressData,
  }) {
    return QuestProgress(
      questId: questId,
      userId: userId,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      claimedAt: claimedAt ?? this.claimedAt,
      lastUpdated: DateTime.now(),
      progressData: progressData ?? this.progressData,
    );
  }
}

/// Represents a player's quest statistics
class QuestStats {
  final String userId;
  final int totalQuestsCompleted;
  final int dailyQuestsCompleted;
  final int weeklyQuestsCompleted;
  final int achievementQuestsCompleted;
  final int currentDailyStreak;
  final int longestDailyStreak;
  final int currentWeeklyStreak;
  final int longestWeeklyStreak;
  final DateTime lastDailyQuestDate;
  final DateTime lastWeeklyQuestDate;
  final Map<String, int> categoryProgress; // Progress by quest category
  final DateTime lastUpdated;

  const QuestStats({
    required this.userId,
    this.totalQuestsCompleted = 0,
    this.dailyQuestsCompleted = 0,
    this.weeklyQuestsCompleted = 0,
    this.achievementQuestsCompleted = 0,
    this.currentDailyStreak = 0,
    this.longestDailyStreak = 0,
    this.currentWeeklyStreak = 0,
    this.longestWeeklyStreak = 0,
    required this.lastDailyQuestDate,
    required this.lastWeeklyQuestDate,
    this.categoryProgress = const {},
    required this.lastUpdated,
  });

  factory QuestStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return QuestStats(
      userId: doc.id,
      totalQuestsCompleted: data['totalQuestsCompleted'] ?? 0,
      dailyQuestsCompleted: data['dailyQuestsCompleted'] ?? 0,
      weeklyQuestsCompleted: data['weeklyQuestsCompleted'] ?? 0,
      achievementQuestsCompleted: data['achievementQuestsCompleted'] ?? 0,
      currentDailyStreak: data['currentDailyStreak'] ?? 0,
      longestDailyStreak: data['longestDailyStreak'] ?? 0,
      currentWeeklyStreak: data['currentWeeklyStreak'] ?? 0,
      longestWeeklyStreak: data['longestWeeklyStreak'] ?? 0,
      lastDailyQuestDate: data['lastDailyQuestDate']?.toDate() ?? DateTime(2000),
      lastWeeklyQuestDate: data['lastWeeklyQuestDate']?.toDate() ?? DateTime(2000),
      categoryProgress: Map<String, int>.from(data['categoryProgress'] ?? {}),
      lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'totalQuestsCompleted': totalQuestsCompleted,
      'dailyQuestsCompleted': dailyQuestsCompleted,
      'weeklyQuestsCompleted': weeklyQuestsCompleted,
      'achievementQuestsCompleted': achievementQuestsCompleted,
      'currentDailyStreak': currentDailyStreak,
      'longestDailyStreak': longestDailyStreak,
      'currentWeeklyStreak': currentWeeklyStreak,
      'longestWeeklyStreak': longestWeeklyStreak,
      'lastDailyQuestDate': Timestamp.fromDate(lastDailyQuestDate),
      'lastWeeklyQuestDate': Timestamp.fromDate(lastWeeklyQuestDate),
      'categoryProgress': categoryProgress,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}
