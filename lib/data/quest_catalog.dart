// lib/data/quest_catalog.dart

import '../models/quest_models.dart';

/// Comprehensive catalog of all available quests
class QuestCatalog {
  
  /// Daily Quests - Reset every 24 hours
  static const List<Quest> dailyQuests = [
    // Gameplay Daily Quests
    Quest(
      id: 'daily_practice_3',
      title: 'Practice Makes Perfect',
      description: 'Complete 3 practice sessions',
      type: QuestType.daily,
      difficulty: QuestDifficulty.easy,
      category: QuestCategory.gameplay,
      targetAction: 'complete_practice',
      targetCount: 3,
      rewards: [
        QuestReward(type: 'gems', amount: 100),
        QuestReward(type: 'xp', amount: 50),
      ],
    ),
    
    Quest(
      id: 'daily_challenge_1',
      title: 'Daily Dedication',
      description: 'Complete today\'s daily challenge',
      type: QuestType.daily,
      difficulty: QuestDifficulty.easy,
      category: QuestCategory.gameplay,
      targetAction: 'complete_daily_challenge',
      targetCount: 1,
      rewards: [
        QuestReward(type: 'gems', amount: 150),
        QuestReward(type: 'xp', amount: 75),
      ],
    ),
    
    Quest(
      id: 'daily_campaign_2',
      title: 'Campaign Warrior',
      description: 'Complete 2 campaign levels',
      type: QuestType.daily,
      difficulty: QuestDifficulty.medium,
      category: QuestCategory.gameplay,
      targetAction: 'complete_campaign_level',
      targetCount: 2,
      rewards: [
        QuestReward(type: 'gems', amount: 200),
        QuestReward(type: 'xp', amount: 100),
      ],
    ),
    
    Quest(
      id: 'daily_accuracy_80',
      title: 'Precision Master',
      description: 'Achieve 80%+ accuracy in any mode',
      type: QuestType.daily,
      difficulty: QuestDifficulty.medium,
      category: QuestCategory.mastery,
      targetAction: 'achieve_accuracy',
      targetCount: 1,
      rewards: [
        QuestReward(type: 'gems', amount: 250),
        QuestReward(type: 'xp', amount: 125),
      ],
      metadata: {'minAccuracy': 80},
    ),
    
    Quest(
      id: 'daily_gems_500',
      title: 'Gem Collector',
      description: 'Earn 500 Mind Gems today',
      type: QuestType.daily,
      difficulty: QuestDifficulty.medium,
      category: QuestCategory.progression,
      targetAction: 'earn_gems',
      targetCount: 500,
      rewards: [
        QuestReward(type: 'gems', amount: 300),
        QuestReward(type: 'xp', amount: 150),
      ],
    ),
    
    Quest(
      id: 'daily_perfect_score',
      title: 'Perfection Seeker',
      description: 'Achieve a perfect score (100%) in any mode',
      type: QuestType.daily,
      difficulty: QuestDifficulty.hard,
      category: QuestCategory.mastery,
      targetAction: 'perfect_score',
      targetCount: 1,
      rewards: [
        QuestReward(type: 'gems', amount: 500),
        QuestReward(type: 'xp', amount: 250),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_perfectionist'),
      ],
    ),
    
    // Social Daily Quests (for future multiplayer)
    Quest(
      id: 'daily_multiplayer_2',
      title: 'Social Player',
      description: 'Play 2 multiplayer games',
      type: QuestType.daily,
      difficulty: QuestDifficulty.easy,
      category: QuestCategory.social,
      targetAction: 'complete_multiplayer',
      targetCount: 2,
      rewards: [
        QuestReward(type: 'gems', amount: 150),
        QuestReward(type: 'xp', amount: 75),
      ],
    ),
  ];

