import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mind Drift'**
  String get appTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create or join a room to start drifting your mind!'**
  String get homeSubtitle;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @enterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Room Code'**
  String get enterCodeHint;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get joinRoom;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @enableSaboteur.
  ///
  /// In en, this message translates to:
  /// **'Enable Saboteur Mode'**
  String get enableSaboteur;

  /// No description provided for @enableDiceRoll.
  ///
  /// In en, this message translates to:
  /// **'Enable Dice Roll Feature'**
  String get enableDiceRoll;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved!'**
  String get settingsSaved;

  /// No description provided for @tutorialTitle1.
  ///
  /// In en, this message translates to:
  /// **'Create or Join a Room'**
  String get tutorialTitle1;

  /// No description provided for @tutorialDesc1.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Create Room\" to start a new game, or enter a code to join friends.'**
  String get tutorialDesc1;

  /// No description provided for @tutorialTitle2.
  ///
  /// In en, this message translates to:
  /// **'Roles are Assigned'**
  String get tutorialTitle2;

  /// No description provided for @tutorialDesc2.
  ///
  /// In en, this message translates to:
  /// **'One Navigator, one Saboteur, and the rest are Guessers each round.'**
  String get tutorialDesc2;

  /// No description provided for @tutorialTitle3.
  ///
  /// In en, this message translates to:
  /// **'Navigator Gives a Clue'**
  String get tutorialTitle3;

  /// No description provided for @tutorialDesc3.
  ///
  /// In en, this message translates to:
  /// **'The Navigator sees the hidden target and gives a one‑word hint.'**
  String get tutorialDesc3;

  /// No description provided for @tutorialTitle4.
  ///
  /// In en, this message translates to:
  /// **'Guessers Place Their Bets'**
  String get tutorialTitle4;

  /// No description provided for @tutorialDesc4.
  ///
  /// In en, this message translates to:
  /// **'Guessers set their slider where they think the target lies.'**
  String get tutorialDesc4;

  /// No description provided for @tutorialTitle5.
  ///
  /// In en, this message translates to:
  /// **'Saboteur Tries to Mislead'**
  String get tutorialTitle5;

  /// No description provided for @tutorialDesc5.
  ///
  /// In en, this message translates to:
  /// **'One secret Saboteur places a guess to throw the team off course.'**
  String get tutorialDesc5;

  /// No description provided for @tutorialTitle6.
  ///
  /// In en, this message translates to:
  /// **'Reveal & Score!'**
  String get tutorialTitle6;

  /// No description provided for @tutorialDesc6.
  ///
  /// In en, this message translates to:
  /// **'See everyone's guesses vs. the actual point, then tally the points.'**
  String get tutorialDesc6;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @roleRevealTitle.
  ///
  /// In en, this message translates to:
  /// **'Role Reveal'**
  String get roleRevealTitle;

  /// No description provided for @youAreNavigator.
  ///
  /// In en, this message translates to:
  /// **'You are the Navigator'**
  String get youAreNavigator;

  /// No description provided for @youAreSaboteur.
  ///
  /// In en, this message translates to:
  /// **'You are the Saboteur'**
  String get youAreSaboteur;

  /// No description provided for @youAreGuesser.
  ///
  /// In en, this message translates to:
  /// **'You are a Guesser'**
  String get youAreGuesser;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @readyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready Up'**
  String get readyTitle;

  /// No description provided for @waitingForPlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for players…'**
  String get waitingForPlayers;

  /// No description provided for @readyButton.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get readyButton;

  /// No description provided for @diceRollTitle.
  ///
  /// In en, this message translates to:
  /// **'Dice Roll'**
  String get diceRollTitle;

  /// No description provided for @rollTheDice.
  ///
  /// In en, this message translates to:
  /// **'Roll the dice'**
  String get rollTheDice;

  /// No description provided for @rolling.
  ///
  /// In en, this message translates to:
  /// **'Rolling…'**
  String get rolling;

  /// No description provided for @setupRoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup Round'**
  String get setupRoundTitle;

  /// No description provided for @submitClue.
  ///
  /// In en, this message translates to:
  /// **'Submit Clue'**
  String get submitClue;

  /// No description provided for @waitingClueTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Clue'**
  String get waitingClueTitle;

  /// No description provided for @waitingForNavigator.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the Navigator…'**
  String get waitingForNavigator;

  /// No description provided for @guessRoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Guess Round'**
  String get guessRoundTitle;

  /// No description provided for @placeYourGuess.
  ///
  /// In en, this message translates to:
  /// **'Place your guess'**
  String get placeYourGuess;

  /// No description provided for @roundResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Round Results'**
  String get roundResultTitle;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your score'**
  String get yourScore;

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **'Next round'**
  String get nextRound;

  /// No description provided for @matchSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Match Summary'**
  String get matchSummaryTitle;

  /// No description provided for @finalScores.
  ///
  /// In en, this message translates to:
  /// **'Final scores'**
  String get finalScores;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @availableCategories.
  ///
  /// In en, this message translates to:
  /// **'Available Categories'**
  String get availableCategories;

  /// No description provided for @lockedCategories.
  ///
  /// In en, this message translates to:
  /// **'Locked Categories'**
  String get lockedCategories;

  /// No description provided for @gameLobby.
  ///
  /// In en, this message translates to:
  /// **'Game Lobby'**
  String get gameLobby;

  /// No description provided for @addBot.
  ///
  /// In en, this message translates to:
  /// **'Add Bot'**
  String get addBot;

  /// No description provided for @roomCode.
  ///
  /// In en, this message translates to:
  /// **'Room Code:'**
  String get roomCode;

  /// No description provided for @cancelReady.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ready'**
  String get cancelReady;

  /// No description provided for @imReady.
  ///
  /// In en, this message translates to:
  /// **'I\'m Ready'**
  String get imReady;

  /// No description provided for @allReadyStartRound.
  ///
  /// In en, this message translates to:
  /// **'All Ready — Start Round'**
  String get allReadyStartRound;



  /// No description provided for @waitingForPlayersToGetReady.
  ///
  /// In en, this message translates to:
  /// **'Waiting for players to get ready...'**
  String get waitingForPlayersToGetReady;

  /// No description provided for @allReadyWaitingForHost.
  ///
  /// In en, this message translates to:
  /// **'All ready! Waiting for host to start...'**
  String get allReadyWaitingForHost;

  /// No description provided for @exitGame.
  ///
  /// In en, this message translates to:
  /// **'Exit Game?'**
  String get exitGame;

  /// No description provided for @exitGameConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit this room? Other players will be notified.'**
  String get exitGameConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @youAreLastPlayer.
  ///
  /// In en, this message translates to:
  /// **'You are the Last Player!'**
  String get youAreLastPlayer;

  /// No description provided for @lastPlayerMessage.
  ///
  /// In en, this message translates to:
  /// **'All other players have exited the room. You can invite other players, view the total score, or exit.'**
  String get lastPlayerMessage;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @shareRoomId.
  ///
  /// In en, this message translates to:
  /// **'Share room ID: {roomId}'**
  String shareRoomId(String roomId);

  /// No description provided for @viewScoreboard.
  ///
  /// In en, this message translates to:
  /// **'View Scoreboard'**
  String get viewScoreboard;

  /// No description provided for @exitToHome.
  ///
  /// In en, this message translates to:
  /// **'Exit to Home'**
  String get exitToHome;

  /// No description provided for @playerExited.
  ///
  /// In en, this message translates to:
  /// **'{playerName} has exited the room.'**
  String playerExited(String playerName);

  /// No description provided for @roundNumber.
  ///
  /// In en, this message translates to:
  /// **'Round {roundNumber}'**
  String roundNumber(int roundNumber);

  /// No description provided for @secret.
  ///
  /// In en, this message translates to:
  /// **'Secret: {secret}'**
  String secret(String secret);

  /// No description provided for @groupGuess.
  ///
  /// In en, this message translates to:
  /// **'Group Guess: {guess}'**
  String groupGuess(String guess);

  /// No description provided for @scorePoints.
  ///
  /// In en, this message translates to:
  /// **'Score: {score} points'**
  String scorePoints(int score);

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String time(String time);

  /// No description provided for @noRoundsPlayed.
  ///
  /// In en, this message translates to:
  /// **'No rounds played yet.'**
  String get noRoundsPlayed;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score!'**
  String get finalScore;

  /// No description provided for @playersInThisGame.
  ///
  /// In en, this message translates to:
  /// **'Players in this Game'**
  String get playersInThisGame;

  /// No description provided for @returnToHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get returnToHome;

  /// No description provided for @roundsPerMatch.
  ///
  /// In en, this message translates to:
  /// **'Rounds per Match'**
  String get roundsPerMatch;

  /// No description provided for @gameMusic.
  ///
  /// In en, this message translates to:
  /// **'Game Music'**
  String get gameMusic;

  /// No description provided for @threeRounds.
  ///
  /// In en, this message translates to:
  /// **'3 Rounds'**
  String get threeRounds;

  /// No description provided for @fiveRounds.
  ///
  /// In en, this message translates to:
  /// **'5 Rounds'**
  String get fiveRounds;

  /// No description provided for @sevenRounds.
  ///
  /// In en, this message translates to:
  /// **'7 Rounds'**
  String get sevenRounds;

  /// No description provided for @seekersMakeGuess.
  ///
  /// In en, this message translates to:
  /// **'Seekers: Make the Guess'**
  String get seekersMakeGuess;

  /// No description provided for @confirmGroupGuess.
  ///
  /// In en, this message translates to:
  /// **'Confirm Group Guess'**
  String get confirmGroupGuess;

  /// No description provided for @waitingForHostToContinue.
  ///
  /// In en, this message translates to:
  /// **'Waiting for host to continue...'**
  String get waitingForHostToContinue;

  /// No description provided for @doubleScore.
  ///
  /// In en, this message translates to:
  /// **'Double Score!'**
  String get doubleScore;

  /// No description provided for @halfScore.
  ///
  /// In en, this message translates to:
  /// **'Half Score!'**
  String get halfScore;

  /// No description provided for @navigatorGetsToken.
  ///
  /// In en, this message translates to:
  /// **'Navigator gets a Token!'**
  String get navigatorGetsToken;

  /// No description provided for @reverseSlider.
  ///
  /// In en, this message translates to:
  /// **'Reverse Slider!'**
  String get reverseSlider;

  /// No description provided for @noClue.
  ///
  /// In en, this message translates to:
  /// **'No Clue!'**
  String get noClue;

  /// No description provided for @blindGuess.
  ///
  /// In en, this message translates to:
  /// **'Blind Guess!'**
  String get blindGuess;

  /// No description provided for @noEffect.
  ///
  /// In en, this message translates to:
  /// **'No Effect'**
  String get noEffect;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @pleaseEnterRoomCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a room code.'**
  String get pleaseEnterRoomCode;

  /// No description provided for @errorCreatingRoom.
  ///
  /// In en, this message translates to:
  /// **'Error creating room: {error}'**
  String errorCreatingRoom(String error);

  /// No description provided for @errorJoiningRoom.
  ///
  /// In en, this message translates to:
  /// **'Error joining room: {error}'**
  String errorJoiningRoom(String error);



  /// No description provided for @scoreboard.
  ///
  /// In en, this message translates to:
  /// **'Scoreboard'**
  String get scoreboard;

  /// No description provided for @lobby.
  ///
  /// In en, this message translates to:
  /// **'Lobby'**
  String get lobby;

  /// No description provided for @waitingForPlayersToJoin.
  ///
  /// In en, this message translates to:
  /// **'Waiting for players to join…'**
  String get waitingForPlayersToJoin;

  /// No description provided for @imHereLetsGetReady.
  ///
  /// In en, this message translates to:
  /// **'I\'m Here—Let's Get Ready'**
  String get imHereLetsGetReady;

  /// No description provided for @uid.
  ///
  /// In en, this message translates to:
  /// **'UID: {uid}'**
  String uid(String uid);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @navigatorDescription.
  ///
  /// In en, this message translates to:
  /// **'Give a clever clue to guide your team!'**
  String get navigatorDescription;

  /// No description provided for @saboteurDescription.
  ///
  /// In en, this message translates to:
  /// **'Subtly mislead the team to make them miss!'**
  String get saboteurDescription;

  /// No description provided for @seekerDescription.
  ///
  /// In en, this message translates to:
  /// **'Work with your team to guess the position!'**
  String get seekerDescription;

  /// No description provided for @secretPositionSet.
  ///
  /// In en, this message translates to:
  /// **'Your secret position is set — enter your clue'**
  String get secretPositionSet;

  /// No description provided for @clueDisabledByEffect.
  ///
  /// In en, this message translates to:
  /// **'Clue disabled by effect'**
  String get clueDisabledByEffect;

  /// No description provided for @oneWordClue.
  ///
  /// In en, this message translates to:
  /// **'One-word clue'**
  String get oneWordClue;

  /// No description provided for @confirmNoClue.
  ///
  /// In en, this message translates to:
  /// **'Confirm No Clue'**
  String get confirmNoClue;

  /// No description provided for @navigatorThinking.
  ///
  /// In en, this message translates to:
  /// **'{navigatorName} is thinking...'**
  String navigatorThinking(String navigatorName);

  /// No description provided for @rollingTheDice.
  ///
  /// In en, this message translates to:
  /// **'Rolling the dice...'**
  String get rollingTheDice;

  /// No description provided for @bullseye.
  ///
  /// In en, this message translates to:
  /// **'Bullseye!'**
  String get bullseye;

  /// No description provided for @howScoringWorks.
  ///
  /// In en, this message translates to:
  /// **'How Scoring Works'**
  String get howScoringWorks;

  /// No description provided for @scoringExplanation.
  ///
  /// In en, this message translates to:
  /// **'The closer your team's guess is to the secret target, the more points you get!\n\nBullseye (0-2 away): 6 pts\nGreat (3-5 away): 4 pts\nGood (6-10 away): 3 pts\nOkay (11-15 away): 2 pts'**
  String get scoringExplanation;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It!'**
  String get gotIt;

  /// No description provided for @roundResults.
  ///
  /// In en, this message translates to:
  /// **'Round {roundNumber} Results'**
  String roundResults(int roundNumber);

  /// No description provided for @navigatorWas.
  ///
  /// In en, this message translates to:
  /// **'{navigatorName} was the Navigator'**
  String navigatorWas(String navigatorName);

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get score;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready!'**
  String get ready;

  /// No description provided for @readyForSummary.
  ///
  /// In en, this message translates to:
  /// **'Ready for Summary'**
  String get readyForSummary;

  /// No description provided for @readyForNextRound.
  ///
  /// In en, this message translates to:
  /// **'Ready for Next Round'**
  String get readyForNextRound;

  /// No description provided for @waitingForOtherPlayersToGetReady.
  ///
  /// In en, this message translates to:
  /// **'Waiting for other players to get ready...'**
  String get waitingForOtherPlayersToGetReady;

  /// No description provided for @showMatchSummary.
  ///
  /// In en, this message translates to:
  /// **'Show Match Summary'**
  String get showMatchSummary;

  /// No description provided for @startNextRound.
  ///
  /// In en, this message translates to:
  /// **'Start Next Round'**
  String get startNextRound;

  /// No description provided for @allAccessPass.
  ///
  /// In en, this message translates to:
  /// **'All‑Access Pass'**
  String get allAccessPass;

  /// No description provided for @allAccessPassDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlocks all current & future bundles'**
  String get allAccessPassDescription;

  /// No description provided for @horrorBundle.
  ///
  /// In en, this message translates to:
  /// **'Horror Bundle'**
  String get horrorBundle;

  /// No description provided for @horrorBundleDescription.
  ///
  /// In en, this message translates to:
  /// **'20 spooky categories'**
  String get horrorBundleDescription;

  /// No description provided for @kidsBundle.
  ///
  /// In en, this message translates to:
  /// **'Kids Bundle'**
  String get kidsBundle;

  /// No description provided for @kidsBundleDescription.
  ///
  /// In en, this message translates to:
  /// **'20 fun categories for kids'**
  String get kidsBundleDescription;

  /// No description provided for @foodBundle.
  ///
  /// In en, this message translates to:
  /// **'Food Bundle'**
  String get foodBundle;

  /// No description provided for @foodBundleDescription.
  ///
  /// In en, this message translates to:
  /// **'20 culinary categories for food lovers'**
  String get foodBundleDescription;

  /// No description provided for @natureBundle.
  ///
  /// In en, this message translates to:
  /// **'Nature Bundle'**
  String get natureBundle;

  /// No description provided for @natureBundleDescription.
  ///
  /// In en, this message translates to:
  /// **'20 nature-inspired categories for outdoor enthusiasts'**
  String get natureBundleDescription;

  /// No description provided for @fantasyBundle.
  ///
  /// In en, this message translates to:
  /// **'Fantasy Bundle'**
  String get fantasyBundle;

  /// No description provided for @fantasyBundleDescription.
  ///
  /// In en, this message translates to:
  /// **'20 magical categories for fantasy lovers'**
  String get fantasyBundleDescription;

  /// No description provided for @selectBundlesForGameplay.
  ///
  /// In en, this message translates to:
  /// **'Select Bundles for Gameplay'**
  String get selectBundlesForGameplay;

  /// No description provided for @bundleSelectionSaved.
  ///
  /// In en, this message translates to:
  /// **'Bundle selection saved'**
  String get bundleSelectionSaved;

  /// No description provided for @selectBundleForGame.
  ///
  /// In en, this message translates to:
  /// **'Select Bundle for Game'**
  String get selectBundleForGame;

  /// No description provided for @selectBundleDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose which bundle to use for this game. All players will have access to these categories.'**
  String get selectBundleDescription;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'التبديل إلى العربية'**
  String get switchToArabic;

  /// No description provided for @billingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'In-App Purchases Unavailable'**
  String get billingUnavailable;

  /// No description provided for @billingUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'This device does not support in-app purchases. You can still view available bundles, but purchases will not work.'**
  String get billingUnavailableDescription;

  /// No description provided for @copyRoomCode.
  ///
  /// In en, this message translates to:
  /// **'Copy room code'**
  String get copyRoomCode;

  /// No description provided for @roomCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Room code copied to clipboard!'**
  String get roomCodeCopied;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Features'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get access to exclusive features and enhance your gaming experience'**
  String get premiumSubtitle;

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get premiumActive;

  /// No description provided for @premiumPrice.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. No commitment.'**
  String get premiumPrice;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @avatarCustomization.
  ///
  /// In en, this message translates to:
  /// **'Avatar Customization'**
  String get avatarCustomization;

  /// No description provided for @avatarCustomizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload and use your own custom avatars'**
  String get avatarCustomizationDesc;

  /// No description provided for @groupChat.
  ///
  /// In en, this message translates to:
  /// **'Group Chat'**
  String get groupChat;

  /// No description provided for @groupChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Chat with other players in the game room'**
  String get groupChatDesc;

  /// No description provided for @voiceChat.
  ///
  /// In en, this message translates to:
  /// **'Voice Chat'**
  String get voiceChat;

  /// No description provided for @voiceChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Record and send voice messages'**
  String get voiceChatDesc;

  /// No description provided for @onlineMatchmaking.
  ///
  /// In en, this message translates to:
  /// **'Online Matchmaking'**
  String get onlineMatchmaking;

  /// No description provided for @onlineMatchmakingDesc.
  ///
  /// In en, this message translates to:
  /// **'Play with random players online'**
  String get onlineMatchmakingDesc;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get takePhoto;

  /// No description provided for @getBundles.
  ///
  /// In en, this message translates to:
  /// **'Get Bundles'**
  String get getBundles;

  /// No description provided for @getMoreBundlesMessage.
  ///
  /// In en, this message translates to:
  /// **'Get more bundles to have more variety!'**
  String get getMoreBundlesMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAvatar.
  ///
  /// In en, this message translates to:
  /// **'Delete Avatar'**
  String get deleteAvatar;

  /// No description provided for @deleteAvatarConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this avatar? This action cannot be undone.'**
  String get deleteAvatarConfirmation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
