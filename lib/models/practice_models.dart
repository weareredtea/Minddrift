// lib/models/practice_models.dart

/// Represents a single practice challenge
class PracticeChallenge {
  final String categoryId;
  final String clue;
  final double secretPosition;
  final int range; // 1-5, which range the position falls into
  final String bundleId;
  final String leftLabel;
  final String rightLabel;

  const PracticeChallenge({
    required this.categoryId,
    required this.clue,
    required this.secretPosition,
    required this.range,
    required this.bundleId,
    required this.leftLabel,
    required this.rightLabel,
  });

  Map<String, dynamic> toMap() => {
    'categoryId': categoryId,
    'clue': clue,
    'secretPosition': secretPosition,
    'range': range,
    'bundleId': bundleId,
    'leftLabel': leftLabel,
    'rightLabel': rightLabel,
  };

  factory PracticeChallenge.fromMap(Map<String, dynamic> map) => PracticeChallenge(
    categoryId: map['categoryId'] ?? '',
    clue: map['clue'] ?? '',
    secretPosition: map['secretPosition']?.toDouble() ?? 0.5,
    range: map['range'] ?? 3,
    bundleId: map['bundleId'] ?? '',
    leftLabel: map['leftLabel'] ?? '',
    rightLabel: map['rightLabel'] ?? '',
  );
}

/// Represents the result of a practice attempt
class PracticeResult {
  final PracticeChallenge challenge;
  final double userGuess;
  final int score;
  final double accuracy; // How close the guess was (0.0-1.0)
  final DateTime completedAt;
  final Duration timeSpent;

  const PracticeResult({
    required this.challenge,
    required this.userGuess,
    required this.score,
    required this.accuracy,
    required this.completedAt,
    required this.timeSpent,
  });

  /// Get feedback message based on accuracy
  String get feedbackMessage {
    if (accuracy >= 0.95) return 'Perfect! Spot on!';
    if (accuracy >= 0.85) return 'Excellent! Very close!';
    if (accuracy >= 0.70) return 'Great job! Close guess!';
    if (accuracy >= 0.50) return 'Good effort! Getting warmer!';
    if (accuracy >= 0.30) return 'Not bad! Keep practicing!';
    return 'Keep trying! You\'ll get it!';
  }

  /// Get accuracy percentage for display
  String get accuracyPercentage => '${(accuracy * 100).toStringAsFixed(1)}%';

  Map<String, dynamic> toMap() => {
    'challenge': challenge.toMap(),
    'userGuess': userGuess,
    'score': score,
    'accuracy': accuracy,
    'completedAt': completedAt.toIso8601String(),
    'timeSpent': timeSpent.inSeconds,
  };
}

/// Tracks user's practice statistics
class PracticeStats {
  final int totalChallenges;
  final int perfectScores;
  final double averageScore;
  final double averageAccuracy;
  final int bestScore;
  final int bestStreak;
  final int currentStreak;
  final Map<String, int> categoryStats; // Category ID -> times played

  const PracticeStats({
    required this.totalChallenges,
    required this.perfectScores,
    required this.averageScore,
    required this.averageAccuracy,
    required this.bestScore,
    required this.bestStreak,
    required this.currentStreak,
    required this.categoryStats,
  });

  factory PracticeStats.empty() => const PracticeStats(
    totalChallenges: 0,
    perfectScores: 0,
    averageScore: 0.0,
    averageAccuracy: 0.0,
    bestScore: 0,
    bestStreak: 0,
    currentStreak: 0,
    categoryStats: {},
  );

  Map<String, dynamic> toMap() => {
    'totalChallenges': totalChallenges,
    'perfectScores': perfectScores,
    'averageScore': averageScore,
    'averageAccuracy': averageAccuracy,
    'bestScore': bestScore,
    'bestStreak': bestStreak,
    'currentStreak': currentStreak,
    'categoryStats': categoryStats,
  };

  factory PracticeStats.fromMap(Map<String, dynamic> map) => PracticeStats(
    totalChallenges: map['totalChallenges'] ?? 0,
    perfectScores: map['perfectScores'] ?? 0,
    averageScore: map['averageScore']?.toDouble() ?? 0.0,
    averageAccuracy: map['averageAccuracy']?.toDouble() ?? 0.0,
    bestScore: map['bestScore'] ?? 0,
    bestStreak: map['bestStreak'] ?? 0,
    currentStreak: map['currentStreak'] ?? 0,
    categoryStats: Map<String, int>.from(map['categoryStats'] ?? {}),
  );
}
