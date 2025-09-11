// lib/data/category_data.dart

/// Simple model to hold your category info with localization support.
class CategoryItem {
  final String id;
  final dynamic left;  // Can be String (old format) or Map<String, String> (new format)
  final dynamic right; // Can be String (old format) or Map<String, String> (new format)
  final String bundleId;

  const CategoryItem({
    required this.id,
    required this.left,
    required this.right,
    required this.bundleId,
  });

  // Helper methods for localization
  String getLeftText(String languageCode) {
    if (left is Map<String, String>) {
      return (left as Map<String, String>)[languageCode] ?? (left as Map<String, String>)['en'] ?? '';
    }
    return left as String;
  }
  
  String getRightText(String languageCode) {
    if (right is Map<String, String>) {
      return (right as Map<String, String>)[languageCode] ?? (right as Map<String, String>)['en'] ?? '';
    }
    return right as String;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'left': left,
        'right': right,
        'bundleId': bundleId,
      };
}

/// Your full catalog: 10 free, 20 horror, 20 kids, etc.
/// Your full catalog: 10 free, 20 horror, 20 kids, 20 food, 20 nature, 20 fantasy
const List<CategoryItem> allCategories = [
  // ─── Free Bundle (10) ───
  CategoryItem(
    id: 'hot_cold',
    left: {'en': 'HOT', 'ar': 'ساخن'},
    right: {'en': 'COLD', 'ar': 'بارد'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'day_night',
    left: {'en': 'DAY', 'ar': 'نهار'},
    right: {'en': 'NIGHT', 'ar': 'ليل'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'happy_sad',
    left: {'en': 'HAPPY', 'ar': 'سعيد'},
    right: {'en': 'SAD', 'ar': 'حزين'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'big_small',
    left: {'en': 'BIG', 'ar': 'كبير'},
    right: {'en': 'SMALL', 'ar': 'صغير'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'young_old',
    left: {'en': 'YOUNG', 'ar': 'شاب'},
    right: {'en': 'OLD', 'ar': 'عجوز'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'fast_slow',
    left: {'en': 'FAST', 'ar': 'سريع'},
    right: {'en': 'SLOW', 'ar': 'بطيء'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'sweet_sour',
    left: {'en': 'SWEET', 'ar': 'حلو'},
    right: {'en': 'SOUR', 'ar': 'حامض'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'rich_poor',
    left: {'en': 'RICH', 'ar': 'غني'},
    right: {'en': 'POOR', 'ar': 'فقير'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'soft_hard',
    left: {'en': 'SOFT', 'ar': 'ناعم'},
    right: {'en': 'HARD', 'ar': 'قاسي'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'near_far',
    left: {'en': 'NEAR', 'ar': 'قريب'},
    right: {'en': 'FAR', 'ar': 'بعيد'},
    bundleId: 'bundle.free',
  ),

  // ─── Horror Bundle (20) ───
  CategoryItem(
    id: 'darkness_light',
    left: {'en': 'DARKNESS', 'ar': 'ظلام'},
    right: {'en': 'LIGHT', 'ar': 'نور'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'silence_noise',
    left: {'en': 'SILENCE', 'ar': 'صمت'},
    right: {'en': 'NOISE', 'ar': 'ضوضاء'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'danger_safety',
    left: {'en': 'DANGER', 'ar': 'خطر'},
    right: {'en': 'SAFETY', 'ar': 'أمان'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'pain_pleasure',
    left: {'en': 'PAIN', 'ar': 'ألم'},
    right: {'en': 'PLEASURE', 'ar': 'متعة'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'chaos_order',
    left: {'en': 'CHAOS', 'ar': 'فوضى'},
    right: {'en': 'ORDER', 'ar': 'نظام'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'supernatural_natural',
    left: {'en': 'SUPERNATURAL', 'ar': 'خارق للطبيعة'},
    right: {'en': 'NATURAL', 'ar': 'طبيعي'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'deadly_harmless',
    left: {'en': 'DEADLY', 'ar': 'قاتل'},
    right: {'en': 'HARMLESS', 'ar': 'غير مؤذٍ'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'scary_funny',
    left: {'en': 'SCARY', 'ar': 'مرعب'},
    right: {'en': 'FUNNY', 'ar': 'مضحك'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'graphic_subtle',
    left: {'en': 'GRAPHIC', 'ar': 'صريح'},
    right: {'en': 'SUBTLE', 'ar': 'ضمني'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'survivable_unsurvivable',
    left: {'en': 'SURVIVABLE', 'ar': 'يمكن النجاة منه'},
    right: {'en': 'UNSURVIVABLE', 'ar': 'لا يمكن النجاة منه'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'rational_fear_irrational_fear',
    left: {'en': 'RATIONAL FEAR', 'ar': 'خوف منطقي'},
    right: {'en': 'IRRATIONAL FEAR', 'ar': 'خوف غير منطقي'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'safe_place_dangerous_place',
    left: {'en': 'SAFE PLACE', 'ar': 'مكان آمن'},
    right: {'en': 'DANGEROUS PLACE', 'ar': 'مكان خطير'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'helpful_object_useless_object',
    left: {'en': 'HELPFUL OBJECT', 'ar': 'أداة مفيدة'},
    right: {'en': 'USELESS OBJECT', 'ar': 'أداة عديمة الفائدة'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'curse_blessing',
    left: {'en': 'CURSE', 'ar': 'لعنة'},
    right: {'en': 'BLESSING', 'ar': 'بركة'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'guilt_innocence',
    left: {'en': 'GUILT', 'ar': 'ذنب'},
    right: {'en': 'INNOCENCE', 'ar': 'براءة'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'known_unknown',
    left: {'en': 'KNOWN', 'ar': 'معروف'},
    right: {'en': 'UNKNOWN', 'ar': 'مجهول'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'predictable_unpredictable',
    left: {'en': 'PREDICTABLE', 'ar': 'متوقع'},
    right: {'en': 'UNPREDICTABLE', 'ar': 'غير متوقع'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'fast_zombie_slow_zombie',
    left: {'en': 'FAST ZOMBIE', 'ar': 'زومبي سريع'},
    right: {'en': 'SLOW ZOMBIE', 'ar': 'زومبي بطيء'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'alone_in_a_crowd',
    left: {'en': 'ALONE', 'ar': 'وحيد'},
    right: {'en': 'IN A CROWD', 'ar': 'وسط حشد'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'explainable_unexplainable',
    left: {'en': 'EXPLAINABLE', 'ar': 'يمكن تفسيره'},
    right: {'en': 'UNEXPLAINABLE', 'ar': 'لا يمكن تفسيره'},
    bundleId: 'bundle.horror',
  ),

  // ─── Kids Bundle (20) ───
  CategoryItem(
    id: 'awake_asleep',
    left: {'en': 'AWAKE', 'ar': 'مستيقظ'},
    right: {'en': 'ASLEEP', 'ar': 'نائم'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'loud_quiet',
    left: {'en': 'LOUD', 'ar': 'صاخب'},
    right: {'en': 'QUIET', 'ar': 'هادئ'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'bright_dim',
    left: {'en': 'BRIGHT', 'ar': 'مضيء'},
    right: {'en': 'DIM', 'ar': 'خافت'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'full_empty',
    left: {'en': 'FULL', 'ar': 'ممتلئ'},
    right: {'en': 'EMPTY', 'ar': 'فارغ'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'thick_thin',
    left: {'en': 'THICK', 'ar': 'سميك'},
    right: {'en': 'THIN', 'ar': 'رفيع'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'smooth_rough',
    left: {'en': 'SMOOTH', 'ar': 'ناعم'},
    right: {'en': 'ROUGH', 'ar': 'خشن'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'high_low',
    left: {'en': 'HIGH', 'ar': 'عالي'},
    right: {'en': 'LOW', 'ar': 'منخفض'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'early_late',
    left: {'en': 'EARLY', 'ar': 'مبكر'},
    right: {'en': 'LATE', 'ar': 'متأخر'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'start_end',
    left: {'en': 'START', 'ar': 'بداية'},
    right: {'en': 'END', 'ar': 'نهاية'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'open_closed',
    left: {'en': 'OPEN', 'ar': 'مفتوح'},
    right: {'en': 'CLOSED', 'ar': 'مغلق'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'inside_outside',
    left: {'en': 'INSIDE', 'ar': 'داخل'},
    right: {'en': 'OUTSIDE', 'ar': 'خارج'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'above_below',
    left: {'en': 'ABOVE', 'ar': 'فوق'},
    right: {'en': 'BELOW', 'ar': 'تحت'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'front_back',
    left: {'en': 'FRONT', 'ar': 'أمام'},
    right: {'en': 'BACK', 'ar': 'خلف'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'broad_narrow',
    left: {'en': 'BROAD', 'ar': 'واسع'},
    right: {'en': 'NARROW', 'ar': 'ضيق'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'single_multiple',
    left: {'en': 'SINGLE', 'ar': 'واحد'},
    right: {'en': 'MULTIPLE', 'ar': 'متعدد'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'shallow_deep',
    left: {'en': 'SHALLOW', 'ar': 'ضحل'},
    right: {'en': 'DEEP', 'ar': 'عميق'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'polite_rude',
    left: {'en': 'POLITE', 'ar': 'مهذب'},
    right: {'en': 'RUDE', 'ar': 'وقح'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'clean_dirty',
    left: {'en': 'CLEAN', 'ar': 'نظيف'},
    right: {'en': 'DIRTY', 'ar': 'قذر'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'together_apart',
    left: {'en': 'TOGETHER', 'ar': 'معاً'},
    right: {'en': 'APART', 'ar': 'منفصل'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'soon_later',
    left: {'en': 'SOON', 'ar': 'قريباً'},
    right: {'en': 'LATER', 'ar': 'لاحقاً'},
    bundleId: 'bundle.kids',
  ),

  // ─── Food Bundle (20) ───
  CategoryItem(
    id: 'hungry_satiated',
    left: {'en': 'HUNGRY', 'ar': 'جائع'},
    right: {'en': 'SATIATED', 'ar': 'شبعان'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'thirsty_hydrated',
    left: {'en': 'THIRSTY', 'ar': 'عطشان'},
    right: {'en': 'HYDRATED', 'ar': 'مرتوي'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'raw_cooked',
    left: {'en': 'RAW', 'ar': 'نيء'},
    right: {'en': 'COOKED', 'ar': 'مطبوخ'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'fresh_stale',
    left: {'en': 'FRESH', 'ar': 'طازج'},
    right: {'en': 'STALE', 'ar': 'فاسد'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'spicy_mild',
    left: {'en': 'SPICY', 'ar': 'حار'},
    right: {'en': 'MILD', 'ar': 'خفيف'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'salty_bland',
    left: {'en': 'SALTY', 'ar': 'مالح'},
    right: {'en': 'BLAND', 'ar': 'فاتر'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'bitter_sweet',
    left: {'en': 'BITTER', 'ar': 'مر'},
    right: {'en': 'SWEET', 'ar': 'حلو'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'dense_airy',
    left: {'en': 'DENSE', 'ar': 'كثيف'},
    right: {'en': 'AIRY', 'ar': 'خفيف'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'rich_plain',
    left: {'en': 'RICH', 'ar': 'غني'},
    right: {'en': 'PLAIN', 'ar': 'بسيط'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'heavy_light',
    left: {'en': 'HEAVY', 'ar': 'ثقيل'},
    right: {'en': 'LIGHT', 'ar': 'خفيف'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'crunchy_tender',
    left: {'en': 'CRUNCHY', 'ar': 'مقرمش'},
    right: {'en': 'TENDER', 'ar': 'طري'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'organic_processed',
    left: {'en': 'ORGANIC', 'ar': 'عضوي'},
    right: {'en': 'PROCESSED', 'ar': 'مصنع'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'plentiful_scarce',
    left: {'en': 'PLENTIFUL', 'ar': 'وفير'},
    right: {'en': 'SCARCE', 'ar': 'نادر'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'subtle_intense',
    left: {'en': 'SUBTLE', 'ar': 'خافت'},
    right: {'en': 'INTENSE', 'ar': 'قوي'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'fatty_lean',
    left: {'en': 'FATTY', 'ar': 'دهني'},
    right: {'en': 'LEAN', 'ar': 'قليل الدهن'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'delicious_disgusting',
    left: {'en': 'DELICIOUS', 'ar': 'لذيذ'},
    right: {'en': 'DISGUSTING', 'ar': 'مقرف'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'healthy_unhealthy',
    left: {'en': 'HEALTHY', 'ar': 'صحي'},
    right: {'en': 'UNHEALTHY', 'ar': 'غير صحي'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'natural_artificial',
    left: {'en': 'NATURAL', 'ar': 'طبيعي'},
    right: {'en': 'ARTIFICIAL', 'ar': 'اصطناعي'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'appealing_unappealing',
    left: {'en': 'APPEALING', 'ar': 'جذاب'},
    right: {'en': 'UNAPPEALING', 'ar': 'غير جذاب'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'balanced_unbalanced',
    left: {'en': 'BALANCED', 'ar': 'متوازن'},
    right: {'en': 'UNBALANCED', 'ar': 'غير متوازن'},
    bundleId: 'bundle.food',
  ),

  // ─── Nature Bundle (20) ───
  CategoryItem(
    id: 'pure_contaminated',
    left: {'en': 'PURE', 'ar': 'نقي'},
    right: {'en': 'CONTAMINATED', 'ar': 'ملوث'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'wet_dry',
    left: {'en': 'WET', 'ar': 'رطب'},
    right: {'en': 'DRY', 'ar': 'جاف'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'fertile_barren',
    left: {'en': 'FERTILE', 'ar': 'خصب'},
    right: {'en': 'BARREN', 'ar': 'عقيم'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'growth_decay',
    left: {'en': 'GROWTH', 'ar': 'نمو'},
    right: {'en': 'DECAY', 'ar': 'تحلل'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'calm_stormy',
    left: {'en': 'CALM', 'ar': 'هادئ'},
    right: {'en': 'STORMY', 'ar': 'عاصف'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'tame_wild',
    left: {'en': 'TAME', 'ar': 'أليف'},
    right: {'en': 'WILD', 'ar': 'بري'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'natural_man_made',
    left: {'en': 'NATURAL', 'ar': 'طبيعي'},
    right: {'en': 'MAN-MADE', 'ar': 'من صنع الإنسان'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'resilient_fragile',
    left: {'en': 'RESILIENT', 'ar': 'مرن'},
    right: {'en': 'FRAGILE', 'ar': 'هش'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'dangerous_animal_harmless_animal',
    left: {'en': 'DANGEROUS ANIMAL', 'ar': 'حيوان خطير'},
    right: {'en': 'HARMLESS ANIMAL', 'ar': 'حيوان غير مؤذٍ'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'seasonal_permanent',
    left: {'en': 'SEASONAL', 'ar': 'موسمي'},
    right: {'en': 'PERMANENT', 'ar': 'دائم'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'predator_prey',
    left: {'en': 'PREDATOR', 'ar': 'مفترس'},
    right: {'en': 'PREY', 'ar': 'فريسة'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'radiant_dim',
    left: {'en': 'RADIANT', 'ar': 'مشع'},
    right: {'en': 'DIM', 'ar': 'خافت'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'verdant_arid',
    left: {'en': 'VERDANT', 'ar': 'أخضر'},
    right: {'en': 'ARID', 'ar': 'قاحل'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'connected_isolated',
    left: {'en': 'CONNECTED', 'ar': 'متصل'},
    right: {'en': 'ISOLATED', 'ar': 'منعزل'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'symphony_of_nature_dead_silent',
    left: {'en': 'SYMPHONY OF NATURE', 'ar': 'سمفونية الطبيعة'},
    right: {'en': 'DEAD SILENT', 'ar': 'صمت مطبق'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'beautiful_view_ugly_view',
    left: {'en': 'BEAUTIFUL VIEW', 'ar': 'منظر جميل'},
    right: {'en': 'UGLY VIEW', 'ar': 'منظر قبيح'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'accessible_remote',
    left: {'en': 'ACCESSIBLE', 'ar': 'سهل الوصول'},
    right: {'en': 'REMOTE', 'ar': 'نائي'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'inviting_water_dangerous_water',
    left: {'en': 'INVITING WATER', 'ar': 'مياه جذابة'},
    right: {'en': 'DANGEROUS WATER', 'ar': 'مياه خطرة'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'thriving_dying',
    left: {'en': 'THRIVING', 'ar': 'مزدهر'},
    right: {'en': 'DYING', 'ar': 'يحتضر'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'evolving_stagnant',
    left: {'en': 'EVOLVING', 'ar': 'متطور'},
    right: {'en': 'STAGNANT', 'ar': 'راكد'},
    bundleId: 'bundle.nature',
  ),

  // ─── Fantasy Bundle (20) ───
  CategoryItem(
    id: 'illusion_reality',
    left: {'en': 'ILLUSION', 'ar': 'وهم'},
    right: {'en': 'REALITY', 'ar': 'واقع'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'prophecy_chance',
    left: {'en': 'PROPHECY', 'ar': 'نبوءة'},
    right: {'en': 'CHANCE', 'ar': 'صدفة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'magic_science',
    left: {'en': 'MAGIC', 'ar': 'سحر'},
    right: {'en': 'SCIENCE', 'ar': 'علم'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'creation_destruction',
    left: {'en': 'CREATION', 'ar': 'خلق'},
    right: {'en': 'DESTRUCTION', 'ar': 'دمار'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'myth_history',
    left: {'en': 'MYTH', 'ar': 'أسطورة'},
    right: {'en': 'HISTORY', 'ar': 'تاريخ'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'miracle_curse',
    left: {'en': 'MIRACLE', 'ar': 'معجزة'},
    right: {'en': 'CURSE', 'ar': 'لعنة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'legendary_weapon_common_weapon',
    left: {'en': 'LEGENDARY WEAPON', 'ar': 'سلاح أسطوري'},
    right: {'en': 'COMMON WEAPON', 'ar': 'سلاح شائع'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'power_weakness',
    left: {'en': 'POWER', 'ar': 'قوة'},
    right: {'en': 'WEAKNESS', 'ar': 'ضعف'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'victory_defeat',
    left: {'en': 'VICTORY', 'ar': 'انتصار'},
    right: {'en': 'DEFEAT', 'ar': 'هزيمة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'trust_betrayal',
    left: {'en': 'TRUST', 'ar': 'ثقة'},
    right: {'en': 'BETRAYAL', 'ar': 'خيانة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'wonder_doubt',
    left: {'en': 'WONDER', 'ar': 'عجب'},
    right: {'en': 'DOUBT', 'ar': 'شك'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'high_fantasy_low_fantasy',
    left: {'en': 'HIGH FANTASY', 'ar': 'خيال عالي'},
    right: {'en': 'LOW FANTASY', 'ar': 'خيال منخفض'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'good_king_evil_tyrant',
    left: {'en': 'GOOD KING', 'ar': 'ملك صالح'},
    right: {'en': 'EVIL TYRANT', 'ar': 'طاغية شرير'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'forbidden_allowed',
    left: {'en': 'FORBIDDEN', 'ar': 'محظور'},
    right: {'en': 'ALLOWED', 'ar': 'مسموح'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'clearly_good_morally_grey',
    left: {'en': 'CLEARLY GOOD', 'ar': 'خيّر بوضوح'},
    right: {'en': 'MORALLY GREY', 'ar': 'رمادي أخلاقياً'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'heroism_cowardice',
    left: {'en': 'HEROISM', 'ar': 'بطولة'},
    right: {'en': 'COWARDICE', 'ar': 'جبن'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'wisdom_foolishness',
    left: {'en': 'WISDOM', 'ar': 'حكمة'},
    right: {'en': 'FOOLISHNESS', 'ar': 'حماقة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'useful_spell_useless_spell',
    left: {'en': 'USEFUL SPELL', 'ar': 'تعويذة مفيدة'},
    right: {'en': 'USELESS SPELL', 'ar': 'تعويذة عديمة الفائدة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'simple_quest_epic_journey',
    left: {'en': 'SIMPLE QUEST', 'ar': 'مهمة بسيطة'},
    right: {'en': 'EPIC JOURNEY', 'ar': 'رحلة ملحمية'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'rare_common',
    left: {'en': 'RARE', 'ar': 'نادر'},
    right: {'en': 'COMMON', 'ar': 'شائع'},
    bundleId: 'bundle.fantasy',
  ),
];
