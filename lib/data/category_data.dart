// lib/data/category_data.dart

/// Simple model to hold your category info.
class CategoryItem {
  final String id;
  final String left;
  final String right;
  final String bundleId;

  const CategoryItem({
    required this.id,
    required this.left,
    required this.right,
    required this.bundleId,
  });

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
  CategoryItem(id: 'hot_cold',         left: 'HOT',           right: 'COLD',           bundleId: 'bundle.free'),
  CategoryItem(id: 'day_night',        left: 'DAY',           right: 'NIGHT',          bundleId: 'bundle.free'),
  CategoryItem(id: 'happy_sad',        left: 'HAPPY',         right: 'SAD',            bundleId: 'bundle.free'),
  CategoryItem(id: 'big_small',        left: 'BIG',           right: 'SMALL',          bundleId: 'bundle.free'),
  CategoryItem(id: 'young_old',        left: 'YOUNG',         right: 'OLD',            bundleId: 'bundle.free'),
  CategoryItem(id: 'fast_slow',        left: 'FAST',          right: 'SLOW',           bundleId: 'bundle.free'),
  CategoryItem(id: 'sweet_sour',       left: 'SWEET',         right: 'SOUR',           bundleId: 'bundle.free'),
  CategoryItem(id: 'rich_poor',        left: 'RICH',          right: 'POOR',           bundleId: 'bundle.free'),
  CategoryItem(id: 'soft_hard',        left: 'SOFT',          right: 'HARD',           bundleId: 'bundle.free'),
  CategoryItem(id: 'near_far',         left: 'NEAR',          right: 'FAR',            bundleId: 'bundle.free'),

  // ─── Horror Bundle (20) ───
  CategoryItem(id: 'fear_courage',             left: 'FEAR',            right: 'COURAGE',          bundleId: 'bundle.horror'),
  CategoryItem(id: 'despair_hope',             left: 'DESPAIR',         right: 'HOPE',             bundleId: 'bundle.horror'),
  CategoryItem(id: 'darkness_light',           left: 'DARKNESS',        right: 'LIGHT',            bundleId: 'bundle.horror'),
  CategoryItem(id: 'silence_noise',            left: 'SILENCE',         right: 'NOISE',            bundleId: 'bundle.horror'),
  CategoryItem(id: 'madness_sanity',           left: 'MADNESS',         right: 'SANITY',           bundleId: 'bundle.horror'),
  CategoryItem(id: 'dread_eagerness',          left: 'DREAD',           right: 'EAGERNESS',        bundleId: 'bundle.horror'),
  CategoryItem(id: 'terror_peace',             left: 'TERROR',          right: 'PEACE',            bundleId: 'bundle.horror'),
  CategoryItem(id: 'doom_salvation',           left: 'DOOM',            right: 'SALVATION',        bundleId: 'bundle.horror'),
  CategoryItem(id: 'curse_blessing',           left: 'CURSE',           right: 'BLESSING',         bundleId: 'bundle.horror'),
  CategoryItem(id: 'sorrow_joy',               left: 'SORROW',          right: 'JOY',              bundleId: 'bundle.horror'),
  CategoryItem(id: 'anguish_relief',           left: 'ANGUISH',         right: 'RELIEF',           bundleId: 'bundle.horror'),
  CategoryItem(id: 'grief_comfort',            left: 'GRIEF',           right: 'COMFORT',          bundleId: 'bundle.horror'),
  CategoryItem(id: 'loneliness_companionship', left: 'LONELINESS',      right: 'COMPANIONSHIP',    bundleId: 'bundle.horror'),
  CategoryItem(id: 'danger_safety',            left: 'DANGER',          right: 'SAFETY',           bundleId: 'bundle.horror'),
  CategoryItem(id: 'panic_calm',               left: 'PANIC',           right: 'CALM',             bundleId: 'bundle.horror'),
  CategoryItem(id: 'horror_serenity',          left: 'HORROR',          right: 'SERENITY',         bundleId: 'bundle.horror'),
  CategoryItem(id: 'guilt_innocence',          left: 'GUILT',           right: 'INNOCENCE',        bundleId: 'bundle.horror'),
  CategoryItem(id: 'violence_nonviolence',     left: 'VIOLENCE',        right: 'NONVIOLENCE',      bundleId: 'bundle.horror'),
  CategoryItem(id: 'pain_pleasure',            left: 'PAIN',            right: 'PLEASURE',         bundleId: 'bundle.horror'),
  CategoryItem(id: 'chaos_order',              left: 'CHAOS',           right: 'ORDER',            bundleId: 'bundle.horror'),

