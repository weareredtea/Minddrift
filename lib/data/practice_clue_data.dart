// lib/data/practice_clue_data.dart

/// Organized clue database for Practice Mode
/// Easy to edit and expand - just add more clues to any range
/// 
/// Structure: 4 categories × 5 ranges × 4 clues = 80 total clues
/// User Experience: 4 categories × 5 ranges = 20 unique challenges

class CategoryClueSet {
  final List<String> range1; // 0.0-0.2 (Left extreme)
  final List<String> range2; // 0.2-0.4
  final List<String> range3; // 0.4-0.6 (Center)
  final List<String> range4; // 0.6-0.8
  final List<String> range5; // 0.8-1.0 (Right extreme)

  const CategoryClueSet({
    required this.range1,
    required this.range2,
    required this.range3,
    required this.range4,
    required this.range5,
  });

  List<String> getRangeClues(int range) {
    switch (range) {
      case 1: return range1;
      case 2: return range2;
      case 3: return range3;
      case 4: return range4;
      case 5: return range5;
      default: return range3; // Default to center
    }
  }
}

class PracticeClueDatabase {
  /// Practice Mode Categories (4 total from 2 bundles)
  static const List<String> practiceCategories = [
    // Bundle.fantasy (2 categories)
    'magic_science',
    'myth_history',
    // Bundle.food (2 categories) 
    'hungry_satiated',
    'spicy_mild',
  ];

  /// Complete clue database - organized by category and range
  /// TO ADD MORE CLUES: Simply append to any range list below
  static const Map<String, CategoryClueSet> clues = {
    
    // ═══════════════════════════════════════════════════════════
    // BUNDLE.FANTASY - Categories
    // ═══════════════════════════════════════════════════════════
    
    'magic_science': CategoryClueSet(
      // Range 1: 0.0-0.2 (MAGIC side)
      range1: [
        'Dragon\'s breath',
        'Wizard\'s spell',
        'Enchanted forest',
        'Magic potion'
      ],
      // Range 2: 0.2-0.4 (Mostly magic)
      range2: [
        'Fairy tale',
        'Crystal ball',
        'Spell book',
        'Mystical aura'
      ],
      // Range 3: 0.4-0.6 (Neutral/Mixed)
      range3: [
        'Fantasy novel',
        'Alchemy',
        'Old legend',
        'Supernatural'
      ],
      // Range 4: 0.6-0.8 (Mostly science)
      range4: [
        'Laboratory',
        'Research',
        'Experiment',
        'Data analysis'
      ],
      // Range 5: 0.8-1.0 (SCIENCE side)
      range5: [
        'Quantum physics',
        'DNA sequencing',
        'Space telescope',
        'Clinical trial'
      ],
    ),

    'myth_history': CategoryClueSet(
      // Range 1: 0.0-0.2 (MYTH side)
      range1: [
        'Dragon legend',
        'Greek gods',
        'Fairy tale',
        'Unicorn story'
      ],
      // Range 2: 0.2-0.4 (Mostly myth)
      range2: [
        'Folk tale',
        'Ancient legend',
        'Oral tradition',
        'Mythical creature'
      ],
      // Range 3: 0.4-0.6 (Neutral/Mixed)
      range3: [
        'Historical fiction',
        'Old story',
        'Ancient tale',
        'Legend or fact'
      ],
      // Range 4: 0.6-0.8 (Mostly history)
      range4: [
        'Historical record',
        'Archaeological find',
        'Museum artifact',
        'Documented event'
      ],
      // Range 5: 0.8-1.0 (HISTORY side)
      range5: [
        'DNA evidence',
        'Carbon dating',
        'Scientific proof',
        'Historical fact'
      ],
    ),

    // ═══════════════════════════════════════════════════════════
    // BUNDLE.FOOD - Categories  
    // ═══════════════════════════════════════════════════════════

    'hungry_satiated': CategoryClueSet(
      // Range 1: 0.0-0.2 (HUNGRY side)
      range1: [
        'Starving student',
        'Empty stomach',
        'Skipped breakfast',
        'Famished traveler'
      ],
      // Range 2: 0.2-0.4 (Mostly hungry)
      range2: [
        'Getting peckish',
        'Light snack time',
        'Stomach rumbling',
        'Pre-dinner hunger'
      ],
      // Range 3: 0.4-0.6 (Neutral/Satisfied)
      range3: [
        'Just right',
        'Content feeling',
        'Good meal',
        'Perfectly satisfied'
      ],
      // Range 4: 0.6-0.8 (Mostly full)
      range4: [
        'Very full',
        'Had enough',
        'Big dinner',
        'Feeling stuffed'
      ],
      // Range 5: 0.8-1.0 (SATIATED side)
      range5: [
        'Thanksgiving feast',
        'Food coma',
        'About to burst',
        'Can\'t eat another bite'
      ],
    ),

    'spicy_mild': CategoryClueSet(
      // Range 1: 0.0-0.2 (SPICY side)
      range1: [
        'Ghost pepper',
        'Fire in mouth',
        'Call the fire department',
        'Lava hot'
      ],
      // Range 2: 0.2-0.4 (Mostly spicy)
      range2: [
        'Jalapeño kick',
        'Hot sauce',
        'Spicy curry',
        'Burning tongue'
      ],
      // Range 3: 0.4-0.6 (Neutral/Balanced)
      range3: [
        'Black pepper',
        'Hint of heat',
        'Gentle warmth',
        'Balanced seasoning'
      ],
      // Range 4: 0.6-0.8 (Mostly mild)
      range4: [
        'Plain yogurt',
        'Butter on toast',
        'Vanilla ice cream',
        'Soothing soup'
      ],
      // Range 5: 0.8-1.0 (MILD side)
      range5: [
        'Baby food',
        'Plain white rice',
        'Distilled water',
        'Completely tasteless'
      ],
    ),
  };

  /// Get clue for specific category and range
  static List<String> getCluePool(String categoryId, int range) {
    final categoryClues = clues[categoryId];
    if (categoryClues == null) {
      throw ArgumentError('Category $categoryId not found in practice database');
    }
    return categoryClues.getRangeClues(range);
  }

  /// Check if category is available in practice mode
  static bool isCategoryAvailable(String categoryId) {
    return practiceCategories.contains(categoryId);
  }

  /// Get all available practice categories
  static List<String> getAvailableCategories() {
    return List.from(practiceCategories);
  }
}
