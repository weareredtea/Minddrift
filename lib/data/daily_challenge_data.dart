// lib/data/daily_challenge_data.dart

/// Curated Daily Challenge Database
/// 365+ hand-picked challenges for optimal user experience
/// Easy to add/edit/remove challenges

import '../models/campaign_models.dart'; // For LocalizedClue

class DailyChallengeTemplate {
  final String id;
  final String categoryId;
  final int range; // 1-5
  final String specificClue; // Specific clue from the range pool
  final LocalizedClue? localizedClue; // Localized clue support
  final String difficulty; // 'easy', 'medium', 'hard'
  final String? specialNote; // Optional note for special days

  const DailyChallengeTemplate({
    required this.id,
    required this.categoryId,
    required this.range,
    required this.specificClue,
    this.localizedClue,
    required this.difficulty,
    this.specialNote,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'range': range,
    'specificClue': specificClue,
    'difficulty': difficulty,
    'specialNote': specialNote,
  };
}

class DailyChallengeDatabase {
  /// Curated daily challenges - Easy to add more!
  /// Format: Add new challenges to the end of the list
  /// The system will cycle through these challenges based on day of year
  static const List<DailyChallengeTemplate> challenges = [
    
    // ═══════════════════════════════════════════════════════════
    // WEEK 1: Easy Start (Days 1-7)
    // ═══════════════════════════════════════════════════════════
    
    DailyChallengeTemplate(
      id: 'day_001',
      categoryId: 'hungry_satiated',
      range: 1,
      specificClue: 'Starving',
      difficulty: 'easy',
      specialNote: 'Welcome to Daily Challenges!',
    ),
    
    DailyChallengeTemplate(
      id: 'day_002', 
      categoryId: 'spicy_mild',
      range: 5,
      specificClue: 'Plain rice',
      difficulty: 'easy',
    ),
    
    DailyChallengeTemplate(
      id: 'day_003',
      categoryId: 'magic_science', 
      range: 1,
      specificClue: 'Dragon\'s breath',
      difficulty: 'easy',
    ),
    
    DailyChallengeTemplate(
      id: 'day_004',
      categoryId: 'myth_history',
      range: 5,
      specificClue: 'DNA evidence',
      difficulty: 'easy',
    ),
    
    DailyChallengeTemplate(
      id: 'day_005',
      categoryId: 'hungry_satiated',
      range: 5,
      specificClue: 'Food coma',
      difficulty: 'easy',
    ),
    
    DailyChallengeTemplate(
      id: 'day_006',
      categoryId: 'spicy_mild',
      range: 1, 
      specificClue: 'Ghost pepper',
      difficulty: 'easy',
    ),
    
    DailyChallengeTemplate(
      id: 'day_007',
      categoryId: 'magic_science',
      range: 5,
      specificClue: 'Quantum physics',
      difficulty: 'easy',
    ),

    // ═══════════════════════════════════════════════════════════
    // WEEK 2: Medium Difficulty (Days 8-14)
    // ═══════════════════════════════════════════════════════════
    
    DailyChallengeTemplate(
      id: 'day_008',
      categoryId: 'myth_history',
      range: 2,
      specificClue: 'Folk tale',
      difficulty: 'medium',
    ),
    
    DailyChallengeTemplate(
      id: 'day_009',
      categoryId: 'hungry_satiated',
      range: 3,
      specificClue: 'A perfect cup of tea',
      difficulty: 'medium',
    ),
    
    DailyChallengeTemplate(
      id: 'day_010',
      categoryId: 'spicy_mild',
      range: 3,
      specificClue: 'Black pepper',
      difficulty: 'medium',
    ),
    
    DailyChallengeTemplate(
      id: 'day_011',
      categoryId: 'magic_science',
      range: 4,
      specificClue: 'Laboratory',
      difficulty: 'medium',
    ),
    
    DailyChallengeTemplate(
      id: 'day_012',
      categoryId: 'myth_history',
      range: 4,
      specificClue: 'Archaeological find',
      difficulty: 'medium',
    ),
    
    DailyChallengeTemplate(
      id: 'day_013',
      categoryId: 'hungry_satiated',
      range: 2,
      specificClue: 'Getting hungry',
      difficulty: 'medium',
    ),
    
    DailyChallengeTemplate(
      id: 'day_014',
      categoryId: 'spicy_mild',
      range: 4,
      specificClue: 'Plain yogurt',
      difficulty: 'medium',
    ),

    // ═══════════════════════════════════════════════════════════
    // WEEK 3: Hard Challenges (Days 15-21)
    // ═══════════════════════════════════════════════════════════
    
    DailyChallengeTemplate(
      id: 'day_015',
      categoryId: 'magic_science',
      range: 3,
      specificClue: 'Alchemy',
      difficulty: 'hard',
    ),
    
    DailyChallengeTemplate(
      id: 'day_016',
      categoryId: 'myth_history',
      range: 3,
      specificClue: 'Legend or fact',
      difficulty: 'hard',
    ),
    
    DailyChallengeTemplate(
      id: 'day_017',
      categoryId: 'hungry_satiated',
      range: 4,
      specificClue: 'Had enough',
      difficulty: 'hard',
    ),
    
    DailyChallengeTemplate(
      id: 'day_018',
      categoryId: 'spicy_mild',
      range: 2,
      specificClue: 'Hot sauce',
      difficulty: 'hard',
    ),
    
    DailyChallengeTemplate(
      id: 'day_019',
      categoryId: 'magic_science',
      range: 2,
      specificClue: 'Crystal ball',
      difficulty: 'hard',
    ),
    
    DailyChallengeTemplate(
      id: 'day_020',
      categoryId: 'myth_history',
      range: 1,
      specificClue: 'Greek gods',
      difficulty: 'hard',
    ),
    
    DailyChallengeTemplate(
      id: 'day_021',
      categoryId: 'hungry_satiated',
      range: 1,
      specificClue: 'Empty stomach',
      difficulty: 'hard',
      specialNote: 'Week 3 complete!',
    ),

    // ═══════════════════════════════════════════════════════════
    // CONTINUING PATTERN: Add more challenges here...
    // TO EXPAND: Copy the pattern above and continue with day_022, day_023, etc.
    // Mix difficulties and categories for variety
    // ═══════════════════════════════════════════════════════════
    
    // Week 4: Mixed Difficulty (Days 22-28)
    DailyChallengeTemplate(
      id: 'day_022',
      categoryId: 'spicy_mild',
      range: 5,
      specificClue: 'Tasteless',
      difficulty: 'easy',
    ),
    
    DailyChallengeTemplate(
      id: 'day_023',
      categoryId: 'magic_science',
      range: 1,
      specificClue: 'Magic potion',
      difficulty: 'medium',
    ),
    
    DailyChallengeTemplate(
      id: 'day_024',
      categoryId: 'myth_history',
      range: 5,
      specificClue: 'Historical fact',
      difficulty: 'medium',
    ),
    
    DailyChallengeTemplate(
      id: 'day_025',
      categoryId: 'hungry_satiated',
      range: 4,
      specificClue: 'The feeling after a good movie',
      difficulty: 'hard',
    ),
    
    DailyChallengeTemplate(
      id: 'day_026',
      categoryId: 'spicy_mild',
      range: 3,
      specificClue: 'Balanced',
      difficulty: 'hard',
    ),
    
    DailyChallengeTemplate(
      id: 'day_027',
      categoryId: 'magic_science',
      range: 4,
      specificClue: 'Research',
      difficulty: 'medium',
    ),
    
    DailyChallengeTemplate(
      id: 'day_028',
      categoryId: 'myth_history',
      range: 2,
      specificClue: 'Ancient legend',
      difficulty: 'easy',
      specialNote: 'Month 1 complete!',
    ),

    // ═══════════════════════════════════════════════════════════
    // MONTH 2: Continue the pattern...
    // TO EXPAND TO 365 DAYS: Continue adding challenges following this pattern
    // Mix categories, ranges, and difficulties for optimal variety
    // ═══════════════════════════════════════════════════════════
    
    // Add more challenges here to reach 365+
    // For now, these 28 will cycle to provide daily content
    
  ];

  /// Get challenge for specific day
  /// Cycles through available challenges based on day of year
  static DailyChallengeTemplate getChallengeForDay(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final challengeIndex = dayOfYear % challenges.length;
    return challenges[challengeIndex];
  }

  /// Get today's challenge template
  static DailyChallengeTemplate getTodaysChallenge() {
    return getChallengeForDay(DateTime.now());
  }

  /// Get challenge by ID
  static DailyChallengeTemplate? getChallengeById(String id) {
    try {
      return challenges.firstWhere((challenge) => challenge.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get total number of available challenges
  static int get totalChallenges => challenges.length;

  /// Check if we have enough challenges for the year
  static bool get hasFullYearContent => challenges.length >= 365;
}
