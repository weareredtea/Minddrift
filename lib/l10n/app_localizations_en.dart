// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'wave';

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
  String get foodBundle => 'Food Bundle';
  String get foodBundleDescription => '20 culinary categories for food lovers';
  String get natureBundle => 'Nature Bundle';
  String get natureBundleDescription => '20 nature-inspired categories for outdoor enthusiasts';
  String get fantasyBundle => 'Fantasy Bundle';
  String get fantasyBundleDescription => '20 magical categories for fantasy lovers';
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
}
