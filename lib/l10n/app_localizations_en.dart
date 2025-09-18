// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wave';

  @override
  String get homeSubtitle =>
      'Create or join a room to start drifting your mind!';

  @override
  String get createRoom => 'Create Room';

  @override
  String get or => 'OR';

  @override
  String get enterCodeHint => 'Enter Room Code';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get enableSaboteur => 'Enable Saboteur Mode';

  @override
  String get enableDiceRoll => 'Enable Dice Roll Feature';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get settingsSaved => 'Settings saved!';

  @override
  String get tutorialTitle1 => 'Create or Join a Room';

  @override
  String get tutorialDesc1 =>
      'Tap \"Create Room\" to start a new game, or enter a code to join friends.';

  @override
  String get tutorialTitle2 => 'Roles are Assigned';

  @override
  String get tutorialDesc2 =>
      'One Navigator, one Saboteur, and the rest are Guessers each round.';

  @override
  String get tutorialTitle3 => 'Navigator Gives a Clue';

  @override
  String get tutorialDesc3 =>
      'The Navigator sees the hidden target and gives a one‑word hint.';

  @override
  String get tutorialTitle4 => 'Guessers Place Their Bets';

  @override
  String get tutorialDesc4 =>
      'Guessers set their slider where they think the target lies.';

  @override
  String get tutorialTitle5 => 'Saboteur Tries to Mislead';

  @override
  String get tutorialDesc5 =>
      'One secret Saboteur places a guess to throw the team off course.';

  @override
  String get tutorialTitle6 => 'Reveal & Score!';

  @override
  String get tutorialDesc6 =>
      'See everyone\'s guesses vs. the actual point, then tally the points.';

  @override
  String get skip => 'Skip';

  @override
  String get done => 'Done';

  @override
  String get getStarted => 'Get Started';

  @override
  String get roleRevealTitle => 'Role Reveal';

  @override
  String get youAreNavigator => 'You are the Navigator';

  @override
  String get youAreSaboteur => 'You are the Saboteur';

  @override
  String get youAreGuesser => 'You are a Guesser';

  @override
  String get continueButton => 'Continue';

  @override
  String get readyTitle => 'Ready Up';

  @override
  String get waitingForPlayers => 'Waiting for players…';

  @override
  String get readyButton => 'Ready';

  @override
  String get diceRollTitle => 'Dice Roll';

  @override
  String get rollTheDice => 'Roll the dice';

  @override
  String get rolling => 'Rolling…';

  @override
  String get setupRoundTitle => 'Setup Round';

  @override
  String get submitClue => 'Submit Clue';

  @override
  String get waitingClueTitle => 'Waiting for Clue';

  @override
  String get waitingForNavigator => 'Waiting for the Navigator…';

  @override
  String get guessRoundTitle => 'Guess Round';

  @override
  String get placeYourGuess => 'Place your guess';

  @override
  String get roundResultTitle => 'Round Results';

  @override
  String get yourScore => 'Your score';

  @override
  String get nextRound => 'Next round';

  @override
  String get matchSummaryTitle => 'Match Summary';

  @override
  String get finalScores => 'Final scores';

  @override
  String get playAgain => 'Play again';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get availableCategories => 'Available Categories';

  @override
  String get lockedCategories => 'Locked Categories';

  @override
  String get gameLobby => 'Game Lobby';

  @override
  String get addBot => 'Add Bot';

  @override
  String get roomCode => 'Room Code:';

  @override
  String get cancelReady => 'Cancel Ready';

  @override
  String get imReady => 'I\'m Ready';

  @override
  String get allReadyStartRound => 'All Ready — Start Round';

  @override
  String get waitingForPlayersToGetReady => 'Waiting for players to get ready...';

  @override
  String get allReadyWaitingForHost => 'All ready! Waiting for host to start...';

  @override
  String get exitGame => 'Exit Game?';

  @override
  String get exitGameConfirmation => 'Are you sure you want to exit this room? Other players will be notified.';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get youAreLastPlayer => 'You are the Last Player!';

  @override
  String get lastPlayerMessage => 'All other players have exited the room. You can invite other players, view the total score, or exit.';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String shareRoomId(String roomId) => 'Share room ID: $roomId';

  @override
  String get viewScoreboard => 'View Scoreboard';

  @override
  String get exitToHome => 'Exit to Home';

  @override
  String playerExited(String playerName) => '$playerName has exited the room.';

  @override
  String roundNumber(int roundNumber) => 'Round $roundNumber';

  @override
  String secret(String secret) => 'Secret: $secret';

  @override
  String groupGuess(String guess) => 'Group Guess: $guess';

  @override
  String scorePoints(int score) => 'Score: $score points';

  @override
  String time(String time) => 'Time: $time';

  @override
  String get noRoundsPlayed => 'No rounds played yet.';

  @override
  String get finalScore => 'Final Score!';

  @override
  String get playersInThisGame => 'Players in this Game';

  @override
  String get returnToHome => 'Return to Home';

  @override
  String get roundsPerMatch => 'Rounds per Match';

  @override
  String get gameMusic => 'Game Music';

  @override
  String get threeRounds => '3 Rounds';

  @override
  String get fiveRounds => '5 Rounds';

  @override
  String get sevenRounds => '7 Rounds';

  @override
  String get seekersMakeGuess => 'Seekers: Make the Guess';

  @override
  String get confirmGroupGuess => 'Confirm Group Guess';

  @override
  String get waitingForHostToContinue => 'Waiting for host to continue...';

  @override
  String get doubleScore => 'Double Score!';

  @override
  String get halfScore => 'Half Score!';

  @override
  String get navigatorGetsToken => 'Navigator gets a Token!';

  @override
  String get reverseSlider => 'Reverse Slider!';

  @override
  String get noClue => 'No Clue!';

  @override
  String get blindGuess => 'Blind Guess!';

  @override
  String get noEffect => 'No Effect';

  @override
  String get store => 'Store';

  @override
  String get owned => 'Owned';

  @override
  String get pleaseEnterRoomCode => 'Please enter a room code.';

  @override
  String errorCreatingRoom(String error) => 'Error creating room: $error';

  @override
  String errorJoiningRoom(String error) => 'Error joining room: $error';

  @override
  String get scoreboard => 'Scoreboard';

  @override
  String get lobby => 'Lobby';

  @override
  String get waitingForPlayersToJoin => 'Waiting for players to join…';

  @override
  String get imHereLetsGetReady => 'I\'m Here—Let\'s Get Ready';

  @override
  String uid(String uid) => 'UID: $uid';

  @override
  String error(String error) => 'Error: $error';

  @override
  String get navigatorDescription => 'Give a clever clue to guide your team!';

  @override
  String get saboteurDescription => 'Subtly mislead the team to make them miss!';

  @override
  String get seekerDescription => 'Work with your team to guess the position!';

  @override
  String get secretPositionSet => 'Your secret position is set — enter your clue';

  @override
  String get clueDisabledByEffect => 'Clue disabled by effect';

  @override
  String get oneWordClue => 'clue';

  @override
  String get confirmNoClue => 'Confirm No Clue';

  @override
  String navigatorThinking(String navigatorName) => '$navigatorName is thinking...';

  @override
  String get rollingTheDice => 'Rolling the dice...';

  @override
  String get bullseye => 'Bullseye!';

  @override
  String get howScoringWorks => 'How Scoring Works';

  @override
  String get scoringExplanation => 'The closer your team\'s guess is to the secret target, the more points you get!\n\nBullseye (0-2 away): 6 pts\nGreat (3-5 away): 4 pts\nGood (6-10 away): 3 pts\nOkay (11-15 away): 2 pts';

  @override
  String get gotIt => 'Got It!';

  @override
  String roundResults(int roundNumber) => 'Round $roundNumber Results';

  @override
  String navigatorWas(String navigatorName) => '$navigatorName was the Navigator';

  @override
  String get score => 'SCORE';

  @override
  String get ready => 'Ready!';

  @override
  String get readyForSummary => 'Ready for Summary';

  @override
  String get readyForNextRound => 'Ready for Next Round';

  @override
  String get waitingForOtherPlayersToGetReady => 'Waiting for other players to get ready...';

  @override
  String get showMatchSummary => 'Show Match Summary';

  @override
  String get startNextRound => 'Start Next Round';

  @override
  String get allAccessPass => 'All‑Access Pass';

  @override
  String get allAccessPassDescription => 'Unlocks all current & future bundles';

  @override
  String get horrorBundle => 'Horror Bundle';

  @override
  String get horrorBundleDescription => '20 spooky categories';

  @override
  String get kidsBundle => 'Kids Bundle';

  @override
  String get kidsBundleDescription => '20 fun categories for kids';

  @override
  String get foodBundle => 'Food Bundle';

  @override
  String get foodBundleDescription => '20 culinary categories for food lovers';

  @override
  String get natureBundle => 'Nature Bundle';

  @override
  String get natureBundleDescription => '20 nature-inspired categories for outdoor enthusiasts';

  @override
  String get fantasyBundle => 'Fantasy Bundle';

  @override
  String get fantasyBundleDescription => '20 magical categories for fantasy lovers';

  @override
  String get freeBundle => 'Free Bundle';

  @override
  String get categories => 'categories';
  String get selectBundlesForGameplay => 'Select Bundles for Gameplay';
  String get bundleSelectionSaved => 'Bundle selection saved';
  String get selectBundleForGame => 'Select Bundle for Game';
  String get selectBundleDescription => 'Choose which bundle to use for this game. All players will have access to these categories.';
  String get switchToEnglish => 'Switch to English';
  String get switchToArabic => 'التبديل إلى العربية';
  String get billingUnavailable => 'In-App Purchases Unavailable';
  String get billingUnavailableDescription => 'This device does not support in-app purchases. You can still view available bundles, but purchases will not work.';
  String get copyRoomCode => 'Copy room code';
  String get roomCodeCopied => 'Room code copied to clipboard!';

  @override
  String get premium => 'Premium';

  @override
  String get premiumTitle => 'Unlock Premium Features';

  @override
  String get premiumSubtitle => 'Get access to exclusive features and enhance your gaming experience';

  @override
  String get premiumFeatures => 'Premium Features';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get premiumPrice => 'One-time purchase. No recurring charges.';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get avatarCustomization => 'Avatar Customization';

  @override
  String get avatarCustomizationDesc => 'Upload and use your own custom avatars';

  @override
  String get groupChat => 'Group Chat';

  @override
  String get groupChatDesc => 'Chat with other players in the game room';

  @override
  String get voiceChat => 'Voice Chat';

  @override
  String get voiceChatDesc => 'Record and send voice messages';

  @override
  String get onlineMatchmaking => 'Online Matchmaking';

  @override
  String get onlineMatchmakingDesc => 'Play with random players online';

  @override
  String get chooseFromGallery => 'Gallery';

  @override
  String get takePhoto => 'Camera';

  @override
  String get getBundles => 'Get Bundles';

  @override
  String get getMoreBundlesMessage => 'Get more bundles to have more variety!';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAvatar => 'Delete Avatar';

  @override
  String get deleteAvatarConfirmation => 'Are you sure you want to delete this avatar? This action cannot be undone.';

  @override
  String get practiceMode => 'Practice Mode';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get campaignMode => 'Campaign Mode';

  // ===== NEW FEATURES ENGLISH TRANSLATIONS =====

  /// Gem Store related strings
  @override
  String get gemStore => 'Gem Store';
  @override
  String get gemStoreTitle => 'Gem Store';
  @override
  String get mindGems => 'Mind Gems';
  @override
  String get sliderSkins => 'Slider Skins';
  @override
  String get badges => 'Badges';
  @override
  String get avatarPacks => 'Avatar Packs';
  @override
  String get loadingStore => 'Loading Store...';
  @override
  String get confirmPurchase => 'Confirm Purchase';
  @override
  String get purchase => 'Purchase';
  // cancel already exists
  // owned already exists - using existing 'Owned'
  @override
  String get notEnoughGems => 'Not enough Gems!';
  @override
  String get purchaseSuccessful => 'Successfully purchased!';
  @override
  String get purchaseFailed => 'Purchase failed. Please try again.';
  @override
  String get animated => 'ANIMATED';
  @override
  String get retry => 'Retry';

  /// Quest System related strings
  @override
  String get quests => 'Quests';
  @override
  String get questsTitle => 'Quests';
  @override
  String get daily => 'Daily';
  @override
  String get weekly => 'Weekly';
  @override
  String get achievements => 'Achievements';
  @override
  String get special => 'Special';
  @override
  String get loadingQuests => 'Loading Quests...';
  @override
  String get progress => 'Progress';
  @override
  String get rewards => 'Rewards';
  @override
  String get completed => 'Completed';
  @override
  String get claimReward => 'Claim Reward';
  @override
  String get readyToClaim => 'Ready to Claim';
  @override
  String get inProgress => 'In Progress';
  @override
  String get questRewardClaimed => 'Quest reward claimed successfully!';
  @override
  String get questClaimFailed => 'Failed to claim reward. Please try again.';
  @override
  String get noDailyQuests => 'No daily quests available.\nCheck back tomorrow!';
  @override
  String get noWeeklyQuests => 'No weekly quests available.\nCheck back next week!';
  @override
  String get noAchievementQuests => 'No achievement quests available.\nKeep playing to unlock more!';
  @override
  String get noSpecialQuests => 'No special events running.\nStay tuned for limited-time quests!';

  /// Practice Mode related strings
  @override
  String get yourClue => 'Your Clue:';
  @override
  String get whereDoesThisBelong => 'Where does this clue belong?';
  @override
  String get yourGuess => 'Your Guess';
  @override
  String get correctAnswer => 'Correct Answer';
  @override
  String get submitGuess => 'Submit Guess';
  // score already exists - using existing 'SCORE'
  @override
  String get accuracy => 'Accuracy';
  @override
  String get gameTime => 'Time';
  @override
  String get nextChallenge => 'Next Challenge';
  @override
  String get newChallenge => 'New Challenge';

  /// Campaign Mode related strings
  @override
  String get campaign => 'Campaign';
  @override
  String get level => 'Level';
  @override
  String get section => 'Section';
  @override
  String get difficulty => 'Difficulty';
  @override
  String get stars => 'Stars';
  @override
  String get maxScore => 'Max Score';
  @override
  String get beginnerJourney => 'Beginner\'s Journey';
  @override
  String get risingChallenge => 'Rising Challenge';
  @override
  String get expertTerritory => 'Expert Territory';
  @override
  String get grandmasterGauntlet => 'Grandmaster Gauntlet';

  /// Daily Challenge related strings
  @override
  String get todaysChallenge => 'Today\'s Challenge';
  @override
  String get leaderboard => 'Leaderboard';
  @override
  String get streak => 'Streak';
  @override
  String get rank => 'Rank';
  @override
  String get submitAnswer => 'Submit Answer';
  @override
  String get yourRank => 'Your Rank';
  @override
  String get currentStreak => 'Current Streak';

  /// General UI strings
  @override
  String get playWithFriends => 'Play with Friends';
  @override
  String get playSolo => 'Play Solo';
  @override
  String get playByYourself => 'Play by Yourself';
  @override
  String get startGame => 'Start Game';
  @override
  String get gems => 'Gems';
  // store already exists
  // settings already exists
  @override
  String get loading => 'Loading...';
  // error already exists (as function)
  @override
  String get back => 'Back';
  @override
  String get errorLoadingChallenge => 'Error loading daily challenge';
  @override
  String get errorSubmittingResult => 'Error submitting result';
  @override
  String get unknownBundle => 'Unknown Bundle';
  @override
  String get noSpecialEffect => 'No Special Effect';
  @override
  String get errorGeneric => 'Error';
  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';
  @override
  String get errorUpdatingProfile => 'Error updating profile';
  @override
  String get errorLoadingProfile => 'Error loading profile';
  @override
  String get failedToSendMessage => 'Failed to send message';
  @override
  String get voiceRecordingComingSoon => 'Voice recording coming soon!';
  @override
  String get failedToPlayVoiceMessage => 'Failed to play voice message';
  @override
  String get voiceChatRequiresPremium => 'Voice chat requires Premium';
  @override
  String get errorSavingBundleSelections => 'Error saving bundle selections';
  @override
  String get loadingBundleSelections => 'Loading bundle selections...';
  @override
  String get you => 'You';
  @override
  String get operationTimedOut => 'Operation timed out';
  @override
  String get premiumFeature => 'Premium Feature';
  @override
  String get upgradeToPremiumNew => 'Upgrade to Premium';
  @override
  String get customUsername => 'Custom Username';
  @override
  String get currentUsername => 'Current Username';
  @override
  String get suggestBundle => 'Suggest Bundle';
  @override
  String get bundleName => 'Bundle Name';
  @override
  String get description => 'Description';
  @override
  String get pleaseEnterBundleName => 'Please enter a bundle name';
  @override
  String get pleaseEnterDescription => 'Please enter a description';
  @override
  String get pleaseSelectAtLeastOneCategory => 'Please select at least one category';
  @override
  String get anonymous => 'Anonymous';
  @override
  String get onlineMatchmakingNew => 'Online Matchmaking';
  @override
  String get goOffline => 'Go Offline';
  @override
  String get goOnline => 'Go Online';
  @override
  String get youAreNowOffline => 'You are now offline';
  @override
  String get youAreNowOnline => 'You are now online';
  @override
  String get onlineLookingForPlayers => 'Online - Looking for players';
  @override
  String get offline => 'Offline';
  
  // Profile Edit Screen
  @override
  String get editProfile => 'Edit Profile';
  @override
  String get chooseAvatar => 'Choose Avatar';
  @override
  String get username => 'Username';
  @override
  String get enterYourUsername => 'Enter your username';
  @override
  String get yourUsername => 'Your Username';
  @override
  String get usernameIsRequired => 'Username is required';
  @override
  String get usernameMustBeAtLeast3Characters => 'Username must be at least 3 characters';
  @override
  String get usernameCanOnlyContainLettersNumbersUnderscores => 'Username can only contain letters, numbers, and underscores';
  @override
  String get usernameRules => '• 3-20 characters\n• Letters, numbers, and underscores only\n• Must be unique';
  @override
  String get saveProfile => 'Save Profile';
  @override
  String get randomAvatar => 'Random Avatar';
  @override
  String get usernameIsAlreadyTaken => 'Username is already taken';
  @override
  String get errorCheckingUsernameAvailability => 'Error checking username availability';
  
  // Daily Challenge Screen
  @override
  String get todaysClue => 'Today\'s Clue:';
  @override
  String get todaysResult => 'Today\'s Result';
  // correctAnswer already exists above
  @override
  String get challengeComplete => 'Challenge Complete!';
  @override
  String get comeBackTomorrow => 'Come back tomorrow for a new challenge!';
  @override
  String get todaysLeaderboard => 'Today\'s Leaderboard';
  @override
  String get noPlayersYetToday => 'No players yet today';
  @override
  String get beTheFirstToComplete => 'Be the first to complete today\'s challenge!';
  @override
  String get yourStatistics => 'Your Statistics';
  // currentStreak already exists above
  @override
  String get daysPlayed => 'Days Played';
  @override
  String get perfectDays => 'Perfect Days';
  @override
  String get bestStreak => 'Best Streak';
  @override
  String get avgScore => 'Avg Score';
  @override
  String get avgAccuracy => 'Avg Accuracy';
  @override
  String get bestScore => 'Best Score';
  @override
  String get challenge => 'Challenge';
  // leaderboard already exists above
  @override
  String get stats => 'Stats';
  @override
  String get refresh => 'Refresh';
  
  // Campaign Screen
  @override
  String get loadingCampaign => 'Loading Campaign...';
  @override
  String get failedToLoadCampaign => 'Failed to load campaign';
  // section already exists above
  // level already exists above
  @override
  String get levels => 'Levels';
  @override
  String get complete => 'Complete';
  @override
  String get campaignSections => 'Campaign Sections';
  @override
  String get completePreviousSectionToUnlock => 'Complete previous section with 22+ stars to unlock';
}
