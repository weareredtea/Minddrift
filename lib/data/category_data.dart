// lib/data/category_data.dart

/// Simple model to hold your category info with localization support.
class CategoryItem {
  final String id;
  // NEW semantics (preferred): positive (left pole) and negative (right pole)
  final Map<String, String>? positive;
  final Map<String, String>? negative;
  // Backward compatibility with existing data: left/right
  final dynamic left;  // String or Map<String,String>
  final dynamic right; // String or Map<String,String>
  final String bundleId;

  const CategoryItem({
    required this.id,
    this.positive,
    this.negative,
    this.left,
    this.right,
    required this.bundleId,
  });

  // Helper methods for localization with graceful fallback
  String getPositiveText(String languageCode) {
    if (positive != null) {
      return positive![languageCode] ?? positive!['en'] ?? '';
    }
    // Fallback to legacy left
    if (left is Map<String, String>) {
      return (left as Map<String, String>)[languageCode] ?? (left as Map<String, String>)['en'] ?? '';
    }
    return (left as String?) ?? '';
  }
  
  String getNegativeText(String languageCode) {
    if (negative != null) {
      return negative![languageCode] ?? negative!['en'] ?? '';
    }
    // Fallback to legacy right
    if (right is Map<String, String>) {
      return (right as Map<String, String>)[languageCode] ?? (right as Map<String, String>)['en'] ?? '';
    }
    return (right as String?) ?? '';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        if (positive != null) 'positive': positive,
        if (negative != null) 'negative': negative,
        if (left != null) 'left': left,
        if (right != null) 'right': right,
        'bundleId': bundleId,
      };
}

