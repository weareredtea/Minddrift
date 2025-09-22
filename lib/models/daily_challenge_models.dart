// lib/models/daily_challenge_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a daily challenge configuration
class DailyChallenge {
  final String id; // Format: YYYY-MM-DD
  final String categoryId;
  final double secretPosition;
  final int range; // 1-5, which range the position falls into
  final String clue;
  final String? clueAr; // Optional Arabic translation if provided in Firestore
  final String? clueEn; // Optional English override if provided in Firestore
  final String difficulty; // 'easy', 'medium', 'hard'
  final DateTime date;
  final String bundleId;
  final String leftLabel;
  final String rightLabel;

  const DailyChallenge({
    required this.id,
    required this.categoryId,
    required this.secretPosition,
    required this.range,
    required this.clue,
    this.clueAr,
    this.clueEn,
    required this.difficulty,
    required this.date,
    required this.bundleId,
    required this.leftLabel,
    required this.rightLabel,
  });

  /// Create from Firestore document
  factory DailyChallenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyChallenge(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      secretPosition: data['secretPosition']?.toDouble() ?? 0.5,
      range: data['range'] ?? 3,
      clue: data['clue'] ?? '',
      clueAr: data['clueAr'],
      clueEn: data['clueEn'],
      difficulty: data['difficulty'] ?? 'medium',
      date: data['date']?.toDate() ?? DateTime.now(),
      bundleId: data['bundleId'] ?? '',
      leftLabel: data['leftLabel'] ?? '',
      rightLabel: data['rightLabel'] ?? '',
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'secretPosition': secretPosition,
      'range': range,
      'clue': clue,
      if (clueAr != null) 'clueAr': clueAr,
      if (clueEn != null) 'clueEn': clueEn,
      'difficulty': difficulty,
      'date': date,
      'bundleId': bundleId,
      'leftLabel': leftLabel,
      'rightLabel': rightLabel,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'secretPosition': secretPosition,
    'range': range,
    'clue': clue,
    'clueAr': clueAr,
    'clueEn': clueEn,
    'difficulty': difficulty,
    'date': date.toIso8601String(),
    'bundleId': bundleId,
    'leftLabel': leftLabel,
    'rightLabel': rightLabel,
  };

  /// Returns a localized clue string when available. Falls back to `clue`.
  String getClue(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return (clueAr != null && clueAr!.isNotEmpty) ? clueAr! : clue;
      case 'en':
      default:
        return (clueEn != null && clueEn!.isNotEmpty) ? clueEn! : clue;
    }
  }
}

/// Represents a user's daily challenge result
class DailyResult {
  final String challengeId; // YYYY-MM-DD
  final String userId;
  final double userGuess;
  final int score;
  final double accuracy;
  final DateTime submittedAt;
  final Duration timeSpent;
  final String categoryId;

  const DailyResult({
    required this.challengeId,
    required this.userId,
    required this.userGuess,
    required this.score,
    required this.accuracy,
    required this.submittedAt,
    required this.timeSpent,
    required this.categoryId,
  });

  /// Create from Firestore document
  factory DailyResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyResult(
      challengeId: data['challengeId'] ?? '',
      userId: data['userId'] ?? '',
      userGuess: data['userGuess']?.toDouble() ?? 0.5,
      score: data['score'] ?? 0,
      accuracy: data['accuracy']?.toDouble() ?? 0.0,
      submittedAt: data['submittedAt']?.toDate() ?? DateTime.now(),
      timeSpent: Duration(seconds: data['timeSpentSeconds'] ?? 0),
      categoryId: data['categoryId'] ?? '',
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'userGuess': userGuess,
      'score': score,
      'accuracy': accuracy,
      'submittedAt': submittedAt,
      'timeSpentSeconds': timeSpent.inSeconds,
      'categoryId': categoryId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Represents a leaderboard entry
class DailyLeaderboardEntry {
  final String userId;
  final String displayName;
  final String avatarId;
  final int score;
  final double accuracy;
  final Duration timeSpent;
  final DateTime submittedAt;
  final int rank;

  const DailyLeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.avatarId,
    required this.score,
    required this.accuracy,
    required this.timeSpent,
    required this.submittedAt,
    required this.rank,
  });

  factory DailyLeaderboardEntry.fromFirestore(DocumentSnapshot doc, int rank) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyLeaderboardEntry(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? 'Anonymous',
      avatarId: data['avatarId'] ?? 'bear',
      score: data['score'] ?? 0,
      accuracy: data['accuracy']?.toDouble() ?? 0.0,
      timeSpent: Duration(seconds: data['timeSpentSeconds'] ?? 0),
      submittedAt: data['submittedAt']?.toDate() ?? DateTime.now(),
      rank: rank,
    );
  }
}

/// Represents user's daily challenge statistics
class DailyStats {
  final int totalDaysPlayed;
  final int currentStreak;
  final int bestStreak;
  final int perfectDays; // Days with score = 5
  final double averageScore;
  final double averageAccuracy;
  final int bestScore;
  final int bestRank;
  final DateTime lastPlayedDate;
  final Map<String, int> difficultyStats; // difficulty -> times played

  const DailyStats({
    required this.totalDaysPlayed,
    required this.currentStreak,
    required this.bestStreak,
    required this.perfectDays,
    required this.averageScore,
    required this.averageAccuracy,
    required this.bestScore,
    required this.bestRank,
    required this.lastPlayedDate,
    required this.difficultyStats,
  });

  factory DailyStats.empty() => DailyStats(
    totalDaysPlayed: 0,
    currentStreak: 0,
    bestStreak: 0,
    perfectDays: 0,
    averageScore: 0.0,
    averageAccuracy: 0.0,
    bestScore: 0,
    bestRank: 0,
    lastPlayedDate: DateTime.now(),
    difficultyStats: {},
  );

  factory DailyStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyStats(
      totalDaysPlayed: data['totalDaysPlayed'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      bestStreak: data['bestStreak'] ?? 0,
      perfectDays: data['perfectDays'] ?? 0,
      averageScore: data['averageScore']?.toDouble() ?? 0.0,
      averageAccuracy: data['averageAccuracy']?.toDouble() ?? 0.0,
      bestScore: data['bestScore'] ?? 0,
      bestRank: data['bestRank'] ?? 0,
      lastPlayedDate: data['lastPlayedDate']?.toDate() ?? DateTime.now(),
      difficultyStats: Map<String, int>.from(data['difficultyStats'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalDaysPlayed': totalDaysPlayed,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'perfectDays': perfectDays,
      'averageScore': averageScore,
      'averageAccuracy': averageAccuracy,
      'bestScore': bestScore,
      'bestRank': bestRank,
      'lastPlayedDate': lastPlayedDate,
      'difficultyStats': difficultyStats,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Check if user played today
  bool get playedToday {
    final today = DateTime.now();
    return lastPlayedDate.year == today.year &&
           lastPlayedDate.month == today.month &&
           lastPlayedDate.day == today.day;
  }

  /// Get streak status message
  String get streakMessage {
    if (currentStreak == 0) return 'Start your streak today!';
    if (currentStreak == 1) return '1 day streak - keep it up!';
    return '$currentStreak day streak! 🔥';
  }
}
