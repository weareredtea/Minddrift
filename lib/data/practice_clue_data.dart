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
        'A puff of smoke',
        'Abracadabra',
        'A magic wand',
        'A top hat'
      ],
      // Range 2: 0.2-0.4 (Mostly magic)
      range2: [
        'A four-leaf clover',
        'Knocking on wood',
        'Making a wish',
        'A tarot card'
      ],
      // Range 3: 0.4-0.6 (Neutral/Mixed)
      range3: [
        'An optical illusion',
        'Hypnosis',
        'Astrology',
        'Déjà vu'
      ],
      // Range 4: 0.6-0.8 (Mostly science)
      range4: [
        'A lightbulb',
        'A blueprint',
        'An antibiotic',
        'A smartphone'
      ],
      // Range 5: 0.8-1.0 (SCIENCE side)
      range5: [
        'A lab coat',
        'E = mc²',
        'A beaker',
        'The periodic table'
      ],
    ),

    'myth_history': CategoryClueSet(
      // Range 1: 0.0-0.2 (MYTH side)
      range1: [
        'Mount Olympus',
        'Excalibur',
        'A golden fleece',
        'A cyclops\'s eye'
      ],
      // Range 2: 0.2-0.4 (Mostly myth)
      range2: [
        'The Fountain of Youth',
        'The Loch Ness Monster',
        'Bigfoot',
        'The lost city of Atlantis'
      ],
      // Range 3: 0.4-0.6 (Neutral/Mixed)
      range3: [
        'Robin Hood',
        'The Rosetta Stone',
        'Hieroglyphics',
        'The Trojan Horse'
      ],
      // Range 4: 0.6-0.8 (Mostly history)
      range4: [
        'A black-and-white photograph',
        'A museum display',
        'An ancient coin',
        'A pyramid'
      ],
      // Range 5: 0.8-1.0 (HISTORY side)
      range5: [
        'A fossil',
        'A birth certificate',
        'A newspaper headline',
        'Security camera footage'
      ],
    ),

    // ═══════════════════════════════════════════════════════════
    // BUNDLE.FOOD - Categories  
    // ═══════════════════════════════════════════════════════════

    'hungry_satiated': CategoryClueSet(
      // Range 1: 0.0-0.2 (HUNGRY side)
      range1: [
        'Stomach rumbling',
        'Opening the fridge',
        'Looking at a menu',
        'A vending machine'
      ],
      // Range 2: 0.2-0.4 (Mostly hungry)
      range2: [
        'A lunch break',
        'Grocery shopping',
        'Watching a cooking show',
        '"What\'s for dinner?"'
      ],
      // Range 3: 0.4-0.6 (Neutral/Satisfied)
      range3: [
        'A doggy bag',
        'A lunchbox',
        '"Just a coffee, thanks"',
        'Cleaning your plate'
      ],
      // Range 4: 0.6-0.8 (Mostly satiated)
      range4: [
        'Loosening your belt',
        'A food coma',
        'Declining dessert',
        'Patting your belly'
      ],
      // Range 5: 0.8-1.0 (SATIATED side)
      range5: [
        'A nap',
        'Black tea',
        'A toothpick',
        '"I couldn\'t eat another bite"'
      ],
    ),

    'spicy_mild': CategoryClueSet(
      // Range 1: 0.0-0.2 (SPICY side)
      range1: [
        'A glass of milk',
        'Tears in your eyes',
        'Sweating',
        'A fire extinguisher'
      ],
      // Range 2: 0.2-0.4 (Mostly spicy)
      range2: [
        'A warning label',
        'Needing a drink',
        'A red chili pepper icon',
        'Fanning your mouth'
      ],
      // Range 3: 0.4-0.6 (Neutral/Balanced)
      range3: [
        'Ketchup',
        'A pinch of salt',
        'Cinnamon',
        'Ginger'
      ],
      // Range 4: 0.6-0.8 (Mostly mild)
      range4: [
        'A saltine cracker',
        'Chicken noodle soup',
        'Oatmeal',
        'A baby spoon'
      ],
      // Range 5: 0.8-1.0 (MILD side)
      range5: [
        'A glass of water',
        'An ice cube',
        'A doctor\'s recommendation',
        'Fasting'
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
