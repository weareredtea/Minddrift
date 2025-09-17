// lib/models/campaign_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single campaign level
class CampaignLevel {
  final String id;
  final int levelNumber;
  final int sectionNumber;
  final String title;
  final String description;
  final String categoryId;
  final int range;
  final String specificClue;
  final int secretPosition;
  final String difficulty; // 'easy', 'medium', 'hard', 'expert'
  final int maxScore;
  final bool isUnlocked;
  final int starsEarned; // 0-3 stars
  final int bestScore;
  final double bestAccuracy;

  const CampaignLevel({
    required this.id,
    required this.levelNumber,
    required this.sectionNumber,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.range,
    required this.specificClue,
    required this.secretPosition,
    required this.difficulty,
    required this.maxScore,
    this.isUnlocked = false,
    this.starsEarned = 0,
    this.bestScore = 0,
    this.bestAccuracy = 0.0,
  });

  CampaignLevel copyWith({
    String? id,
    int? levelNumber,
    int? sectionNumber,
    String? title,
    String? description,
    String? categoryId,
    int? range,
    String? specificClue,
    int? secretPosition,
    String? difficulty,
    int? maxScore,
    bool? isUnlocked,
    int? starsEarned,
    int? bestScore,
    double? bestAccuracy,
  }) {
    return CampaignLevel(
      id: id ?? this.id,
      levelNumber: levelNumber ?? this.levelNumber,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      range: range ?? this.range,
      specificClue: specificClue ?? this.specificClue,
      secretPosition: secretPosition ?? this.secretPosition,
      difficulty: difficulty ?? this.difficulty,
      maxScore: maxScore ?? this.maxScore,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      starsEarned: starsEarned ?? this.starsEarned,
      bestScore: bestScore ?? this.bestScore,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
    );
  }
}

/// Represents a campaign section (group of 10 levels)
class CampaignSection {
  final int sectionNumber;
  final String title;
  final String description;
  final String theme;
  final List<CampaignLevel> levels;
  final bool isUnlocked;
  final bool isCompleted;
  final int totalStars;
  final int maxStars;
  final double completionPercentage;

  const CampaignSection({
    required this.sectionNumber,
    required this.title,
    required this.description,
    required this.theme,
    required this.levels,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.totalStars = 0,
    this.maxStars = 30, // 10 levels × 3 stars each
    this.completionPercentage = 0.0,
  });

  CampaignSection copyWith({
    int? sectionNumber,
    String? title,
    String? description,
    String? theme,
    List<CampaignLevel>? levels,
    bool? isUnlocked,
    bool? isCompleted,
    int? totalStars,
    int? maxStars,
    double? completionPercentage,
  }) {
    return CampaignSection(
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      theme: theme ?? this.theme,
      levels: levels ?? this.levels,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      totalStars: totalStars ?? this.totalStars,
      maxStars: maxStars ?? this.maxStars,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}

/// Represents a campaign result for a specific level
class CampaignResult {
  final String levelId;
  final String userId;
  final int userGuess;
  final int score;
  final double accuracy;
  final int starsEarned;
  final DateTime completedAt;
  final Duration timeSpent;
  final bool isNewBest;

  const CampaignResult({
    required this.levelId,
    required this.userId,
    required this.userGuess,
    required this.score,
    required this.accuracy,
    required this.starsEarned,
    required this.completedAt,
    required this.timeSpent,
    this.isNewBest = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'levelId': levelId,
      'userId': userId,
      'userGuess': userGuess,
      'score': score,
      'accuracy': accuracy,
      'starsEarned': starsEarned,
      'completedAt': Timestamp.fromDate(completedAt),
      'timeSpentSeconds': timeSpent.inSeconds,
      'isNewBest': isNewBest,
    };
  }

  static CampaignResult fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CampaignResult(
      levelId: data['levelId'] ?? '',
      userId: data['userId'] ?? '',
      userGuess: data['userGuess'] ?? 0,
      score: data['score'] ?? 0,
      accuracy: data['accuracy']?.toDouble() ?? 0.0,
      starsEarned: data['starsEarned'] ?? 0,
      completedAt: data['completedAt']?.toDate() ?? DateTime.now(),
      timeSpent: Duration(seconds: data['timeSpentSeconds'] ?? 0),
      isNewBest: data['isNewBest'] ?? false,
    );
  }
}

/// Represents overall campaign progress for a user
class CampaignProgress {
  final String userId;
  final int currentSection;
  final int currentLevel;
  final int totalStars;
  final int maxStars;
  final int levelsCompleted;
  final int totalLevels;
  final double overallProgress;
  final DateTime lastPlayedAt;
  final List<int> sectionStars; // Stars earned per section

  const CampaignProgress({
    required this.userId,
    this.currentSection = 1,
    this.currentLevel = 1,
    this.totalStars = 0,
    this.maxStars = 120, // 40 levels × 3 stars each
    this.levelsCompleted = 0,
    this.totalLevels = 40,
    this.overallProgress = 0.0,
    required this.lastPlayedAt,
    this.sectionStars = const [0, 0, 0, 0], // 4 sections
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'currentSection': currentSection,
      'currentLevel': currentLevel,
      'totalStars': totalStars,
      'maxStars': maxStars,
      'levelsCompleted': levelsCompleted,
      'totalLevels': totalLevels,
      'overallProgress': overallProgress,
      'lastPlayedAt': Timestamp.fromDate(lastPlayedAt),
      'sectionStars': sectionStars,
    };
  }

  static CampaignProgress fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CampaignProgress(
      userId: data['userId'] ?? '',
      currentSection: data['currentSection'] ?? 1,
      currentLevel: data['currentLevel'] ?? 1,
      totalStars: data['totalStars'] ?? 0,
      maxStars: data['maxStars'] ?? 120,
      levelsCompleted: data['levelsCompleted'] ?? 0,
      totalLevels: data['totalLevels'] ?? 40,
      overallProgress: data['overallProgress']?.toDouble() ?? 0.0,
      lastPlayedAt: data['lastPlayedAt']?.toDate() ?? DateTime.now(),
      sectionStars: List<int>.from(data['sectionStars'] ?? [0, 0, 0, 0]),
    );
  }

  CampaignProgress copyWith({
    String? userId,
    int? currentSection,
    int? currentLevel,
    int? totalStars,
    int? maxStars,
    int? levelsCompleted,
    int? totalLevels,
    double? overallProgress,
    DateTime? lastPlayedAt,
    List<int>? sectionStars,
  }) {
    return CampaignProgress(
      userId: userId ?? this.userId,
      currentSection: currentSection ?? this.currentSection,
      currentLevel: currentLevel ?? this.currentLevel,
      totalStars: totalStars ?? this.totalStars,
      maxStars: maxStars ?? this.maxStars,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      totalLevels: totalLevels ?? this.totalLevels,
      overallProgress: overallProgress ?? this.overallProgress,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      sectionStars: sectionStars ?? this.sectionStars,
    );
  }
}

/// Achievement types for campaign mode
enum CampaignAchievement {
  firstLevel('First Steps', 'Complete your first campaign level'),
  firstSection('Section Master', 'Complete your first campaign section'),
  perfectLevel('Perfectionist', 'Get 3 stars on a level'),
  speedRunner('Speed Runner', 'Complete a level in under 30 seconds'),
  starCollector('Star Collector', 'Earn 50 total stars'),
  campaignMaster('Campaign Master', 'Complete the entire campaign');

  const CampaignAchievement(this.title, this.description);
  
  final String title;
  final String description;
}
