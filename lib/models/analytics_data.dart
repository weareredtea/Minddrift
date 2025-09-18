// lib/models/analytics_data.dart

/// Data models for analytics dashboard

class UserOverviewData {
  final int totalUsers;
  final int activeToday;
  final int activeThisWeek;
  final int newUsers;
  final double retentionRate;

  const UserOverviewData({
    required this.totalUsers,
    required this.activeToday,
    required this.activeThisWeek,
    required this.newUsers,
    required this.retentionRate,
  });

  static UserOverviewData empty() {
    return const UserOverviewData(
      totalUsers: 0,
      activeToday: 0,
      activeThisWeek: 0,
      newUsers: 0,
      retentionRate: 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'activeToday': activeToday,
      'activeThisWeek': activeThisWeek,
      'newUsers': newUsers,
      'retentionRate': retentionRate,
    };
  }
}

class GameplayStatsData {
  final int totalGames;
  final double averageScore;
  final double perfectScoreRate;
  final int practiceGames;
  final int dailyChallengeGames;

  const GameplayStatsData({
    required this.totalGames,
    required this.averageScore,
    required this.perfectScoreRate,
    required this.practiceGames,
    required this.dailyChallengeGames,
  });

  static GameplayStatsData empty() {
    return const GameplayStatsData(
      totalGames: 0,
      averageScore: 0.0,
      perfectScoreRate: 0.0,
      practiceGames: 0,
      dailyChallengeGames: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalGames': totalGames,
      'averageScore': averageScore,
      'perfectScoreRate': perfectScoreRate,
      'practiceGames': practiceGames,
      'dailyChallengeGames': dailyChallengeGames,
    };
  }
}

class EconomicData {
  final int totalGemsEarned;
  final int totalGemsSpent;
  final int averageWallet;
  final double conversionRate;
  final int activeSpenders;

  const EconomicData({
    required this.totalGemsEarned,
    required this.totalGemsSpent,
    required this.averageWallet,
    required this.conversionRate,
    required this.activeSpenders,
  });

  static EconomicData empty() {
    return const EconomicData(
      totalGemsEarned: 0,
      totalGemsSpent: 0,
      averageWallet: 0,
      conversionRate: 0.0,
      activeSpenders: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalGemsEarned': totalGemsEarned,
      'totalGemsSpent': totalGemsSpent,
      'averageWallet': averageWallet,
      'conversionRate': conversionRate,
      'activeSpenders': activeSpenders,
    };
  }
}

class EngagementData {
  final int totalQuestsCompleted;
  final int totalCampaignStars;
  final int averageCampaignProgress;
  final double averageDailyStreak;
  final int maxDailyStreak;

  const EngagementData({
    required this.totalQuestsCompleted,
    required this.totalCampaignStars,
    required this.averageCampaignProgress,
    required this.averageDailyStreak,
    required this.maxDailyStreak,
  });

  static EngagementData empty() {
    return const EngagementData(
      totalQuestsCompleted: 0,
      totalCampaignStars: 0,
      averageCampaignProgress: 0,
      averageDailyStreak: 0.0,
      maxDailyStreak: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalQuestsCompleted': totalQuestsCompleted,
      'totalCampaignStars': totalCampaignStars,
      'averageCampaignProgress': averageCampaignProgress,
      'averageDailyStreak': averageDailyStreak,
      'maxDailyStreak': maxDailyStreak,
    };
  }
}

class TopUserData {
  final String userId;
  final String displayName;
  final double value;
  final String metric;

  const TopUserData({
    required this.userId,
    required this.displayName,
    required this.value,
    required this.metric,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'value': value,
      'metric': metric,
    };
  }
}

class AnalyticsSummary {
  final UserOverviewData userOverview;
  final GameplayStatsData gameplayStats;
  final EconomicData economicData;
  final EngagementData engagementData;
  final List<TopUserData> topUsers;

  const AnalyticsSummary({
    required this.userOverview,
    required this.gameplayStats,
    required this.economicData,
    required this.engagementData,
    required this.topUsers,
  });

  static AnalyticsSummary empty() {
    return AnalyticsSummary(
      userOverview: UserOverviewData.empty(),
      gameplayStats: GameplayStatsData.empty(),
      economicData: EconomicData.empty(),
      engagementData: EngagementData.empty(),
      topUsers: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userOverview': userOverview.toMap(),
      'gameplayStats': gameplayStats.toMap(),
      'economicData': economicData.toMap(),
      'engagementData': engagementData.toMap(),
      'topUsers': topUsers.map((user) => user.toMap()).toList(),
    };
  }
}
