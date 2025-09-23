// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'موجة';

  @override
  String get homeSubtitle => 'اعمل غرفة او انضم لغرفة عشان تبدا اللعبة!';

  @override
  String get createRoom => 'إنشاء غرفة';

  @override
  String get or => 'أو';

  @override
  String get enterCodeHint => 'أدخل رمز الغرفة';

  @override
  String get joinRoom => 'انضم إلى غرفة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get enableSaboteur => 'تفعيل وضع المخرب';

  @override
  String get enableDiceRoll => 'تفعيل خاصية رمي النرد';

  @override
  String get howToPlay => 'طريقة اللعب';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات!';

  @override
  String get tutorialTitle1 => 'إنشاء غرفة أو الانضمام ليها!';

  @override
  String get tutorialDesc1 =>
      'اضغط على \"إنشاء غرفة\" عشان تبدا لعبة جديدة، أو أدخل رمز الغرفة وانضم إلى اصدقائك.';

  @override
  String get tutorialTitle2 => 'تعيين الأدوار';

  @override
  String get tutorialDesc2 =>
      'يُعيَّن دور القائد والمخرب وبقية اللاعبين مخمنين في كل جولة.';

  @override
  String get tutorialTitle3 => 'القائد بيكتب تلميح عشان يوجه الفريق للاجابة الصحيحة';

  @override
  String get tutorialDesc3 =>
      'بيظهر للقائد موقع النقطة المخفية وبيكتب تلميح ذكي يسهل للفريق يكتشف الموقع بالزبط.';

  @override
  String get tutorialTitle4 => 'الفريق بيتناقش مع بعض ويتفق على احسن تخمين لموقع النقطةالمخفية';

  @override
  String get tutorialDesc4 =>
      'فريق المخمنين بيضع المؤشر في المكان المتفق عليه، السؤال هو هل حيكون دا المكان الصحيح ولا ما هل؟.';

  @override
  String get tutorialTitle5 => 'المخرب يحاول التضليل';

  @override
  String get tutorialDesc5 => 'المخرب بحاول يشوش على الفريق بدون ما يتم كشفه.';

  @override
  String get tutorialTitle6 => 'النتيجة والاسكور!';

  @override
  String get tutorialDesc6 =>
      'اطلع على تخمينات الفريق مقابل الهدف الفعلي وشوف حصلت كم نقطة.';

  @override
  String get skip => 'تخطي';

  @override
  String get done => 'تم';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get roleRevealTitle => 'كشف الدور';

  @override
  String get youAreNavigator => 'أنت القائد';

  @override
  String get youAreSaboteur => 'أنت المخرب';

  @override
  String get youAreGuesser => 'أنت المخمن';

  @override
  String get continueButton => 'متابعة';

  @override
  String get readyTitle => 'الاستعداد';

  @override
  String get waitingForPlayers => 'في انتظار اللاعبين...';

  @override
  String get readyButton => 'انا جاهز';

  @override
  String get diceRollTitle => 'رمي النرد';

  @override
  String get rollTheDice => 'ارمِي النرد';

  @override
  String get rolling => 'جاري الرمي...';

  @override
  String get setupRoundTitle => 'إعداد الجولة';

  @override
  String get submitClue => 'إرسال التلميح';

  @override
  String get waitingClueTitle => 'في انتظار التلميح';

  @override
  String get waitingForNavigator => 'في انتظار القائد يكتب التلميح...';

  @override
  String get guessRoundTitle => 'جولة التخمين';

  @override
  String get placeYourGuess => 'ضع تخمينك';

  @override
  String get roundResultTitle => 'نتائج الجولة';

  @override
  String get yourScore => 'نقاطك';

  @override
  String get nextRound => 'الجولة التالية';

  @override
  String get matchSummaryTitle => 'ملخص المباراة';

  @override
  String get finalScores => 'النتائج النهائية';

  @override
  String get playAgain => 'العب مرة تانية';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get availableCategories => 'الفئات المتاحة';

  @override
  String get lockedCategories => 'الفئات المقفلة';

  @override
  String get gameLobby => 'ردهة اللعبة';

  @override
  String get addBot => 'إضافة روبوت';

  @override
  String get roomCode => 'رمز الغرفة:';

  @override
  String get cancelReady => 'إلغاء الاستعداد';

  @override
  String get imReady => 'أنا جاهز';

  @override
  String get allReadyStartRound => 'الجميع جاهزين — ابدأ الجولة';

  @override
  String get waitingForPlayersToGetReady => 'في انتظار اللاعبين للاستعداد...';

  @override
  String get allReadyWaitingForHost => 'الجميع جاهزون! في انتظار المضيف للبدء...';

  @override
  String get exitGame => 'الخروج من اللعبة؟';

  @override
  String get exitGameConfirmation => 'هل أنت متأكد من أنك تريد الخروج من الغرفة؟ سيتم إخطار اللاعبين الآخرين.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get exit => 'خروج';

  @override
  String get youAreLastPlayer => 'أنت آخر لاعب!';

  @override
  String get lastPlayerMessage => 'غادر جميع اللاعبين الآخرين الغرفة. يمكنك دعوة لاعبين آخرين، أو عرض النتيجة الإجمالية، أو الخروج.';

  @override
  String get inviteFriends => 'دعوة الأصدقاء';

  @override
  String shareRoomId(String roomId) => 'شارك رمز الغرفة: $roomId';

  @override
  String get viewScoreboard => 'عرض النتائج';

  @override
  String get exitToHome => 'الخروج إلى الرئيسية';

  @override
  String playerExited(String playerName) => 'غادر $playerName الغرفة.';

  @override
  String roundNumber(int roundNumber) => 'الجولة $roundNumber';

  @override
  String secret(String secret) => 'السر: $secret';

  @override
  String groupGuess(String guess) => 'تخمين المجموعة: $guess';

  @override
  String scorePoints(int score) => 'النقاط: $score نقطة';

  @override
  String time(String time) => 'الوقت: $time';

  @override
  String get noRoundsPlayed => 'لم تُلعب أي جولات بعد.';

  @override
  String get finalScore => 'النتيجة النهائية!';

  @override
  String get playersInThisGame => 'اللاعبون في هذه اللعبة';

  @override
  String get returnToHome => 'العودة إلى الرئيسية';

  @override
  String get roundsPerMatch => 'الجولات في كل مباراة';

  @override
  String get gameMusic => 'موسيقى اللعبة';

  @override
  String get threeRounds => '3 جولات';

  @override
  String get fiveRounds => '5 جولات';

  @override
  String get sevenRounds => '7 جولات';

  @override
  String get seekersMakeGuess => 'فريق المخمنين: تناقشوا وحددوا اجابتكم';

  @override
  String get confirmGroupGuess => 'تأكيد تخمين الفريق';

  @override
  String get waitingForHostToContinue => 'في انتظار المضيف للمتابعة...';

  @override
  String get doubleScore => 'مضاعفة النقاط!';

  @override
  String get halfScore => 'نصف النقاط!';

  @override
  String get navigatorGetsToken => 'يحصل القائد على رمز!';

  @override
  String get reverseSlider => 'عكس المؤشر!';

  @override
  String get noClue => 'لا تلميح!';

  @override
  String get blindGuess => 'تخمين أعمى!';

  @override
  String get noEffect => 'لا تأثير';

  @override
  String get store => 'المتجر';

  @override
  String get owned => 'تم الشراء';

  @override
  String get pleaseEnterRoomCode => 'يرجى إدخال رمز الغرفة.';

  @override
  String errorCreatingRoom(String error) => 'خطأ في إنشاء الغرفة: $error';

  @override
  String errorJoiningRoom(String error) => 'خطأ في الانضمام للغرفة: $error';

  @override
  String get scoreboard => 'لوحة النتائج';

  @override
  String get lobby => 'ردهة';

  @override
  String get waitingForPlayersToJoin => 'في انتظار انضمام اللاعبين…';

  @override
  String get imHereLetsGetReady => 'أنا هنا — دعنا نستعد';

  @override
  String uid(String uid) => 'معرف المستخدم: $uid';

  @override
  String error(String error) => 'خطأ: $error';

  @override
  String get navigatorDescription => 'اكتب تلميح ذكي لتوجيه فريقك!';

  @override
  String get saboteurDescription => 'شوش على الفريق عشان يغلطو!';

  @override
  String get seekerDescription => 'اعمل مع فريقك لتخمين الموضع!';

  @override
  String get secretPositionSet => 'تم تعيين الموقع السري — أدخل تلميحك';

  @override
  String get clueDisabledByEffect => 'التلميح معطل بسبب التأثير';

  @override
  String get oneWordClue => 'التلميح';

  @override
  String get confirmNoClue => 'تأكيد عدم وجود تلميح';

  @override
  String navigatorThinking(String navigatorName) => '$navigatorName يفكر...';

  @override
  String get rollingTheDice => 'رمي النرد...';

  @override
  String get bullseye => 'جوة الجك!';

  @override
  String get howScoringWorks => 'كيف شرح نظام النقاط';

  @override
  String get scoringExplanation => 'كلما كان تخمين فريقك أقرب إلى الهدف السري، كلما حصلت على نقاط أكثر!\n\nإصابة مباشرة (0-2 بعيداً): 6 نقاط\nممتاز (3-5 بعيداً): 4 نقاط\nجيد (6-10 بعيداً): 3 نقاط\nمقبول (11-15 بعيداً): 2 نقاط';

  @override
  String get gotIt => 'فهمت!';

  @override
  String roundResults(int roundNumber) => 'نتائج الجولة $roundNumber';

  @override
  String navigatorWas(String navigatorName) => '$navigatorName كان القائد';

  @override
  String get score => 'النقاط';

  @override
  String get ready => 'جاهز!';

  @override
  String get readyForSummary => 'جاهز للملخص';

  @override
  String get readyForNextRound => 'جاهز للجولة التالية';

  @override
  String get waitingForOtherPlayersToGetReady => 'في انتظار اللاعبين الآخرين للاستعداد...';

  @override
  String get showMatchSummary => 'عرض ملخص المباراة';

  // Multiplayer additions (new)
  String get close => 'إغلاق';
  String get observingYourTeam => 'تراقب فريقك';
  String get navigatorObserverDescription => 'أنت الموجِّه. شاهد الباحثين وهم يضعون إجابتهم.';
  String get viewRoundResults => 'عرض نتائج الجولة';
  String get notReady => 'غير جاهز';
  String get theyAreSubmittingClue => 'يقومون بإرسال التلميح...';
  String waitingForPlayer(String name) => 'ننتظر ${name}';
  String waitingForPlayersCount(int count) => 'ننتظر ${count} لاعب${count == 1 ? '' : 'ين'}...';
  String get removeBot => 'إزالة الروبوت';

  @override
  String get startNextRound => 'ابدأ الجولة التالية';

  @override
  String get allAccessPass => 'اشتراك شامل';

  @override
  String get allAccessPassDescription => 'يفتح جميع الحزم الحالية والمستقبلية';

  @override
  String get horrorBundle => 'حزمة الرعب';

  @override
  String get horrorBundleDescription => '20 فئة مرعبة';

  @override
  String get kidsBundle => 'حزمة الأطفال';

  @override
  String get kidsBundleDescription => '20 فئة ممتعة للأطفال';

  @override
  String get foodBundle => 'حزمة الطعام';

  @override
  String get foodBundleDescription => '20 فئة طعامية لعشاق الطعام';

  @override
  String get natureBundle => 'حزمة الطبيعة';

  @override
  String get natureBundleDescription => '20 فئة مستوحاة من الطبيعة لعشاق الهواء الطلق';

  @override
  String get fantasyBundle => 'حزمة الخيال';

  @override
  String get fantasyBundleDescription => '20 فئة سحرية لعشاق الخيال';

  @override
  String get freeBundle => 'الحزمة المجانية';

  @override
  String get categories => 'فئات';
  String get selectBundlesForGameplay => 'اختر الحزم للعب';
  String get bundleSelectionSaved => 'تم حفظ اختيار الحزم';
  String get selectBundleForGame => 'اختر الحزمة للعبة';
  String get selectBundleDescription => 'اختر الحزمة التي تريد استخدامها في هذه اللعبة. سيكون لدى جميع اللاعبين إمكانية الوصول إلى هذه الفئات.';
  String get switchToEnglish => 'Switch to English';
  String get switchToArabic => 'التبديل إلى العربية';
  String get billingUnavailable => 'المشتريات داخل التطبيق غير متاحة';
  String get billingUnavailableDescription => 'هذا الجهاز لا يدعم المشتريات داخل التطبيق. يمكنك عرض الحزم المتاحة، لكن المشتريات لن تعمل.';
  String get copyRoomCode => 'نسخ رمز الغرفة';
  String get roomCodeCopied => 'تم نسخ رمز الغرفة إلى الحافظة!';

  @override
  String get premium => 'بريميوم';

  @override
  String get premiumTitle => 'افتح ميزات بريميوم';

  @override
  String get premiumSubtitle => 'احصل على ميزات حصرية وحسّن تجربة اللعب الخاصة بك';

  @override
  String get premiumFeatures => 'ميزات بريميوم';

  @override
  String get premiumActive => 'بريميوم نشط';

  @override
  String get premiumPrice => 'شراء لمرة واحدة. بدون رسوم متكررة.';

  @override
  String get upgradeToPremium => 'ترقية إلى بريميوم';

  @override
  String get avatarCustomization => 'تخصيص الصورة الرمزية';

  @override
  String get avatarCustomizationDesc => 'رفع واستخدام صور رمزية مخصصة';

  @override
  String get groupChat => 'الدردشة الجماعية';

  @override
  String get groupChatDesc => 'الدردشة مع اللاعبين الآخرين في غرفة اللعبة';

  @override
  String get voiceChat => 'الدردشة الصوتية';

  @override
  String get voiceChatDesc => 'تسجيل وإرسال رسائل صوتية';

  @override
  String get onlineMatchmaking => 'المطابقة عبر الإنترنت';

  @override
  String get onlineMatchmakingDesc => 'اللعب مع لاعبين عشوائيين عبر الإنترنت';

  @override
  String get chooseFromGallery => 'المعرض';

  @override
  String get takePhoto => 'الكاميرا';

  @override
  String get getBundles => 'احصل على الحزم';

  @override
  String get getMoreBundlesMessage => 'احصل على المزيد من الحزم للحصول على تنوع أكبر!';

  @override
  String get delete => 'حذف';

  @override
  String get deleteAvatar => 'حذف الصورة الرمزية';

  @override
  String get deleteAvatarConfirmation => 'هل أنت متأكد من أنك تريد حذف هذه الصورة الرمزية؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get practiceMode => 'وضع التدريب';

  @override
  String get dailyChallenge => 'التحدي اليومي';

  @override
  String get campaignMode => 'وضع الحملة';

  // ===== NEW FEATURES ARABIC TRANSLATIONS =====

  /// Gem Store related strings
  @override
  String get gemStore => 'متجر الجواهر';
  @override
  String get gemStoreTitle => 'متجر الجواهر';
  @override
  String get mindGems => 'جواهر العقل';
  @override
  String get sliderSkins => 'أشكال المنزلق';
  @override
  String get badges => 'الشارات';
  @override
  String get avatarPacks => 'حزم الصور الرمزية';
  @override
  String get loadingStore => 'جاري تحميل المتجر...';
  @override
  String get confirmPurchase => 'تأكيد الشراء';
  @override
  String get purchase => 'شراء';
  // cancel already exists
  // owned already exists - updating existing one
  @override
  String get notEnoughGems => 'جواهر غير كافية!';
  @override
  String get purchaseSuccessful => 'تم الشراء بنجاح!';
  @override
  String get purchaseFailed => 'فشل الشراء. يرجى المحاولة مرة أخرى.';
  @override
  String get animated => 'متحرك';
  @override
  String get retry => 'إعادة المحاولة';

  /// Quest System related strings
  @override
  String get quests => 'المهام';
  @override
  String get questsTitle => 'المهام';
  @override
  String get daily => 'يومي';
  @override
  String get weekly => 'أسبوعي';
  @override
  String get achievements => 'الإنجازات';
  @override
  String get special => 'خاص';
  @override
  String get loadingQuests => 'جاري تحميل المهام...';
  @override
  String get progress => 'التقدم';
  @override
  String get rewards => 'المكافآت';
  @override
  String get completed => 'مكتمل';
  @override
  String get claimReward => 'استلام المكافأة';
  @override
  String get readyToClaim => 'جاهز للاستلام';
  @override
  String get inProgress => 'قيد التقدم';
  @override
  String get questRewardClaimed => 'تم استلام مكافأة المهمة بنجاح!';
  @override
  String get questClaimFailed => 'فشل في استلام المكافأة. يرجى المحاولة مرة أخرى.';
  @override
  String get noDailyQuests => 'لا توجد مهام يومية متاحة.\nتحقق غداً!';
  @override
  String get noWeeklyQuests => 'لا توجد مهام أسبوعية متاحة.\nتحقق الأسبوع القادم!';
  @override
  String get noAchievementQuests => 'لا توجد مهام إنجازات متاحة.\nاستمر في اللعب لفتح المزيد!';
  @override
  String get noSpecialQuests => 'لا توجد أحداث خاصة.\nترقب المهام محدودة الوقت!';

  /// Practice Mode related strings
  @override
  String get yourClue => 'دليلك:';
  @override
  String get whereDoesThisBelong => 'أين ينتمي هذا الدليل؟';
  @override
  String get yourGuess => 'تخمينك';
  @override
  String get correctAnswer => 'الإجابة الصحيحة';
  @override
  String get submitGuess => 'إرسال التخمين';
  // score already exists
  @override
  String get accuracy => 'الدقة';
  @override
  String get gameTime => 'الوقت';
  @override
  String get nextChallenge => 'التحدي التالي';
  @override
  String get newChallenge => 'تحدي جديد';

  /// Campaign Mode related strings
  @override
  String get campaign => 'الحملة';
  @override
  String get level => 'المستوى';
  @override
  String get section => 'القسم';
  @override
  String get difficulty => 'الصعوبة';
  @override
  String get stars => 'النجوم';
  @override
  String get maxScore => 'أقصى نقاط';
  @override
  String get beginnerJourney => 'رحلة المبتدئين';
  @override
  String get risingChallenge => 'التحدي المتزايد';
  @override
  String get expertTerritory => 'منطقة الخبراء';
  @override
  String get grandmasterGauntlet => 'تحدي الأستاذ الأكبر';

  /// Daily Challenge related strings
  @override
  String get todaysChallenge => 'تحدي اليوم';
  @override
  String get leaderboard => 'لوحة المتصدرين';
  @override
  String get streak => 'السلسلة';
  @override
  String get rank => 'الترتيب';
  @override
  String get submitAnswer => 'إرسال الإجابة';
  @override
  String get yourRank => 'ترتيبك';
  @override
  String get currentStreak => 'السلسلة الحالية';

  /// General UI strings
  @override
  String get playWithFriends => 'العب مع الأصدقاء';
  @override
  String get playSolo => 'العب منفرداً';
  @override
  String get playByYourself => 'العب بمفردك';
  @override
  String get startGame => 'ابدأ اللعبة';
  @override
  String get gems => 'الجواهر';
  // store already exists
  // settings already exists
  @override
  String get loading => 'جاري التحميل...';
  // error already exists (as function)
  @override
  String get back => 'رجوع';
  @override
  String get errorLoadingChallenge => 'خطأ في تحميل التحدي اليومي';
  @override
  String get errorSubmittingResult => 'خطأ في إرسال النتيجة';
  @override
  String get unknownBundle => 'حزمة غير معروفة';
  @override
  String get noSpecialEffect => 'لا توجد تأثيرات خاصة';
  @override
  String get errorGeneric => 'خطأ';
  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح!';
  @override
  String get errorUpdatingProfile => 'خطأ في تحديث الملف الشخصي';
  @override
  String get errorLoadingProfile => 'خطأ في تحميل الملف الشخصي';
  @override
  String get failedToSendMessage => 'فشل في إرسال الرسالة';
  @override
  String get voiceRecordingComingSoon => 'تسجيل الصوت قريباً!';
  @override
  String get failedToPlayVoiceMessage => 'فشل في تشغيل الرسالة الصوتية';
  @override
  String get voiceChatRequiresPremium => 'الدردشة الصوتية تتطلب العضوية المميزة';
  @override
  String get errorSavingBundleSelections => 'خطأ في حفظ اختيارات الحزم';
  @override
  String get loadingBundleSelections => 'جاري تحميل اختيارات الحزم...';
  @override
  String get you => 'أنت';
  @override
  String get operationTimedOut => 'انتهت مهلة العملية';
  @override
  String get premiumFeature => 'ميزة مميزة';
  @override
  String get upgradeToPremiumNew => 'ترقية إلى العضوية المميزة';
  @override
  String get customUsername => 'اسم مستخدم مخصص';
  @override
  String get currentUsername => 'اسم المستخدم الحالي';
  @override
  String get suggestBundle => 'اقتراح حزمة';
  @override
  String get bundleName => 'اسم الحزمة';
  @override
  String get description => 'الوصف';
  @override
  String get pleaseEnterBundleName => 'يرجى إدخال اسم الحزمة';
  @override
  String get pleaseEnterDescription => 'يرجى إدخال الوصف';
  @override
  String get pleaseSelectAtLeastOneCategory => 'يرجى اختيار فئة واحدة على الأقل';
  @override
  String get anonymous => 'مجهول';
  @override
  String get onlineMatchmakingNew => 'المطابقة عبر الإنترنت';
  @override
  String get goOffline => 'عدم الاتصال';
  @override
  String get goOnline => 'الاتصال';
  @override
  String get youAreNowOffline => 'أنت الآن غير متصل';
  @override
  String get youAreNowOnline => 'أنت الآن متصل';
  @override
  String get onlineLookingForPlayers => 'متصل - البحث عن لاعبين';
  @override
  String get offline => 'غير متصل';
  
  // Profile Edit Screen
  @override
  String get editProfile => 'تعديل الملف الشخصي';
  @override
  String get chooseAvatar => 'اختر الصورة الرمزية';
  @override
  String get username => 'اسم المستخدم';
  @override
  String get enterYourUsername => 'أدخل اسم المستخدم الخاص بك';
  @override
  String get yourUsername => 'اسم المستخدم الخاص بك';
  @override
  String get usernameIsRequired => 'اسم المستخدم مطلوب';
  @override
  String get usernameMustBeAtLeast3Characters => 'يجب أن يكون اسم المستخدم 3 أحرف على الأقل';
  @override
  String get usernameCanOnlyContainLettersNumbersUnderscores => 'يمكن أن يحتوي اسم المستخدم على أحرف وأرقام وشرطات سفلية فقط';
  @override
  String get usernameRules => '• 3-20 حرف\n• أحرف وأرقام وشرطات سفلية فقط\n• يجب أن يكون فريداً';
  @override
  String get saveProfile => 'حفظ الملف الشخصي';
  @override
  String get randomAvatar => 'صورة رمزية عشوائية';
  @override
  String get usernameIsAlreadyTaken => 'اسم المستخدم مستخدم بالفعل';
  @override
  String get errorCheckingUsernameAvailability => 'خطأ في التحقق من توفر اسم المستخدم';
  
  // Daily Challenge Screen
  @override
  String get todaysClue => 'دليل اليوم:';
  @override
  String get todaysResult => 'نتيجة اليوم';
  // correctAnswer already exists above
  @override
  String get challengeComplete => 'تم إكمال التحدي!';
  @override
  String get comeBackTomorrow => 'عد غداً لتحدي جديد!';
  @override
  String get todaysLeaderboard => 'قائمة متصدري اليوم';
  @override
  String get noPlayersYetToday => 'لا يوجد لاعبون اليوم بعد';
  @override
  String get beTheFirstToComplete => 'كن أول من يكمل تحدي اليوم!';
  @override
  String get yourStatistics => 'إحصائياتك';
  // currentStreak already exists above
  @override
  String get daysPlayed => 'أيام اللعب';
  @override
  String get perfectDays => 'أيام مثالية';
  @override
  String get bestStreak => 'أفضل مسلسل';
  @override
  String get avgScore => 'متوسط النقاط';
  @override
  String get avgAccuracy => 'متوسط الدقة';
  @override
  String get bestScore => 'أفضل نقاط';
  @override
  String get challenge => 'التحدي';
  // leaderboard already exists above
  @override
  String get stats => 'الإحصائيات';
  @override
  String get refresh => 'تحديث';
  
  // Campaign Screen
  @override
  String get loadingCampaign => 'جاري تحميل الحملة...';
  @override
  String get failedToLoadCampaign => 'فشل في تحميل الحملة';
  // section already exists above
  // level already exists above
  @override
  String get levels => 'المستويات';
  @override
  String get complete => 'مكتمل';
  @override
  String get campaignSections => 'أقسام الحملة';
  @override
  String get completePreviousSectionToUnlock => 'أكمل القسم السابق بـ 22+ نجمة للفتح';

  // Missing multiplayer strings
  @override
  String get testBotRemoved => 'تم إزالة الروبوت التجريبي';
  
  @override
  String get testBotAdded => 'تم إضافة الروبوت التجريبي';
  
  @override
  String get failedToManageBot => 'فشل في إدارة الروبوت';
  
  @override
  String get numberOfRounds => 'عدد الجولات';
  
  @override
  String get backgroundMusic => 'الموسيقى الخلفية';
  
  @override
  String get spectrumTheme => 'مظهر المؤشر';
  
  @override
  String get clue => 'التلميح';
  
  @override
  String get finalizeRound => 'إنهاء الجولة';
  
  @override
  String get pleaseLogInToViewProfile => 'يرجى تسجيل الدخول لعرض ملفك الشخصي';
  
  @override
  String get avatarChangedSuccessfully => 'تم تغيير الصورة الرمزية بنجاح!';
  
  @override
  String get errorChangingAvatar => 'خطأ في تغيير الصورة الرمزية';
  
  @override
  String get usernameChangedSuccessfully => 'تم تغيير اسم المستخدم بنجاح!';
  
  @override
  String get errorChangingUsername => 'خطأ في تغيير اسم المستخدم';
  
  @override
  String get avatarPackPurchasedSuccessfully => 'تم شراء حزمة الصور الرمزية بنجاح!';
  
  @override
  String get failedToPurchaseAvatarPack => 'فشل في شراء حزمة الصور الرمزية. تحقق من رصيد الجواهر.';
  
  @override
  String get errorPurchasingPack => 'خطأ في شراء الحزمة';
  
  @override
  String get changeUsername => 'تغيير اسم المستخدم';
  
  @override
  String get cost => 'التكلفة';
  
  @override
  String get enterNewUsername => 'أدخل اسم مستخدم جديد';
  
  @override
  String get change => 'تغيير';
  
  
  @override
  String get avatarSelectionComingSoon => 'اختيار الصور الرمزية قريباً!';

  // Solo features strings
  @override
  String get bundleSuggestionSubmittedSuccessfully => 'تم إرسال اقتراح الحزمة بنجاح!';
  
  @override
  String get failedToSubmitSuggestion => 'فشل في إرسال الاقتراح';
  
  @override
  String get failedToUpdateStatus => 'فشل في تحديث الحالة';
  
  @override
  String get roomCreatedWith => 'تم إنشاء غرفة مع';
  
  @override
  String get failedToCreateRoom => 'فشل في إنشاء الغرفة';
  
  @override
  String get play => 'العب';
  
  @override
  String get notAvailable => 'غير متاح';
  
  @override
  String get thisScreenOnlyAvailableInDebugMode => 'هذه الشاشة متاحة فقط في وضع التطوير.';
  
  @override
  String get waveSpectrumTest => 'اختبار طيف الموجة';
  
  @override
  String get resetToDefault => 'إعادة تعيين إلى الافتراضي';
  
  @override
  String get premiumPurchaseComingSoon => 'شراء بريميوم قريباً!';

  // Reward system strings
  @override
  String get campaignProgress => 'تقدم الحملة';
  
  @override
  String get mindReaders => 'قارئو العقول!';
  
  @override
  String get incredible => 'مذهل!';
  
  @override
  String get greatJob => 'عمل رائع!';
  
  @override
  String get goodEffort => 'جهد جيد!';
  
  @override
  String get tryAgain => 'حاول مرة أخرى!';
  
  @override
  String get analyticsDataCopiedToClipboard => 'تم نسخ بيانات التحليلات إلى الحافظة!';
  
  @override
  String get exportFailed => 'فشل التصدير';

  // Remaining screen strings
  @override
  String get settingUpRound => 'جاري إعداد الجولة...';
  
  @override
  String get tokens => 'الرموز';

  // Campaign and tasks strings
  @override
  String get best => 'الأفضل';

  // Campaign section titles/descriptions
  @override
  String get campaignSection1Title => 'رحلة المبتدئين';
  @override
  String get campaignSection1Desc => 'تعلّم الأساسيات بتحديات واضحة وبديهية';
  @override
  String get campaignSection2Title => 'تحدٍّ متصاعد';
  @override
  String get campaignSection2Desc => 'صعوبات متنوعة بينما تطوّر مهاراتك';
  @override
  String get campaignSection3Title => 'أرض الخبراء';
  @override
  String get campaignSection3Desc => 'تحديات صعبة تتطلب دقة وخبرة';
  @override
  String get campaignSection4Title => 'اختبار الأساتذة الكبار';
  @override
  String get campaignSection4Desc => 'تحديات قصوى للمحترفين الحقيقيين';

  // Campaign level and daily challenge strings
  @override
  String get easy => 'سهل';
  
  @override
  String get medium => 'متوسط';
  
  @override
  String get hard => 'صعب';
  
  @override
  String get expert => 'خبير';
}