/// Your full catalog: 10 free, 20 horror, 20 kids, etc.
/// Your full catalog: 10 free, 20 horror, 20 kids, 20 food, 20 nature, 20 fantasy
const List<CategoryItem> allCategories = [
  // ─── Free Bundle (Standardized) ───
  CategoryItem(
    id: 'hot_cold', // Positive (Cold/passive) vs. Negative (Hot/active)
    positive: {'en': 'COLD', 'ar': 'بارد'},
    negative: {'en': 'HOT', 'ar': 'ساخن'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'day_night', // Positive (Day/active) vs. Negative (Night/passive)
    positive: {'en': 'DAY', 'ar': 'نهار'},
    negative: {'en': 'NIGHT', 'ar': 'ليل'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'sad_happy', // Positive (Happy/pleasant) vs. Negative (Sad/aversive)
    positive: {'en': 'HAPPY', 'ar': 'سعيد'},
    negative: {'en': 'SAD', 'ar': 'حزين'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'small_big', // Positive (Big/more) vs. Negative (Small/less)
    positive: {'en': 'BIG', 'ar': 'كبير'},
    negative: {'en': 'SMALL', 'ar': 'صغير'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'young_old', // Positive (Young/beginning) vs. Negative (Old/end)
    positive: {'en': 'YOUNG', 'ar': 'شاب'},
    negative: {'en': 'OLD', 'ar': 'عجوز'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'fast_slow', // Positive (Fast/active) vs. Negative (Slow/passive)
    positive: {'en': 'FAST', 'ar': 'سريع'},
    negative: {'en': 'SLOW', 'ar': 'بطيء'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'sour_sweet', // Positive (Sweet/pleasant) vs. Negative (Sour/aversive)
    positive: {'en': 'SWEET', 'ar': 'حلو'},
    negative: {'en': 'SOUR', 'ar': 'حامض'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'poor_rich', // Positive (Rich/more) vs. Negative (Poor/less)
    positive: {'en': 'RICH', 'ar': 'غني'},
    negative: {'en': 'POOR', 'ar': 'فقير'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'hard_soft', // Positive (Soft/yielding) vs. Negative (Hard/resistant)
    positive: {'en': 'SOFT', 'ar': 'ناعم'},
    negative: {'en': 'HARD', 'ar': 'قاسي'},
    bundleId: 'bundle.free',
  ),
  CategoryItem(
    id: 'near_far', // Positive (Near/close) vs. Negative (Far/distant)
    positive: {'en': 'NEAR', 'ar': 'قريب'},
    negative: {'en': 'FAR', 'ar': 'بعيد'},
    bundleId: 'bundle.free',
  ),

  // ─── Horror Bundle (20) ───
  CategoryItem(
    id: 'darkness_light',
    positive: {'en': 'LIGHT', 'ar': 'نور'},
    negative: {'en': 'DARKNESS', 'ar': 'ظلام'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'silence_noise',
    positive: {'en': 'SILENCE', 'ar': 'صمت'},
    negative: {'en': 'NOISE', 'ar': 'ضوضاء'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'danger_safety',
    positive: {'en': 'SAFETY', 'ar': 'أمان'},
    negative: {'en': 'DANGER', 'ar': 'خطر'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'pain_pleasure',
    positive: {'en': 'PLEASURE', 'ar': 'متعة'},
    negative: {'en': 'PAIN', 'ar': 'ألم'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'chaos_order',
    positive: {'en': 'ORDER', 'ar': 'نظام'},
    negative: {'en': 'CHAOS', 'ar': 'فوضى'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'supernatural_natural',
    positive: {'en': 'NATURAL', 'ar': 'طبيعي'},
    negative: {'en': 'SUPERNATURAL', 'ar': 'خارق للطبيعة'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'deadly_harmless',
    positive: {'en': 'HARMLESS', 'ar': 'غير مؤذٍ'},
    negative: {'en': 'DEADLY', 'ar': 'قاتل'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'scary_funny',
    positive: {'en': 'FUNNY', 'ar': 'مضحك'},
    negative: {'en': 'SCARY', 'ar': 'مرعب'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'graphic_subtle',
    positive: {'en': 'SUBTLE', 'ar': 'ضمني'},
    negative: {'en': 'GRAPHIC', 'ar': 'صريح'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'survivable_unsurvivable',
    positive: {'en': 'SURVIVABLE', 'ar': 'يمكن النجاة منه'},
    negative: {'en': 'UNSURVIVABLE', 'ar': 'لا يمكن النجاة منه'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'rational_fear_irrational_fear',
    positive: {'en': 'RATIONAL FEAR', 'ar': 'خوف منطقي'},
    negative: {'en': 'IRRATIONAL FEAR', 'ar': 'خوف غير منطقي'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'safe_place_dangerous_place',
    positive: {'en': 'SAFE PLACE', 'ar': 'مكان آمن'},
    negative: {'en': 'DANGEROUS PLACE', 'ar': 'مكان خطير'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'helpful_object_useless_object',
    positive: {'en': 'HELPFUL OBJECT', 'ar': 'أداة مفيدة'},
    negative: {'en': 'USELESS OBJECT', 'ar': 'أداة عديمة الفائدة'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'curse_blessing',
    positive: {'en': 'BLESSING', 'ar': 'بركة'},
    negative: {'en': 'CURSE', 'ar': 'لعنة'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'guilt_innocence',
    positive: {'en': 'INNOCENCE', 'ar': 'براءة'},
    negative: {'en': 'GUILT', 'ar': 'ذنب'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'known_unknown',
    positive: {'en': 'KNOWN', 'ar': 'معروف'},
    negative: {'en': 'UNKNOWN', 'ar': 'مجهول'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'predictable_unpredictable',
    positive: {'en': 'PREDICTABLE', 'ar': 'متوقع'},
    negative: {'en': 'UNPREDICTABLE', 'ar': 'غير متوقع'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'fast_zombie_slow_zombie',
    positive: {'en': 'FAST ZOMBIE', 'ar': 'زومبي سريع'},
    negative: {'en': 'SLOW ZOMBIE', 'ar': 'زومبي بطيء'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'alone_in_a_crowd',
    positive: {'en': 'ALONE', 'ar': 'وحيد'},
    negative: {'en': 'IN A CROWD', 'ar': 'وسط حشد'},
    bundleId: 'bundle.horror',
  ),
  CategoryItem(
    id: 'explainable_unexplainable',
    positive: {'en': 'EXPLAINABLE', 'ar': 'يمكن تفسيره'},
    negative: {'en': 'UNEXPLAINABLE', 'ar': 'لا يمكن تفسيره'},
    bundleId: 'bundle.horror',
  ),

  // ─── Kids Bundle (20) ───
  CategoryItem(
    id: 'awake_asleep',
    positive: {'en': 'AWAKE', 'ar': 'مستيقظ'},
    negative: {'en': 'ASLEEP', 'ar': 'نائم'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'loud_quiet',
    positive: {'en': 'LOUD', 'ar': 'صاخب'},
    negative: {'en': 'QUIET', 'ar': 'هادئ'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'bright_dim',
    positive: {'en': 'BRIGHT', 'ar': 'مضيء'},
    negative: {'en': 'DIM', 'ar': 'خافت'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'full_empty',
    positive: {'en': 'FULL', 'ar': 'ممتلئ'},
    negative: {'en': 'EMPTY', 'ar': 'فارغ'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'thick_thin',
    positive: {'en': 'THICK', 'ar': 'سميك'},
    negative: {'en': 'THIN', 'ar': 'رفيع'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'smooth_rough',
    positive: {'en': 'SMOOTH', 'ar': 'ناعم'},
    negative: {'en': 'ROUGH', 'ar': 'خشن'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'high_low',
    positive: {'en': 'HIGH', 'ar': 'عالي'},
    negative: {'en': 'LOW', 'ar': 'منخفض'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'early_late',
    positive: {'en': 'EARLY', 'ar': 'مبكر'},
    negative: {'en': 'LATE', 'ar': 'متأخر'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'start_end',
    positive: {'en': 'START', 'ar': 'بداية'},
    negative: {'en': 'END', 'ar': 'نهاية'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'open_closed',
    positive: {'en': 'OPEN', 'ar': 'مفتوح'},
    negative: {'en': 'CLOSED', 'ar': 'مغلق'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'inside_outside',
    positive: {'en': 'INSIDE', 'ar': 'داخل'},
    negative: {'en': 'OUTSIDE', 'ar': 'خارج'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'above_below',
    positive: {'en': 'ABOVE', 'ar': 'فوق'},
    negative: {'en': 'BELOW', 'ar': 'تحت'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'front_back',
    positive: {'en': 'FRONT', 'ar': 'أمام'},
    negative: {'en': 'BACK', 'ar': 'خلف'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'broad_narrow',
    positive: {'en': 'BROAD', 'ar': 'واسع'},
    negative: {'en': 'NARROW', 'ar': 'ضيق'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'single_multiple',
    positive: {'en': 'SINGLE', 'ar': 'واحد'},
    negative: {'en': 'MULTIPLE', 'ar': 'متعدد'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'shallow_deep',
    positive: {'en': 'SHALLOW', 'ar': 'ضحل'},
    negative: {'en': 'DEEP', 'ar': 'عميق'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'polite_rude',
    positive: {'en': 'POLITE', 'ar': 'مهذب'},
    negative: {'en': 'RUDE', 'ar': 'وقح'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'clean_dirty',
    positive: {'en': 'CLEAN', 'ar': 'نظيف'},
    negative: {'en': 'DIRTY', 'ar': 'قذر'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'together_apart',
    positive: {'en': 'TOGETHER', 'ar': 'معاً'},
    negative: {'en': 'APART', 'ar': 'منفصل'},
    bundleId: 'bundle.kids',
  ),
  CategoryItem(
    id: 'soon_later',
    positive: {'en': 'SOON', 'ar': 'قريباً'},
    negative: {'en': 'LATER', 'ar': 'لاحقاً'},
    bundleId: 'bundle.kids',
  ),

  // ─── Food Bundle (20) ───
  CategoryItem(
    id: 'hungry_satiated',
    positive: {'en': 'HUNGRY', 'ar': 'جائع'},
    negative: {'en': 'SATIATED', 'ar': 'شبعان'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'thirsty_hydrated',
    positive: {'en': 'THIRSTY', 'ar': 'عطشان'},
    negative: {'en': 'HYDRATED', 'ar': 'مرتوي'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'raw_cooked',
    positive: {'en': 'COOKED', 'ar': 'مطبوخ'},
    negative: {'en': 'RAW', 'ar': 'نيء'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'stale_fresh', // Positive (Fresh) vs. Negative (Stale)
    positive: {'en': 'FRESH', 'ar': 'طازج'},
    negative: {'en': 'STALE', 'ar': 'فاسد'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'spicy_mild',
    positive: {'en': 'SPICY', 'ar': 'حار'},
    negative: {'en': 'MILD', 'ar': 'خفيف'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'salty_bland',
    positive: {'en': 'SALTY', 'ar': 'مالح'},
    negative: {'en': 'BLAND', 'ar': 'فاتر'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'bitter_sweet', // Positive (Sweet) vs. Negative (Bitter)
    positive: {'en': 'SWEET', 'ar': 'حلو'},
    negative: {'en': 'BITTER', 'ar': 'مر'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'dense_airy',
    positive: {'en': 'DENSE', 'ar': 'كثيف'},
    negative: {'en': 'AIRY', 'ar': 'خفيف'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'plain_rich', // Positive (Rich) vs. Negative (Plain)
    positive: {'en': 'RICH', 'ar': 'غني'},
    negative: {'en': 'PLAIN', 'ar': 'بسيط'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'heavy_light',
    positive: {'en': 'HEAVY', 'ar': 'ثقيل'},
    negative: {'en': 'LIGHT', 'ar': 'خفيف'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'crunchy_tender',
    positive: {'en': 'CRUNCHY', 'ar': 'مقرمش'},
    negative: {'en': 'TENDER', 'ar': 'طري'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'organic_processed',
    positive: {'en': 'ORGANIC', 'ar': 'عضوي'},
    negative: {'en': 'PROCESSED', 'ar': 'مصنع'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'plentiful_scarce',
    positive: {'en': 'PLENTIFUL', 'ar': 'وفير'},
    negative: {'en': 'SCARCE', 'ar': 'نادر'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'subtle_intense',
    positive: {'en': 'SUBTLE', 'ar': 'خافت'},
    negative: {'en': 'INTENSE', 'ar': 'قوي'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'fatty_lean',
    positive: {'en': 'LEAN', 'ar': 'قليل الدهن'},
    negative: {'en': 'FATTY', 'ar': 'دهني'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'disgusting_delicious', // Positive (Delicious) vs. Negative (Disgusting)
    positive: {'en': 'DELICIOUS', 'ar': 'لذيذ'},
    negative: {'en': 'DISGUSTING', 'ar': 'مقرف'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'unhealthy_healthy', // Positive (Healthy) vs. Negative (Unhealthy)
    positive: {'en': 'HEALTHY', 'ar': 'صحي'},
    negative: {'en': 'UNHEALTHY', 'ar': 'غير صحي'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'artificial_natural', // Positive (Natural) vs. Negative (Artificial)
    positive: {'en': 'NATURAL', 'ar': 'طبيعي'},
    negative: {'en': 'ARTIFICIAL', 'ar': 'اصطناعي'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'unappealing_appealing', // Positive (Appealing) vs. Negative (Unappealing)
    positive: {'en': 'APPEALING', 'ar': 'جذاب'},
    negative: {'en': 'UNAPPEALING', 'ar': 'غير جذاب'},
    bundleId: 'bundle.food',
  ),
  CategoryItem(
    id: 'unbalanced_balanced', // Positive (Balanced) vs. Negative (Unbalanced)
    positive: {'en': 'BALANCED', 'ar': 'متوازن'},
    negative: {'en': 'UNBALANCED', 'ar': 'غير متوازن'},
    bundleId: 'bundle.food',
  ),

  // ─── Nature Bundle (20) ───
  CategoryItem(
    id: 'pure_contaminated',
    positive: {'en': 'PURE', 'ar': 'نقي'},
    negative: {'en': 'CONTAMINATED', 'ar': 'ملوث'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'wet_dry',
    positive: {'en': 'WET', 'ar': 'رطب'},
    negative: {'en': 'DRY', 'ar': 'جاف'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'fertile_barren',
    positive: {'en': 'FERTILE', 'ar': 'خصب'},
    negative: {'en': 'BARREN', 'ar': 'عقيم'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'growth_decay',
    positive: {'en': 'GROWTH', 'ar': 'نمو'},
    negative: {'en': 'DECAY', 'ar': 'تحلل'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'calm_stormy',
    positive: {'en': 'CALM', 'ar': 'هادئ'},
    negative: {'en': 'STORMY', 'ar': 'عاصف'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'tame_wild',
    positive: {'en': 'TAME', 'ar': 'أليف'},
    negative: {'en': 'WILD', 'ar': 'بري'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'natural_man_made',
    positive: {'en': 'NATURAL', 'ar': 'طبيعي'},
    negative: {'en': 'MAN-MADE', 'ar': 'من صنع الإنسان'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'resilient_fragile',
    positive: {'en': 'RESILIENT', 'ar': 'مرن'},
    negative: {'en': 'FRAGILE', 'ar': 'هش'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'dangerous_animal_harmless_animal',
    positive: {'en': 'DANGEROUS ANIMAL', 'ar': 'حيوان خطير'},
    negative: {'en': 'HARMLESS ANIMAL', 'ar': 'حيوان غير مؤذٍ'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'seasonal_permanent',
    positive: {'en': 'SEASONAL', 'ar': 'موسمي'},
    negative: {'en': 'PERMANENT', 'ar': 'دائم'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'predator_prey',
    positive: {'en': 'PREDATOR', 'ar': 'مفترس'},
    negative: {'en': 'PREY', 'ar': 'فريسة'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'radiant_dim',
    positive: {'en': 'RADIANT', 'ar': 'مشع'},
    negative: {'en': 'DIM', 'ar': 'خافت'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'verdant_arid',
    positive: {'en': 'VERDANT', 'ar': 'أخضر'},
    negative: {'en': 'ARID', 'ar': 'قاحل'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'connected_isolated',
    positive: {'en': 'CONNECTED', 'ar': 'متصل'},
    negative: {'en': 'ISOLATED', 'ar': 'منعزل'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'symphony_of_nature_dead_silent',
    positive: {'en': 'SYMPHONY OF NATURE', 'ar': 'سمفونية الطبيعة'},
    negative: {'en': 'DEAD SILENT', 'ar': 'صمت مطبق'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'beautiful_view_ugly_view',
    positive: {'en': 'BEAUTIFUL VIEW', 'ar': 'منظر جميل'},
    negative: {'en': 'UGLY VIEW', 'ar': 'منظر قبيح'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'accessible_remote',
    positive: {'en': 'ACCESSIBLE', 'ar': 'سهل الوصول'},
    negative: {'en': 'REMOTE', 'ar': 'نائي'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'inviting_water_dangerous_water',
    positive: {'en': 'INVITING WATER', 'ar': 'مياه جذابة'},
    negative: {'en': 'DANGEROUS WATER', 'ar': 'مياه خطرة'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'thriving_dying',
    positive: {'en': 'THRIVING', 'ar': 'مزدهر'},
    negative: {'en': 'DYING', 'ar': 'يحتضر'},
    bundleId: 'bundle.nature',
  ),
  CategoryItem(
    id: 'evolving_stagnant',
    positive: {'en': 'EVOLVING', 'ar': 'متطور'},
    negative: {'en': 'STAGNANT', 'ar': 'راكد'},
    bundleId: 'bundle.nature',
  ),

  // ─── Fantasy Bundle (20) ───
  CategoryItem(
    id: 'illusion_reality',
    positive: {'en': 'ILLUSION', 'ar': 'وهم'},
    negative: {'en': 'REALITY', 'ar': 'واقع'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'prophecy_chance',
    positive: {'en': 'PROPHECY', 'ar': 'نبوءة'},
    negative: {'en': 'CHANCE', 'ar': 'صدفة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'magic_science',
    positive: {'en': 'MAGIC', 'ar': 'سحر'},
    negative: {'en': 'SCIENCE', 'ar': 'علم'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'creation_destruction',
    positive: {'en': 'CREATION', 'ar': 'خلق'},
    negative: {'en': 'DESTRUCTION', 'ar': 'دمار'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'myth_history',
    positive: {'en': 'MYTH', 'ar': 'أسطورة'},
    negative: {'en': 'HISTORY', 'ar': 'تاريخ'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'miracle_curse',
    positive: {'en': 'MIRACLE', 'ar': 'معجزة'},
    negative: {'en': 'CURSE', 'ar': 'لعنة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'legendary_weapon_common_weapon',
    positive: {'en': 'LEGENDARY WEAPON', 'ar': 'سلاح أسطوري'},
    negative: {'en': 'COMMON WEAPON', 'ar': 'سلاح شائع'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'power_weakness',
    positive: {'en': 'POWER', 'ar': 'قوة'},
    negative: {'en': 'WEAKNESS', 'ar': 'ضعف'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'victory_defeat',
    positive: {'en': 'VICTORY', 'ar': 'انتصار'},
    negative: {'en': 'DEFEAT', 'ar': 'هزيمة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'trust_betrayal',
    positive: {'en': 'TRUST', 'ar': 'ثقة'},
    negative: {'en': 'BETRAYAL', 'ar': 'خيانة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'wonder_doubt',
    positive: {'en': 'WONDER', 'ar': 'عجب'},
    negative: {'en': 'DOUBT', 'ar': 'شك'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'high_fantasy_low_fantasy',
    positive: {'en': 'HIGH FANTASY', 'ar': 'خيال عالي'},
    negative: {'en': 'LOW FANTASY', 'ar': 'خيال منخفض'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'good_king_evil_tyrant',
    positive: {'en': 'GOOD KING', 'ar': 'ملك صالح'},
    negative: {'en': 'EVIL TYRANT', 'ar': 'طاغية شرير'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'forbidden_allowed',
    positive: {'en': 'FORBIDDEN', 'ar': 'محظور'},
    negative: {'en': 'ALLOWED', 'ar': 'مسموح'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'clearly_good_morally_grey',
    positive: {'en': 'CLEARLY GOOD', 'ar': 'خيّر بوضوح'},
    negative: {'en': 'MORALLY GREY', 'ar': 'رمادي أخلاقياً'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'heroism_cowardice',
    positive: {'en': 'HEROISM', 'ar': 'بطولة'},
    negative: {'en': 'COWARDICE', 'ar': 'جبن'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'wisdom_foolishness',
    positive: {'en': 'WISDOM', 'ar': 'حكمة'},
    negative: {'en': 'FOOLISHNESS', 'ar': 'حماقة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'useful_spell_useless_spell',
    positive: {'en': 'USEFUL SPELL', 'ar': 'تعويذة مفيدة'},
    negative: {'en': 'USELESS SPELL', 'ar': 'تعويذة عديمة الفائدة'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'simple_quest_epic_journey',
    positive: {'en': 'SIMPLE QUEST', 'ar': 'مهمة بسيطة'},
    negative: {'en': 'EPIC JOURNEY', 'ar': 'رحلة ملحمية'},
    bundleId: 'bundle.fantasy',
  ),
  CategoryItem(
    id: 'rare_common',
    positive: {'en': 'RARE', 'ar': 'نادر'},
    negative: {'en': 'COMMON', 'ar': 'شائع'},
    bundleId: 'bundle.fantasy',
  ),
];