  // ─── Kids Bundle (20) ───
  CategoryItem(id: 'awake_asleep',        left: 'AWAKE',           right: 'ASLEEP',           bundleId: 'bundle.kids'),
  CategoryItem(id: 'loud_quiet',          left: 'LOUD',            right: 'QUIET',            bundleId: 'bundle.kids'),
  CategoryItem(id: 'bright_dim',          left: 'BRIGHT',          right: 'DIM',              bundleId: 'bundle.kids'),
  CategoryItem(id: 'full_empty',          left: 'FULL',            right: 'EMPTY',            bundleId: 'bundle.kids'),
  CategoryItem(id: 'thick_thin',          left: 'THICK',           right: 'THIN',             bundleId: 'bundle.kids'),
  CategoryItem(id: 'smooth_rough',        left: 'SMOOTH',          right: 'ROUGH',            bundleId: 'bundle.kids'),
  CategoryItem(id: 'high_low',            left: 'HIGH',            right: 'LOW',              bundleId: 'bundle.kids'),
  CategoryItem(id: 'early_late',          left: 'EARLY',           right: 'LATE',             bundleId: 'bundle.kids'),
  CategoryItem(id: 'start_end',           left: 'START',           right: 'END',              bundleId: 'bundle.kids'),
  CategoryItem(id: 'open_closed',         left: 'OPEN',            right: 'CLOSED',           bundleId: 'bundle.kids'),
  CategoryItem(id: 'inside_outside',      left: 'INSIDE',          right: 'OUTSIDE',          bundleId: 'bundle.kids'),
  CategoryItem(id: 'above_below',         left: 'ABOVE',           right: 'BELOW',            bundleId: 'bundle.kids'),
  CategoryItem(id: 'front_back',          left: 'FRONT',           right: 'BACK',             bundleId: 'bundle.kids'),
  CategoryItem(id: 'broad_narrow',        left: 'BROAD',           right: 'NARROW',           bundleId: 'bundle.kids'),
  CategoryItem(id: 'single_multiple',     left: 'SINGLE',          right: 'MULTIPLE',         bundleId: 'bundle.kids'),
  CategoryItem(id: 'shallow_deep',        left: 'SHALLOW',         right: 'DEEP',             bundleId: 'bundle.kids'),
  CategoryItem(id: 'polite_rude',         left: 'POLITE',          right: 'RUDE',             bundleId: 'bundle.kids'),
  CategoryItem(id: 'clean_dirty',         left: 'CLEAN',           right: 'DIRTY',            bundleId: 'bundle.kids'),
  CategoryItem(id: 'together_apart',      left: 'TOGETHER',        right: 'APART',            bundleId: 'bundle.kids'),
  CategoryItem(id: 'soon_later',          left: 'SOON',            right: 'LATER',            bundleId: 'bundle.kids'),

  // ─── Food Bundle (20) ───
  CategoryItem(id: 'hungry_satiated',      left: 'HUNGRY',         right: 'SATIATED',         bundleId: 'bundle.food'),
  CategoryItem(id: 'thirsty_hydrated',     left: 'THIRSTY',        right: 'HYDRATED',         bundleId: 'bundle.food'),
  CategoryItem(id: 'raw_cooked',           left: 'RAW',            right: 'COOKED',           bundleId: 'bundle.food'),
  CategoryItem(id: 'fresh_stale',          left: 'FRESH',          right: 'STALE',            bundleId: 'bundle.food'),
  CategoryItem(id: 'spicy_mild',           left: 'SPICY',          right: 'MILD',             bundleId: 'bundle.food'),
  CategoryItem(id: 'salty_bland',          left: 'SALTY',          right: 'BLAND',            bundleId: 'bundle.food'),
  CategoryItem(id: 'bitter_umami',         left: 'BITTER',         right: 'UMAMI',            bundleId: 'bundle.food'),
  CategoryItem(id: 'dense_airy',           left: 'DENSE',          right: 'AIRY',             bundleId: 'bundle.food'),
  CategoryItem(id: 'rich_plain',           left: 'RICH',           right: 'PLAIN',            bundleId: 'bundle.food'),
  CategoryItem(id: 'heavy_light',          left: 'HEAVY',          right: 'LIGHT',            bundleId: 'bundle.food'),
  CategoryItem(id: 'crunchy_tender',       left: 'CRUNCHY',        right: 'TENDER',           bundleId: 'bundle.food'),
  CategoryItem(id: 'organic_processed',    left: 'ORGANIC',        right: 'PROCESSED',        bundleId: 'bundle.food'),
  CategoryItem(id: 'plentiful_scarce',     left: 'PLENTIFUL',      right: 'SCARCE',           bundleId: 'bundle.food'),
  CategoryItem(id: 'subtle_intense',       left: 'SUBTLE',         right: 'INTENSE',          bundleId: 'bundle.food'),
  CategoryItem(id: 'fatty_lean',           left: 'FATTY',          right: 'LEAN',             bundleId: 'bundle.food'),
  CategoryItem(id: 'delicious_disgusting', left: 'DELICIOUS',      right: 'DISGUSTING',       bundleId: 'bundle.food'),
  CategoryItem(id: 'healthy_unhealthy',    left: 'HEALTHY',        right: 'UNHEALTHY',        bundleId: 'bundle.food'),
  CategoryItem(id: 'natural_artificial',   left: 'NATURAL',        right: 'ARTIFICIAL',       bundleId: 'bundle.food'),
  CategoryItem(id: 'appealing_unappealing',left: 'APPEALING',      right: 'UNAPPEALING',      bundleId: 'bundle.food'),
  CategoryItem(id: 'balanced_unbalanced',  left: 'BALANCED',       right: 'UNBALANCED',       bundleId: 'bundle.food'),

