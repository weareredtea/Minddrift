// lib/data/campaign_data.dart

/// Campaign Mode Database
/// 40 hand-crafted levels organized into 4 sections of 10 levels each
/// Progressive difficulty with carefully designed challenges

import '../models/campaign_models.dart';

class CampaignDatabase {
  static const List<CampaignLevel> allLevels = [
    // ===========================================
    // SECTION 1: BEGINNER'S JOURNEY (Levels 1-10)
    // Theme: Learning the basics with clear extremes
    // ===========================================
    
    // Level 1: Tutorial Level
    CampaignLevel(
      id: 'campaign_001',
      levelNumber: 1,
      sectionNumber: 1,
      title: 'First Steps',
      description: 'Welcome to Campaign Mode! Start with something obvious.',
      categoryId: 'hungry_satiated',
      range: 1,
      specificClue: 'Stomach rumbling',
      localizedClue: LocalizedClue(
        english: 'Stomach rumbling',
        arabic: 'قرقرة المعدة',
      ),
      secretPosition: 10,
      difficulty: 'easy',
      maxScore: 25,
    ),
    
    // Level 2: Another Clear Extreme
    CampaignLevel(
      id: 'campaign_002',
      levelNumber: 2,
      sectionNumber: 1,
      title: 'Opposite End',
      description: 'Now try the other extreme of the spectrum.',
      categoryId: 'hungry_satiated',
      range: 5,
      specificClue: 'A toothpick',
      localizedClue: LocalizedClue(
        english: 'A toothpick',
        arabic: 'عود أسنان',
      ),
      secretPosition: 95,
      difficulty: 'easy',
      maxScore: 25,
    ),
    
    // Level 3: Temperature Basics
    CampaignLevel(
      id: 'campaign_003',
      levelNumber: 3,
      sectionNumber: 1,
      title: 'Feeling Hot',
      description: 'Switch categories and feel the heat!',
      categoryId: 'spicy_mild',
      range: 1,
      specificClue: 'A fire extinguisher',
      localizedClue: LocalizedClue(
        english: 'A fire extinguisher',
        arabic: 'طفاية حريق',
      ),
      secretPosition: 5,
      difficulty: 'easy',
      maxScore: 25,
    ),
    
    // Level 4: Cool Down
    CampaignLevel(
      id: 'campaign_004',
      levelNumber: 4,
      sectionNumber: 1,
      title: 'Cool Breeze',
      description: 'Time to cool things down.',
      categoryId: 'spicy_mild',
      range: 5,
      specificClue: 'A glass of water',
      localizedClue: LocalizedClue(
        english: 'A glass of water',
        arabic: 'كوب ماء',
      ),
      secretPosition: 98,
      difficulty: 'easy',
      maxScore: 25,
    ),
    
    // Level 5: Fantasy Realm
    CampaignLevel(
      id: 'campaign_005',
      levelNumber: 5,
      sectionNumber: 1,
      title: 'Enter Fantasy',
      description: 'Step into a world of magic and wonder.',
      categoryId: 'magic_science',
      range: 1,
      specificClue: 'A magic wand',
      localizedClue: LocalizedClue(
        english: 'A magic wand',
        arabic: 'عصا سحرية',
      ),
      secretPosition: 15,
      difficulty: 'easy',
      maxScore: 25,
    ),
    
    // Level 6: Science Lab
    CampaignLevel(
      id: 'campaign_006',
      levelNumber: 6,
      sectionNumber: 1,
      title: 'Laboratory',
      description: 'From magic to science - observe and analyze.',
      categoryId: 'magic_science',
      range: 5,
      specificClue: 'A lab coat',
      localizedClue: LocalizedClue(
        english: 'A lab coat',
        arabic: 'معطف المختبر',
      ),
      secretPosition: 90,
      difficulty: 'easy',
      maxScore: 25,
    ),
    
    // Level 7: Ancient Tales
    CampaignLevel(
      id: 'campaign_007',
      levelNumber: 7,
      sectionNumber: 1,
      title: 'Ancient Legends',
      description: 'Explore stories from long ago.',
      categoryId: 'myth_history',
      range: 1,
      specificClue: 'Mount Olympus',
      localizedClue: LocalizedClue(
        english: 'Mount Olympus',
        arabic: 'جبل الأوليمب',
      ),
      secretPosition: 8,
      difficulty: 'easy',
      maxScore: 25,
    ),
    
    // Level 8: Modern Times
    CampaignLevel(
      id: 'campaign_008',
      levelNumber: 8,
      sectionNumber: 1,
      title: 'Modern Era',
      description: 'Fast forward to recent history.',
      categoryId: 'myth_history',
      range: 5,
      specificClue: 'A newspaper headline',
      localizedClue: LocalizedClue(
        english: 'A newspaper headline',
        arabic: 'عنوان صحيفة',
      ),
      secretPosition: 85,
      difficulty: 'easy',
      maxScore: 25,
    ),
    
    // Level 9: Getting Tricky
    CampaignLevel(
      id: 'campaign_009',
      levelNumber: 9,
      sectionNumber: 1,
      title: 'First Challenge',
      description: 'Things are getting a bit more challenging.',
      categoryId: 'hungry_satiated',
      range: 2,
      specificClue: 'Watching a cooking show',
      localizedClue: LocalizedClue(
        english: 'Watching a cooking show',
        arabic: 'مشاهدة برنامج طبخ',
      ),
      secretPosition: 30,
      difficulty: 'medium',
      maxScore: 30,
    ),
    
    // Level 10: Section Finale
    CampaignLevel(
      id: 'campaign_010',
      levelNumber: 10,
      sectionNumber: 1,
      title: 'Section Master',
      description: 'Complete the first section with this final test!',
      categoryId: 'spicy_mild',
      range: 4,
      specificClue: 'A saltine cracker',
      localizedClue: LocalizedClue(
        english: 'A saltine cracker',
        arabic: 'بسكويت مالح',
      ),
      secretPosition: 75,
      difficulty: 'medium',
      maxScore: 30,
    ),
    
    // ===========================================
    // SECTION 2: RISING CHALLENGE (Levels 11-20)
    // Theme: Mixed difficulties, introducing subtlety
    // ===========================================
    
    // Level 11: Subtle Beginnings
    CampaignLevel(
      id: 'campaign_011',
      levelNumber: 11,
      sectionNumber: 2,
      title: 'Subtle Art',
      description: 'Welcome to Section 2! Time for more nuanced challenges.',
      categoryId: 'magic_science',
      range: 3,
      specificClue: 'Alchemy experiment',
      secretPosition: 45,
      difficulty: 'medium',
      maxScore: 30,
    ),
    
    // Level 12: Historical Mystery
    CampaignLevel(
      id: 'campaign_012',
      levelNumber: 12,
      sectionNumber: 2,
      title: 'Lost in Time',
      description: 'A mysterious period in history.',
      categoryId: 'myth_history',
      range: 3,
      specificClue: 'Medieval times',
      secretPosition: 40,
      difficulty: 'medium',
      maxScore: 30,
    ),
    
    // Level 13: Comfort Food
    CampaignLevel(
      id: 'campaign_013',
      levelNumber: 13,
      sectionNumber: 2,
      title: 'Comfort Zone',
      description: 'How satisfied does comfort food make you?',
      categoryId: 'hungry_satiated',
      range: 4,
      specificClue: 'Comfort food satisfied',
      secretPosition: 70,
      difficulty: 'medium',
      maxScore: 30,
    ),
    
    // Level 14: Spice Challenge
    CampaignLevel(
      id: 'campaign_014',
      levelNumber: 14,
      sectionNumber: 2,
      title: 'Spice Quest',
      description: 'Can you handle this level of heat?',
      categoryId: 'spicy_mild',
      range: 3,
      specificClue: 'Jalapeño pepper',
      secretPosition: 55,
      difficulty: 'medium',
      maxScore: 30,
    ),
    
    // Level 15: Magical Science
    CampaignLevel(
      id: 'campaign_015',
      levelNumber: 15,
      sectionNumber: 2,
      title: 'Magical Science',
      description: 'Where magic meets technology.',
      categoryId: 'magic_science',
      range: 2,
      specificClue: 'Enchanted gadget',
      secretPosition: 30,
      difficulty: 'hard',
      maxScore: 35,
    ),
    
    // Level 16: Historical Figures
    CampaignLevel(
      id: 'campaign_016',
      levelNumber: 16,
      sectionNumber: 2,
      title: 'Famous Figures',
      description: 'Stories of legendary people.',
      categoryId: 'myth_history',
      range: 4,
      specificClue: 'Renaissance period',
      secretPosition: 60,
      difficulty: 'medium',
      maxScore: 30,
    ),
    
    // Level 17: Hunger Games
    CampaignLevel(
      id: 'campaign_017',
      levelNumber: 17,
      sectionNumber: 2,
      title: 'Appetite Test',
      description: 'A tricky hunger level to identify.',
      categoryId: 'hungry_satiated',
      range: 3,
      specificClue: 'Room for dessert',
      secretPosition: 50,
      difficulty: 'hard',
      maxScore: 35,
    ),
    
    // Level 18: Heat Wave
    CampaignLevel(
      id: 'campaign_018',
      levelNumber: 18,
      sectionNumber: 2,
      title: 'Heat Wave',
      description: 'Feeling the burn yet?',
      categoryId: 'spicy_mild',
      range: 4,
      specificClue: 'Sriracha sauce',
      secretPosition: 75,
      difficulty: 'medium',
      maxScore: 30,
    ),
    
    // Level 19: Tech Magic
    CampaignLevel(
      id: 'campaign_019',
      levelNumber: 19,
      sectionNumber: 2,
      title: 'Tech Wizardry',
      description: 'Advanced technology feels like magic.',
      categoryId: 'magic_science',
      range: 4,
      specificClue: 'AI assistant',
      secretPosition: 65,
      difficulty: 'hard',
      maxScore: 35,
    ),
    
    // Level 20: Time Traveler
    CampaignLevel(
      id: 'campaign_020',
      levelNumber: 20,
      sectionNumber: 2,
      title: 'Time Traveler',
      description: 'Section 2 finale: A journey through time!',
      categoryId: 'myth_history',
      range: 2,
      specificClue: 'Victorian era',
      secretPosition: 35,
      difficulty: 'hard',
      maxScore: 35,
    ),
    
    // ===========================================
    // SECTION 3: EXPERT TERRITORY (Levels 21-30)
    // Theme: Difficult challenges requiring precision
    // ===========================================
    
    // Level 21: Expert Welcome
    CampaignLevel(
      id: 'campaign_021',
      levelNumber: 21,
      sectionNumber: 3,
      title: 'Expert Level',
      description: 'Welcome to Section 3 - only experts make it here!',
      categoryId: 'hungry_satiated',
      range: 2,
      specificClue: 'Could eat a snack',
      secretPosition: 40,
      difficulty: 'hard',
      maxScore: 35,
    ),
    
    // Level 22: Subtle Heat
    CampaignLevel(
      id: 'campaign_022',
      levelNumber: 22,
      sectionNumber: 3,
      title: 'Subtle Burn',
      description: 'Can you detect this subtle level of spice?',
      categoryId: 'spicy_mild',
      range: 2,
      specificClue: 'Black pepper',
      secretPosition: 25,
      difficulty: 'hard',
      maxScore: 35,
    ),
    
    // Level 23: Mystical Science
    CampaignLevel(
      id: 'campaign_023',
      levelNumber: 23,
      sectionNumber: 3,
      title: 'Mystical Science',
      description: 'The line between magic and science blurs.',
      categoryId: 'magic_science',
      range: 3,
      specificClue: 'Theoretical physics',
      secretPosition: 55,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 24: Ancient Mysteries
    CampaignLevel(
      id: 'campaign_024',
      levelNumber: 24,
      sectionNumber: 3,
      title: 'Ancient Mysteries',
      description: 'Secrets lost to time.',
      categoryId: 'myth_history',
      range: 2,
      specificClue: 'Bronze Age',
      secretPosition: 30,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 25: Precise Hunger
    CampaignLevel(
      id: 'campaign_025',
      levelNumber: 25,
      sectionNumber: 3,
      title: 'Precise Appetite',
      description: 'Pinpoint this exact level of hunger.',
      categoryId: 'hungry_satiated',
      range: 3,
      specificClue: 'Satisfied but not full',
      secretPosition: 45,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 26: Spice Master
    CampaignLevel(
      id: 'campaign_026',
      levelNumber: 26,
      sectionNumber: 3,
      title: 'Spice Master',
      description: 'Only a spice expert can nail this one.',
      categoryId: 'spicy_mild',
      range: 3,
      specificClue: 'Cayenne pepper',
      secretPosition: 50,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 27: Quantum Magic
    CampaignLevel(
      id: 'campaign_027',
      levelNumber: 27,
      sectionNumber: 3,
      title: 'Quantum Realm',
      description: 'Where quantum physics meets ancient magic.',
      categoryId: 'magic_science',
      range: 2,
      specificClue: 'Quantum entanglement',
      secretPosition: 35,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 28: Historical Precision
    CampaignLevel(
      id: 'campaign_028',
      levelNumber: 28,
      sectionNumber: 3,
      title: 'Historical Precision',
      description: 'Precise knowledge of historical periods required.',
      categoryId: 'myth_history',
      range: 4,
      specificClue: 'Industrial Revolution',
      secretPosition: 70,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 29: Perfect Balance
    CampaignLevel(
      id: 'campaign_029',
      levelNumber: 29,
      sectionNumber: 3,
      title: 'Perfect Balance',
      description: 'Find the perfect balance point.',
      categoryId: 'hungry_satiated',
      range: 4,
      specificClue: 'Perfectly content',
      secretPosition: 65,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 30: Section Master
    CampaignLevel(
      id: 'campaign_030',
      levelNumber: 30,
      sectionNumber: 3,
      title: 'Expert Master',
      description: 'Prove your expertise with this section finale!',
      categoryId: 'spicy_mild',
      range: 4,
      specificClue: 'Perfectly seasoned',
      secretPosition: 60,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // ===========================================
    // SECTION 4: GRANDMASTER GAUNTLET (Levels 31-40)
    // Theme: Ultimate challenges for true masters
    // ===========================================
    
    // Level 31: Grandmaster Entry
    CampaignLevel(
      id: 'campaign_031',
      levelNumber: 31,
      sectionNumber: 4,
      title: 'Grandmaster Trial',
      description: 'Welcome to the final section - only grandmasters succeed here!',
      categoryId: 'magic_science',
      range: 4,
      specificClue: 'Bioengineering',
      secretPosition: 75,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 32: Time Paradox
    CampaignLevel(
      id: 'campaign_032',
      levelNumber: 32,
      sectionNumber: 4,
      title: 'Time Paradox',
      description: 'Navigate through complex historical timelines.',
      categoryId: 'myth_history',
      range: 3,
      specificClue: 'Cold War era',
      secretPosition: 55,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 33: Hunger Guru
    CampaignLevel(
      id: 'campaign_033',
      levelNumber: 33,
      sectionNumber: 4,
      title: 'Hunger Guru',
      description: 'Master the most subtle hunger distinctions.',
      categoryId: 'hungry_satiated',
      range: 2,
      specificClue: 'Thinking about food',
      secretPosition: 35,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 34: Heat Virtuoso
    CampaignLevel(
      id: 'campaign_034',
      levelNumber: 34,
      sectionNumber: 4,
      title: 'Heat Virtuoso',
      description: 'Virtuoso-level spice detection required.',
      categoryId: 'spicy_mild',
      range: 2,
      specificClue: 'Hint of paprika',
      secretPosition: 20,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 35: Ultimate Fusion
    CampaignLevel(
      id: 'campaign_035',
      levelNumber: 35,
      sectionNumber: 4,
      title: 'Ultimate Fusion',
      description: 'The ultimate fusion of magic and science.',
      categoryId: 'magic_science',
      range: 3,
      specificClue: 'Nanotechnology',
      secretPosition: 45,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 36: Legendary Era
    CampaignLevel(
      id: 'campaign_036',
      levelNumber: 36,
      sectionNumber: 4,
      title: 'Legendary Era',
      description: 'Place this legendary historical period.',
      categoryId: 'myth_history',
      range: 4,
      specificClue: 'Space Age',
      secretPosition: 80,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 37: Appetite Sage
    CampaignLevel(
      id: 'campaign_037',
      levelNumber: 37,
      sectionNumber: 4,
      title: 'Appetite Sage',
      description: 'Sage-level understanding of hunger required.',
      categoryId: 'hungry_satiated',
      range: 4,
      specificClue: 'Pleasantly full',
      secretPosition: 75,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 38: Spice Enlightenment
    CampaignLevel(
      id: 'campaign_038',
      levelNumber: 38,
      sectionNumber: 4,
      title: 'Spice Enlightenment',
      description: 'Achieve enlightenment in spice perception.',
      categoryId: 'spicy_mild',
      range: 3,
      specificClue: 'Chipotle pepper',
      secretPosition: 40,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 39: Penultimate Challenge
    CampaignLevel(
      id: 'campaign_039',
      levelNumber: 39,
      sectionNumber: 4,
      title: 'Penultimate Test',
      description: 'One more challenge before the final boss!',
      categoryId: 'magic_science',
      range: 2,
      specificClue: 'String theory',
      secretPosition: 25,
      difficulty: 'expert',
      maxScore: 40,
    ),
    
    // Level 40: Final Boss
    CampaignLevel(
      id: 'campaign_040',
      levelNumber: 40,
      sectionNumber: 4,
      title: 'Campaign Master',
      description: 'The ultimate challenge! Prove you are the true Campaign Master!',
      categoryId: 'myth_history',
      range: 3,
      specificClue: 'Information Age',
      secretPosition: 50,
      difficulty: 'expert',
      maxScore: 50, // Special final boss bonus
    ),
  ];

  /// Get all levels organized by section
  static List<CampaignSection> getSections() {
    final sections = <CampaignSection>[];
    
    for (int sectionNum = 1; sectionNum <= 4; sectionNum++) {
      final sectionLevels = allLevels
          .where((level) => level.sectionNumber == sectionNum)
          .toList();
      
      final section = CampaignSection(
        sectionNumber: sectionNum,
        title: _getSectionTitle(sectionNum),
        description: _getSectionDescription(sectionNum),
        theme: _getSectionTheme(sectionNum),
        levels: sectionLevels,
      );
      
      sections.add(section);
    }
    
    return sections;
  }

  /// Get a specific level by ID
  static CampaignLevel? getLevelById(String levelId) {
    try {
      return allLevels.firstWhere((level) => level.id == levelId);
    } catch (e) {
      return null;
    }
  }

  /// Get levels for a specific section
  static List<CampaignLevel> getLevelsForSection(int sectionNumber) {
    return allLevels
        .where((level) => level.sectionNumber == sectionNumber)
        .toList();
  }

  static String _getSectionTitle(int sectionNumber) {
    switch (sectionNumber) {
      case 1: return "Beginner's Journey";
      case 2: return "Rising Challenge";
      case 3: return "Expert Territory";
      case 4: return "Grandmaster Gauntlet";
      default: return "Unknown Section";
    }
  }

  static String _getSectionDescription(int sectionNumber) {
    switch (sectionNumber) {
      case 1: return "Learn the basics with clear, obvious challenges";
      case 2: return "Mixed difficulties as you develop your skills";
      case 3: return "Difficult challenges requiring precision and expertise";
      case 4: return "Ultimate challenges for true grandmasters";
      default: return "Unknown section";
    }
  }

  static String _getSectionTheme(int sectionNumber) {
    switch (sectionNumber) {
      case 1: return "learning";
      case 2: return "developing";
      case 3: return "mastering";
      case 4: return "perfecting";
      default: return "unknown";
    }
  }
}
