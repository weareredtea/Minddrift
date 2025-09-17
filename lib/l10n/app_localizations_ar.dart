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
}