  // ─── Nature Bundle (20) ───
  CategoryItem(id: 'pure_contaminated',        left: 'PURE',            right: 'CONTAMINATED',      bundleId: 'bundle.nature'),
  CategoryItem(id: 'wet_dry',                  left: 'WET',             right: 'DRY',               bundleId: 'bundle.nature'),
  CategoryItem(id: 'fertile_barren',           left: 'FERTILE',         right: 'BARREN',            bundleId: 'bundle.nature'),
  CategoryItem(id: 'growth_decay',             left: 'GROWTH',          right: 'DECAY',             bundleId: 'bundle.nature'),
  CategoryItem(id: 'stable_unstable',          left: 'STABLE',          right: 'UNSTABLE',          bundleId: 'bundle.nature'),
  CategoryItem(id: 'sustainable_unsustainable',left: 'SUSTAINABLE',     right: 'UNSUSTAINABLE',     bundleId: 'bundle.nature'),
  CategoryItem(id: 'steady_erratic',           left: 'STEADY',          right: 'ERRATIC',           bundleId: 'bundle.nature'),
  CategoryItem(id: 'renewal_erosion',          left: 'RENEWAL',         right: 'EROSION',           bundleId: 'bundle.nature'),
  CategoryItem(id: 'harmony_discord',          left: 'HARMONY',         right: 'DISCORD',           bundleId: 'bundle.nature'),
  CategoryItem(id: 'cyclical_linear',          left: 'CYCLICAL',        right: 'LINEAR',            bundleId: 'bundle.nature'),
  CategoryItem(id: 'dynamic_static',           left: 'DYNAMIC',         right: 'STATIC',            bundleId: 'bundle.nature'),
  CategoryItem(id: 'radiant_dim',              left: 'RADIANT',         right: 'DIM',               bundleId: 'bundle.nature'),
  CategoryItem(id: 'verdant_arid',             left: 'VERDANT',         right: 'ARID',              bundleId: 'bundle.nature'),
  CategoryItem(id: 'resilient_fragile',        left: 'RESILIENT',       right: 'FRAGILE',           bundleId: 'bundle.nature'),
  CategoryItem(id: 'connected_isolated',       left: 'CONNECTED',       right: 'ISOLATED',          bundleId: 'bundle.nature'),
  CategoryItem(id: 'symmetrical_asymmetrical', left: 'SYMMETRICAL',     right: 'ASYMMETRICAL',      bundleId: 'bundle.nature'),
  CategoryItem(id: 'seasonal_permanent',       left: 'SEASONAL',        right: 'PERMANENT',         bundleId: 'bundle.nature'),
  CategoryItem(id: 'layered_flat',             left: 'LAYERED',         right: 'FLAT',              bundleId: 'bundle.nature'),
  CategoryItem(id: 'concentrated_diffuse',     left: 'CONCENTRATED',    right: 'DIFFUSE',           bundleId: 'bundle.nature'),
  CategoryItem(id: 'evolving_stagnant',        left: 'EVOLVING',        right: 'STAGNANT',          bundleId: 'bundle.nature'),

  // ─── Fantasy Bundle (20) ───
  CategoryItem(id: 'illusion_reality',     left: 'ILLUSION',        right: 'REALITY',           bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'fate_free_will',       left: 'FATE',            right: 'FREE WILL',         bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'magic_science',        left: 'MAGIC',           right: 'SCIENCE',           bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'destiny_choice',       left: 'DESTINY',         right: 'CHOICE',            bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'hope_despair',         left: 'HOPE',            right: 'DESPAIR',           bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'creation_destruction', left: 'CREATION',        right: 'DESTRUCTION',       bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'myth_history',         left: 'MYTH',            right: 'HISTORY',           bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'miracle_curse',        left: 'MIRACLE',         right: 'CURSE',             bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'ephemeral_permanent',  left: 'EPHEMERAL',       right: 'PERMANENT',         bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'power_weakness',       left: 'POWER',           right: 'WEAKNESS',          bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'victory_defeat',       left: 'VICTORY',         right: 'DEFEAT',            bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'trust_betrayal',       left: 'TRUST',           right: 'BETRAYAL',          bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'wonder_doubt',         left: 'WONDER',          right: 'DOUBT',             bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'eternal_temporary',    left: 'ETERNAL',         right: 'TEMPORARY',         bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'vision_oblivion',      left: 'VISION',          right: 'OBLIVION',          bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'forbidden_allowed',    left: 'FORBIDDEN',       right: 'ALLOWED',           bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'truth_mystery',        left: 'TRUTH',           right: 'MYSTERY',           bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'heroism_cowardice',    left: 'HEROISM',         right: 'COWARDICE',         bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'wisdom_foolishness',   left: 'WISDOM',          right: 'FOOLISHNESS',       bundleId: 'bundle.fantasy'),
  CategoryItem(id: 'existence_nonexistence', left: 'EXISTENCE',     right: 'NONEXISTENCE',      bundleId: 'bundle.fantasy'),
];