  /// Weekly Quests - Reset every 7 days
  static const List<Quest> weeklyQuests = [
    Quest(
      id: 'weekly_practice_15',
      title: 'Practice Champion',
      description: 'Complete 15 practice sessions this week',
      type: QuestType.weekly,
      difficulty: QuestDifficulty.medium,
      category: QuestCategory.gameplay,
      targetAction: 'complete_practice',
      targetCount: 15,
      rewards: [
        QuestReward(type: 'gems', amount: 800),
        QuestReward(type: 'xp', amount: 400),
      ],
    ),
    
    Quest(
      id: 'weekly_daily_streak_5',
      title: 'Consistency King',
      description: 'Complete daily challenges for 5 days in a row',
      type: QuestType.weekly,
      difficulty: QuestDifficulty.medium,
      category: QuestCategory.progression,
      targetAction: 'daily_challenge_streak',
      targetCount: 5,
      rewards: [
        QuestReward(type: 'gems', amount: 1000),
        QuestReward(type: 'xp', amount: 500),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_consistent'),
      ],
    ),
    
    Quest(
      id: 'weekly_campaign_10',
      title: 'Campaign Conqueror',
      description: 'Complete 10 campaign levels this week',
      type: QuestType.weekly,
      difficulty: QuestDifficulty.hard,
      category: QuestCategory.gameplay,
      targetAction: 'complete_campaign_level',
      targetCount: 10,
      rewards: [
        QuestReward(type: 'gems', amount: 1200),
        QuestReward(type: 'xp', amount: 600),
      ],
    ),
    
    Quest(
      id: 'weekly_stars_20',
      title: 'Star Collector',
      description: 'Earn 20 stars in campaign mode',
      type: QuestType.weekly,
      difficulty: QuestDifficulty.hard,
      category: QuestCategory.mastery,
      targetAction: 'earn_campaign_stars',
      targetCount: 20,
      rewards: [
        QuestReward(type: 'gems', amount: 1500),
        QuestReward(type: 'xp', amount: 750),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_star_collector'),
      ],
    ),
    
    Quest(
      id: 'weekly_gems_3000',
      title: 'Wealth Builder',
      description: 'Earn 3000 Mind Gems this week',
      type: QuestType.weekly,
      difficulty: QuestDifficulty.hard,
      category: QuestCategory.progression,
      targetAction: 'earn_gems',
      targetCount: 3000,
      rewards: [
        QuestReward(type: 'gems', amount: 2000),
        QuestReward(type: 'xp', amount: 1000),
      ],
    ),
  ];

  /// Achievement Quests - One-time permanent goals
  static const List<Quest> achievementQuests = [
    // First Time Achievements
    Quest(
      id: 'achievement_first_practice',
      title: 'First Steps',
      description: 'Complete your first practice session',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.easy,
      category: QuestCategory.progression,
      targetAction: 'complete_practice',
      targetCount: 1,
      rewards: [
        QuestReward(type: 'gems', amount: 100),
        QuestReward(type: 'xp', amount: 50),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_newcomer'),
      ],
    ),
    
    Quest(
      id: 'achievement_first_daily',
      title: 'Daily Debut',
      description: 'Complete your first daily challenge',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.easy,
      category: QuestCategory.progression,
      targetAction: 'complete_daily_challenge',
      targetCount: 1,
      rewards: [
        QuestReward(type: 'gems', amount: 200),
        QuestReward(type: 'xp', amount: 100),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_daily_starter'),
      ],
    ),
    
    Quest(
      id: 'achievement_first_campaign',
      title: 'Campaign Beginner',
      description: 'Complete your first campaign level',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.easy,
      category: QuestCategory.progression,
      targetAction: 'complete_campaign_level',
      targetCount: 1,
      rewards: [
        QuestReward(type: 'gems', amount: 150),
        QuestReward(type: 'xp', amount: 75),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_explorer'),
      ],
    ),
    
    // Milestone Achievements
    Quest(
      id: 'achievement_practice_50',
      title: 'Practice Veteran',
      description: 'Complete 50 practice sessions',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.medium,
      category: QuestCategory.gameplay,
      targetAction: 'complete_practice',
      targetCount: 50,
      rewards: [
        QuestReward(type: 'gems', amount: 1000),
        QuestReward(type: 'xp', amount: 500),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_practice_veteran'),
      ],
    ),
    
    Quest(
      id: 'achievement_campaign_section_1',
      title: 'First Section Master',
      description: 'Complete the first campaign section',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.medium,
      category: QuestCategory.progression,
      targetAction: 'complete_campaign_section',
      targetCount: 1,
      rewards: [
        QuestReward(type: 'gems', amount: 2000),
        QuestReward(type: 'xp', amount: 1000),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_section_master'),
      ],
      metadata: {'sectionNumber': 1},
    ),
    
    Quest(
      id: 'achievement_perfect_scores_10',
      title: 'Perfectionist',
      description: 'Achieve 10 perfect scores (100%)',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.hard,
      category: QuestCategory.mastery,
      targetAction: 'perfect_score',
      targetCount: 10,
      rewards: [
        QuestReward(type: 'gems', amount: 3000),
        QuestReward(type: 'xp', amount: 1500),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_perfectionist_master'),
      ],
    ),
    
    Quest(
      id: 'achievement_daily_streak_30',
      title: 'Dedication Master',
      description: 'Complete daily challenges for 30 days in a row',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.legendary,
      category: QuestCategory.progression,
      targetAction: 'daily_challenge_streak',
      targetCount: 30,
      rewards: [
        QuestReward(type: 'gems', amount: 10000),
        QuestReward(type: 'xp', amount: 5000),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_dedication_master'),
        QuestReward(type: 'item', amount: 1, itemId: 'skin_legendary_dedication'),
      ],
    ),
    
    Quest(
      id: 'achievement_gems_50000',
      title: 'Gem Tycoon',
      description: 'Earn a total of 50,000 Mind Gems',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.legendary,
      category: QuestCategory.progression,
      targetAction: 'earn_gems_total',
      targetCount: 50000,
      rewards: [
        QuestReward(type: 'gems', amount: 15000),
        QuestReward(type: 'xp', amount: 7500),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_gem_tycoon'),
        QuestReward(type: 'item', amount: 1, itemId: 'badge_diamond_crown'),
      ],
    ),
    
    // Mastery Achievements
    Quest(
      id: 'achievement_accuracy_master',
      title: 'Accuracy Master',
      description: 'Achieve 95%+ accuracy in 20 games',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.hard,
      category: QuestCategory.mastery,
      targetAction: 'achieve_accuracy',
      targetCount: 20,
      rewards: [
        QuestReward(type: 'gems', amount: 5000),
        QuestReward(type: 'xp', amount: 2500),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_accuracy_master'),
      ],
      metadata: {'minAccuracy': 95},
    ),
    
    Quest(
      id: 'achievement_campaign_master',
      title: 'Campaign Master',
      description: 'Complete all campaign levels with 3 stars',
      type: QuestType.achievement,
      difficulty: QuestDifficulty.legendary,
      category: QuestCategory.mastery,
      targetAction: 'three_star_all_levels',
      targetCount: 1,
      rewards: [
        QuestReward(type: 'gems', amount: 25000),
        QuestReward(type: 'xp', amount: 12500),
        QuestReward(type: 'badge', amount: 1, itemId: 'badge_campaign_master'),
        QuestReward(type: 'item', amount: 1, itemId: 'skin_legendary_master'),
      ],
    ),
  ];

