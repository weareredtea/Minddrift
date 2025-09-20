// lib/data/practice_clue_data.dart

/// Organized clue database for Practice Mode
/// Easy to edit and expand - just add more clues to any range
/// 
/// Structure: 4 categories × 5 ranges × 4 clues = 80 total clues
/// User Experience: 4 categories × 5 ranges = 20 unique challenges
/// Supports: English and Arabic localization

class LocalizedClueSet {
  final List<String> english;
  final List<String> arabic;

  const LocalizedClueSet({
    required this.english,
    required this.arabic,
  });

  List<String> getClues(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return arabic;
      case 'en':
      default:
        return english;
    }
  }
}

class CategoryClueSet {
  final LocalizedClueSet range1; // 0.0-0.2 (Left extreme)
  final LocalizedClueSet range2; // 0.2-0.4
  final LocalizedClueSet range3; // 0.4-0.6 (Center)
  final LocalizedClueSet range4; // 0.6-0.8
  final LocalizedClueSet range5; // 0.8-1.0 (Right extreme)

  const CategoryClueSet({
    required this.range1,
    required this.range2,
    required this.range3,
    required this.range4,
    required this.range5,
  });

  List<String> getRangeClues(int range, String languageCode) {
    switch (range) {
      case 1: return range1.getClues(languageCode);
      case 2: return range2.getClues(languageCode);
      case 3: return range3.getClues(languageCode);
      case 4: return range4.getClues(languageCode);
      case 5: return range5.getClues(languageCode);
      default: return range3.getClues(languageCode); // Default to center
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
      range1: LocalizedClueSet(
        english: [
          'A puff of smoke',
          'Abracadabra',
          'A magic wand',
          'A crystal ball'
        ],
        arabic: [
          'نفخة دخان',
          'أبرا كادابرا',
          'عصا سحرية',
          'كرة بلورية'
        ],
      ),
      // Range 2: 0.2-0.4 (Mostly magic)
      range2: LocalizedClueSet(
        english: [
          'A four-leaf clover',
          'Knocking on wood',
          'Making a wish',
          'A tarot card'
        ],
        arabic: [
          'برسيم رباعي الأوراق',
          'الطرق على الخشب',
          'تمني أمنية',
          'بطاقة تاروت'
        ],
      ),
      // Range 3: 0.4-0.6 (Neutral/Mixed)
      range3: LocalizedClueSet(
        english: [
          'Alchemy',
          'Hypnosis',
          'Déjà vu',
          'The placebo effect'
        ],
        arabic: [
          'الكيمياء القديمة',
          'تنويم مغناطيسي',
          'شعور سابق',
          'تأثير الدواء الوهمي'
        ],
      ),
      // Range 4: 0.6-0.8 (Mostly science)
      range4: LocalizedClueSet(
        english: [
          'A lightbulb',
          'A blueprint',
          'An antibiotic',
          'A smartphone'
        ],
        arabic: [
          'مصباح كهربائي',
          'مخطط هندسي',
          'مضاد حيوي',
          'هاتف ذكي'
        ],
      ),
      // Range 5: 0.8-1.0 (SCIENCE side)
      range5: LocalizedClueSet(
        english: [
          'A lab coat',
          'E = mc²',
          'A microscope',
          'DNA'
        ],
        arabic: [
          'معطف المختبر',
          'E = mc²',
          'ميكروسكوب',
          'الحمض النووي'
        ],
      ),
    ),

    'myth_history': CategoryClueSet(
      // Range 1: 0.0-0.2 (MYTH side)
      range1: LocalizedClueSet(
        english: [
          'A unicorn',
          'Zeus',
          'The Fountain of Youth',
          'Dragons'
        ],
        arabic: [
          'وحيد القرن',
          'زيوس',
          'نافورة الشباب',
          'التنانين'
        ],
      ),
      // Range 2: 0.2-0.4 (Mostly myth)
      range2: LocalizedClueSet(
        english: [
          'The Fountain of Youth',
          'The Loch Ness Monster',
          'Bigfoot',
          'The lost city of Atlantis'
        ],
        arabic: [
          'نافورة الشباب',
          'وحش بحيرة نيس',
          'القدم الكبيرة',
          'مدينة أطلانطس المفقودة'
        ],
      ),
      // Range 3: 0.4-0.6 (Neutral/Mixed)
      range3: LocalizedClueSet(
        english: [
          'The Trojan War',
          'King Arthur',
          'Atlantis',
          'Robin Hood'
        ],
        arabic: [
          'حرب طروادة',
          'الملك آرثر',
          'أطلانطس',
          'روبن هود'
        ],
      ),
      // Range 4: 0.6-0.8 (Mostly history)
      range4: LocalizedClueSet(
        english: [
          'A black-and-white photograph',
          'A museum display',
          'An ancient coin',
          'A pyramid'
        ],
        arabic: [
          'صورة بالأبيض والأسود',
          'عرض متحف',
          'عملة قديمة',
          'هرم'
        ],
      ),
      // Range 5: 0.8-1.0 (HISTORY side)
      range5: LocalizedClueSet(
        english: [
          'The pyramids of Giza',
          'World War II',
          'The printing press',
          'Julius Caesar'
        ],
        arabic: [
          'أهرامات الجيزة',
          'الحرب العالمية الثانية',
          'المطبعة',
          'يوليوس قيصر'
        ],
      ),
    ),

    // ═══════════════════════════════════════════════════════════
    // BUNDLE.FOOD - Categories  
    // ═══════════════════════════════════════════════════════════

    'hungry_satiated': CategoryClueSet(
      // Range 1: 0.0-0.2 (HUNGRY side)
      range1: LocalizedClueSet(
        english: [
          'Stomach rumbling',
          'Opening the fridge',
          'Looking at a menu',
          'A vending machine'
        ],
        arabic: [
          'قرقرة المعدة',
          'فتح الثلاجة',
          'النظر في القائمة',
          'آلة البيع'
        ],
      ),
      // Range 2: 0.2-0.4 (Mostly hungry)
      range2: LocalizedClueSet(
        english: [
          'A lunch break',
          'Grocery shopping',
          'Watching a cooking show',
          '"What\'s for dinner?"'
        ],
        arabic: [
          'استراحة غداء',
          'تسوق البقالة',
          'مشاهدة برنامج طبخ',
          '"ماذا سنتناول على العشاء؟"'
        ],
      ),
      // Range 3: 0.4-0.6 (Neutral/Satisfied)
      range3: LocalizedClueSet(
        english: [
          'A doggy bag',
          'A lunchbox',
          '"Just a coffee, thanks"',
          'Cleaning your plate'
        ],
        arabic: [
          'كيس بقايا الطعام',
          'صندوق غداء',
          '"قهوة فقط، شكراً"',
          'تنظيف الطبق'
        ],
      ),
      // Range 4: 0.6-0.8 (Mostly satiated)
      range4: LocalizedClueSet(
        english: [
          'Loosening your belt',
          'A food coma',
          'Declining dessert',
          'Patting your belly'
        ],
        arabic: [
          'فك الحزام',
          'غيبوبة الطعام',
          'رفض الحلوى',
          'ربت على البطن'
        ],
      ),
      // Range 5: 0.8-1.0 (SATIATED side)
      range5: LocalizedClueSet(
        english: [
          'A nap',
          'Black tea',
          'A toothpick',
          '"I couldn\'t eat another bite"'
        ],
        arabic: [
          'قيلولة',
          'شاي أسود',
          'عود أسنان',
          '"لا أستطيع أكل قضمة أخرى"'
        ],
      ),
    ),

    'spicy_mild': CategoryClueSet(
      // Range 1: 0.0-0.2 (SPICY side)
      range1: LocalizedClueSet(
        english: [
          'A glass of milk',
          'Tears in your eyes',
          'Sweating',
          'A fire extinguisher'
        ],
        arabic: [
          'كوب حليب',
          'دموع في العينين',
          'تعرق',
          'طفاية حريق'
        ],
      ),
      // Range 2: 0.2-0.4 (Mostly spicy)
      range2: LocalizedClueSet(
        english: [
          'A warning label',
          'Needing a drink',
          'A red chili pepper icon',
          'Fanning your mouth'
        ],
        arabic: [
          'ملصق تحذير',
          'الحاجة لمشروب',
          'أيقونة فلفل أحمر',
          'تهوية الفم'
        ],
      ),
      // Range 3: 0.4-0.6 (Neutral/Balanced)
      range3: LocalizedClueSet(
        english: [
          'Ketchup',
          'A pinch of salt',
          'Cinnamon',
          'Ginger'
        ],
        arabic: [
          'كاتشب',
          'رشة ملح',
          'قرفة',
          'زنجبيل'
        ],
      ),
      // Range 4: 0.6-0.8 (Mostly mild)
      range4: LocalizedClueSet(
        english: [
          'A saltine cracker',
          'Chicken noodle soup',
          'Oatmeal',
          'A baby spoon'
        ],
        arabic: [
          'بسكويت مالح',
          'شوربة دجاج بالشعيرية',
          'شوفان',
          'ملعقة أطفال'
        ],
      ),
      // Range 5: 0.8-1.0 (MILD side)
      range5: LocalizedClueSet(
        english: [
          'A glass of water',
          'An ice cube',
          'A doctor\'s recommendation',
          'Fasting'
        ],
        arabic: [
          'كوب ماء',
          'مكعب ثلج',
          'توصية طبيب',
          'صيام'
        ],
      ),
    ),
  };

  /// Get clue for specific category and range
  static List<String> getCluePool(String categoryId, int range, [String languageCode = 'en']) {
    final categoryClues = clues[categoryId];
    if (categoryClues == null) {
      throw ArgumentError('Category $categoryId not found in practice database');
    }
    return categoryClues.getRangeClues(range, languageCode);
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