  /// Special Event Quests - Limited time
  static List<Quest> getSpecialQuests() {
    // These would be dynamically generated based on events
    return [
      Quest(
        id: 'special_weekend_warrior',
        title: 'Weekend Warrior',
        description: 'Complete 10 games this weekend',
        type: QuestType.special,
        difficulty: QuestDifficulty.medium,
        category: QuestCategory.gameplay,
        targetAction: 'complete_any_game',
        targetCount: 10,
        rewards: const [
          QuestReward(type: 'gems', amount: 1000),
          QuestReward(type: 'xp', amount: 500),
          QuestReward(type: 'badge', amount: 1, itemId: 'badge_weekend_warrior'),
        ],
        timeLimit: Duration(days: 2),
        startDate: DateTime.now().subtract(Duration(days: 1)),
        endDate: DateTime.now().add(Duration(days: 1)),
      ),
    ];
  }

  /// Get all quests by type
  static List<Quest> getQuestsByType(QuestType type) {
    switch (type) {
      case QuestType.daily:
        return dailyQuests;
      case QuestType.weekly:
        return weeklyQuests;
      case QuestType.achievement:
        return achievementQuests;
      case QuestType.special:
        return getSpecialQuests();
    }
  }

  /// Get all available quests
  static List<Quest> getAllQuests() {
    return [
      ...dailyQuests,
      ...weeklyQuests,
      ...achievementQuests,
      ...getSpecialQuests(),
    ];
  }

  /// Get quest by ID
  static Quest? getQuestById(String questId) {
    try {
      return getAllQuests().firstWhere((quest) => quest.id == questId);
    } catch (e) {
      return null;
    }
  }

  /// Get daily quest pool for rotation (returns 3-4 random daily quests)
  static List<Quest> getDailyQuestPool({int count = 3}) {
    final availableQuests = dailyQuests.where((quest) => quest.isAvailable).toList();
    availableQuests.shuffle();
    return availableQuests.take(count).toList();
  }

  /// Get weekly quest pool for rotation (returns 2-3 random weekly quests)
  static List<Quest> getWeeklyQuestPool({int count = 2}) {
    final availableQuests = weeklyQuests.where((quest) => quest.isAvailable).toList();
    availableQuests.shuffle();
    return availableQuests.take(count).toList();
  }

  /// Get available achievement quests for user (based on progress)
  static List<Quest> getAvailableAchievements() {
    return achievementQuests.where((quest) => quest.isAvailable).toList();
  }
}
