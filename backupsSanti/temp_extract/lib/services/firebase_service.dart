import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart'; // Import rxdart for stream combination
import 'package:wavelength_clone_fresh/models/avatar.dart';

import '../models/player_status.dart';
import '../models/round.dart';
import '../models/round_history_entry.dart';
import '../pigeon/pigeon.dart'; // Assuming PigeonUserDetails is here


class ReadyScreenViewModel {
  final bool isHost;
  final bool allPlayersReady;
  final List<PlayerStatus> players;
  final PlayerStatus? me;

  ReadyScreenViewModel({
    required this.isHost,
    required this.allPlayersReady,
    required this.players,
    this.me,
  });
}

class FirebaseService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _rnd = Random();

  // Correctly access __app_id and __initial_auth_token from environment variables
  // Provide default values if they are not defined (e.g., when running outside Canvas)
  final String _canvasAppId = const String.fromEnvironment('app_id', defaultValue: 'default-app-id');
  final String _canvasInitialAuthToken = const String.fromEnvironment('initial_auth_token');

  FirebaseService() {
    _initializeFirebaseAndAuth();
  }

  // --- Firebase Initialization and Authentication ---
  // This function is the single source of truth for authentication.
  Future<void> _initializeFirebaseAndAuth() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      if (_canvasInitialAuthToken.isNotEmpty) {
        try {
          await auth.signInWithCustomToken(_canvasInitialAuthToken);
          print('Signed in with custom token.');
        } catch (e) {
          print('Error signing in with custom token: $e');
          await auth.signInAnonymously();
          print('Signed in anonymously as fallback.');
        }
      } else {
        await auth.signInAnonymously();
        print('Signed in anonymously (no custom token).');
      }
    }
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  // Use null-aware operator for safety, though RoomNavigator checks auth status
  String get currentUserUid => _auth.currentUser?.uid ?? '';

  // Generate a random 4-character room code
  String _randomCode(int n) =>
      List.generate(n, (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[_rnd.nextInt(36)])
          .join();

  Future<bool> roomExists(String roomId) async =>
      (await _db.collection('rooms').doc(roomId).get()).exists;

  // --- Room Management ---

   /// Creates a new room with initial settings.
  Future<String> createRoom(bool saboteurEnabled, bool diceRollEnabled) async {
    // FIX: Removed the redundant signInAnonymously call.
    // We now assume the user is already authenticated by the service's constructor.
    if (currentUserUid.isEmpty) {
      throw Exception("User is not authenticated. Cannot create a room.");
    }

    String roomId;
    do {
      roomId = _randomCode(4);
    } while (await roomExists(roomId));

    final roomRef = _db.collection('rooms').doc(roomId);
    final String randomAvatarId = Avatars.getRandomAvatarId();

    // Use the class getter `currentUserUid` from the already-logged-in user.
    await roomRef.set({
      'creator': currentUserUid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'lobby',
      'saboteurEnabled': saboteurEnabled,
      'diceRollEnabled': diceRollEnabled,
      'currentRoundNumber': 0,
      'navigatorRotationIndex': 0,
      'playerOrder': [currentUserUid],
      'usedCategoryIds': [],
      'saboteurId': null,
    });

    await roomRef.collection('players').doc(currentUserUid).set({
      'displayName': 'Player-${currentUserUid.substring(0, 4)}',
      'isReady': false,
      'guessReady': false,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'totalScore': 0,
      'avatarId': randomAvatarId, // *** NEW: Save avatarId to Firestore ***
    });

    await roomRef.collection('players').doc(currentUserUid).set({
      'displayName': 'Player-${currentUserUid.substring(0, 4)}',
      'isReady': false,
      'guessReady': false,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'totalScore': 0,
    });

    await _seedCategories(roomId);
    await saveCurrentRoomId(roomId);

    notifyListeners();
    return roomId;
  }

  Stream<ReadyScreenViewModel> listenToReadyScreenViewModel(String roomId) {
    // This combines the stream of the room document and the players sub-collection
    return Rx.combineLatest2(
      roomDocRef(roomId).snapshots(),
      playersColRef(roomId).snapshots(),
      (roomDoc, playersSnap) {
        // Get data from the room document
        final roomData = roomDoc.data() ?? {};
        final hostUid = roomData['creator'] as String? ?? '';
        final myUid = currentUserUid;
        final isHost = hostUid == myUid;

        // Get data from the players collection
        final players = playersSnap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList();
        final allPlayersReady = players.isNotEmpty && players.every((p) => p.ready);
        
        PlayerStatus? me;
        if (players.any((p) => p.uid == myUid)) {
           me = players.firstWhere((p) => p.uid == myUid);
        }

        // Return a single, clean object with all the data the UI needs
        return ReadyScreenViewModel(
          isHost: isHost,
          allPlayersReady: allPlayersReady,
          players: players,
          me: me
        );
      },
    );
  }


 /// Joins an existing room.
  Future<void> joinRoom(String roomId) async {
    // FIX: Removed the redundant signInAnonymously call.
    if (currentUserUid.isEmpty) {
      throw Exception("User is not authenticated. Cannot join a room.");
    }

    final roomRef = _db.collection('rooms').doc(roomId);
    // Use the class getter `currentUserUid`
    final playerRef = roomRef.collection('players').doc(currentUserUid);

    await playerRef.set({
      'displayName': 'Player-${currentUserUid.substring(0, 4)}',
      'isReady': false,
      'guessReady': false,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'totalScore': 0,
      'tokens': 0,
    }, SetOptions(merge: true));

    await roomRef.update({
      'playerOrder': FieldValue.arrayUnion([currentUserUid]),
    });

    await saveCurrentRoomId(roomId);
    notifyListeners();
  }

  /// Removes a player from the room and updates playerOrder.
  Future<void> leaveRoom(String roomId) async {
    if (_auth.currentUser == null) return;
    final currentUserDisplayName = (await playersColRef(roomId).doc(currentUserUid).get()).data()?['displayName'] as String? ?? 'A player';

    // Remove player document
    await playersColRef(roomId).doc(currentUserUid).delete();

    // Remove player UID from playerOrder list in room document
    await roomDocRef(roomId).update({
      'playerOrder': FieldValue.arrayRemove([currentUserUid]),
    });

    // Clear currentRoomId for the user
    await saveCurrentRoomId(null);

    print('$currentUserDisplayName has left room $roomId');
  }

  // --- Category Management ---

  // Seeds predefined categories into a room's subcollection.
  Future<void> _seedCategories(String roomId) async {
    final cats = [
      {'id':'hot_cold','left':'HOT','right':'COLD'},
      {'id':'calm_noisy','left':'CALM','right':'NOISY'},
      {'id':'soft_rough','left':'SOFT','right':'ROUGH'},
      {'id':'fast_slow','left':'FAST','right':'SLOW'},
      {'id':'light_dark','left':'LIGHT','right':'DARK'},
      {'id':'sweet_sour','left':'SWEET','right':'SOUR'},
      {'id':'big_small','left':'BIG','right':'SMALL'},
      {'id':'strong_weak','left':'STRONG','right':'WEAK'},
      {'id':'old_new','left':'OLD','right':'NEW'},
      {'id':'happy_sad','left':'HAPPY','right':'SAD'},
      {'id':'brave_cowardly','left':'BRAVE','right':'COWARDLY'},
      {'id':'clean_dirty','left':'CLEAN','right':'DIRTY'},
      {'id':'empty_full','left':'EMPTY','right':'FULL'},
      {'id':'funny_serious','left':'FUNNY','right':'SERIOUS'},
      {'id':'hard_easy','left':'HARD','right':'EASY'},
      {'id':'heavy_light','left':'HEAVY','right':'LIGHT'},
      {'id':'kind_cruel','left':'KIND','right':'CRUEL'},
      {'id':'loud_quiet','left':'LOUD','right':'QUIET'},
      {'id':'open_closed','left':'OPEN','right':'CLOSED'},
      {'id':'rich_poor','left':'RICH','right':'POOR'},
      {'id':'safe_dangerous','left':'SAFE','right':'DANGEROUS'},
      {'id':'short_tall','left':'SHORT','right':'TALL'},
      {'id':'smooth_bumpy','left':'SMOOTH','right':'BUMPY'},
      {'id':'straight_curved','left':'STRAIGHT','right':'CURVED'},
      {'id':'thick_thin','left':'THICK','right':'THIN'},
      {'id':'tight_loose','left':'TIGHT','right':'LOOSE'},
      {'id':'true_false','left':'TRUE','right':'FALSE'},
      {'id':'wet_dry','left':'WET','right':'DRY'},
      {'id':'wide_narrow','left':'WIDE','right':'NARROW'},
      {'id':'young_old','left':'YOUNG','right':'OLD'},
    ];
    final col = _db.collection('rooms').doc(roomId).collection('categories');
    for (var c in cats) {
      await col.doc(c['id']!).set(c);
    }
  }

  // --- Round Specific References ---

  DocumentReference<Map<String,dynamic>> roomDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId);

  DocumentReference<Map<String,dynamic>> roundDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('rounds').doc('current');

  CollectionReference<Map<String,dynamic>> playersColRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('players');

  /// NEW: Fetches all players in a room as a Future<List<PlayerStatus>>.
  Future<List<PigeonUserDetails>> fetchPlayers(String roomId) async {
    final querySnapshot = await playersColRef(roomId).get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return PigeonUserDetails(
        uid: doc.id,
        displayName: data['displayName'] as String? ?? 'Anonymous',
        // If other fields like totalScore, tokens are needed, they should be
        // explicitly fetched here if PigeonUserDetails supports them.
        // Assuming PigeonUserDetails might only have uid and displayName for now.
        // If it requires totalScore and tokens, they need to be added to PigeonUserDetails.
        // For now, let's include them for completeness if PigeonUserDetails supports them,
        // otherwise, remove them. Assuming it has `totalScore` and `tokens`.
        totalScore: data['totalScore'] as int? ?? 0,
        tokens: data['tokens'] as int? ?? 0,
      );
    }).toList();
  }


  // --- Ready Phase (Lobby) ---

  /// Sets player's ready status in the lobby.
  Future<void> setReady(String roomId, bool ready) => playersColRef(roomId)
      .doc(currentUserUid)
      .update({'isReady': ready});

  /// Listens to all players' ready status for the lobby.
  Stream<List<PlayerStatus>> listenToReady(String roomId) =>
      playersColRef(roomId).snapshots().map((snap) {
        return snap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList();
      });

  // --- New Round Setup Helper ---

  Future<void> _setupNewRoundState(String roomId, {required bool isFirstRound}) async {
    // VVV ADD A PRINT STATEMENT AND A TRY-CATCH BLOCK VVV
    print('DEBUG: _setupNewRoundState function started.');
    try {
      final roomSnap = await roomDocRef(roomId).get();
      if (!roomSnap.exists) return;
      final roomData = roomSnap.data()!;

      List<String> playerOrder = List<String>.from(roomData['playerOrder'] ?? []);
      List<String> usedCategoryIds = List<String>.from(roomData['usedCategoryIds'] ?? []);
      final saboteurEnabled = roomData['saboteurEnabled'] as bool? ?? false;
      final diceRollEnabled = roomData['diceRollEnabled'] as bool? ?? false;

      if (playerOrder.isEmpty || isFirstRound) {
        final playersSnap = await playersColRef(roomId).get();
        playerOrder = playersSnap.docs.map((d) => d.id).toList();
        playerOrder.shuffle();
      }

      final currentRoundNumber = (roomData['currentRoundNumber'] as int) + 1;
      final navigatorRotationIndex = (roomData['navigatorRotationIndex'] as int);
      final navigatorUid = playerOrder[navigatorRotationIndex % playerOrder.length];

      String? saboteurUid = roomData['saboteurId'] as String?;
      if (saboteurEnabled && saboteurUid == null) {
        final potentialSaboteurs = playerOrder.where((uid) => uid != navigatorUid).toList();
        if (potentialSaboteurs.isNotEmpty) {
          saboteurUid = potentialSaboteurs[_rnd.nextInt(potentialSaboteurs.length)];
        }
      }

      final batch = _db.batch();
      final playersSnap = await playersColRef(roomId).get();
      for (var doc in playersSnap.docs) {
        final playerUid = doc.id;
        Role role;
        if (playerUid == navigatorUid) {
          role = Role.Navigator;
        } else if (saboteurEnabled && playerUid == saboteurUid) {
          role = Role.Saboteur;
        } else {
          role = Role.Seeker;
        }
        batch.update(playersColRef(roomId).doc(playerUid), {
          'role': role.toString().split('.').last,
          'isReady': false,
          'guessReady': false,
        });
      }

      final allCategoriesSnap = await _db.collection('rooms').doc(roomId).collection('categories').get();
      final availableCategories = allCategoriesSnap.docs
          .where((doc) => !usedCategoryIds.contains(doc.id))
          .toList();

      String selectedCategoryId;
      Map<String, dynamic> selectedCategoryData;

      if (availableCategories.isEmpty) {
        usedCategoryIds = [];
        final randomCategoryDoc = allCategoriesSnap.docs[_rnd.nextInt(allCategoriesSnap.docs.length)];
        selectedCategoryId = randomCategoryDoc.id;
        selectedCategoryData = randomCategoryDoc.data();
      } else {
        final randomCategoryDoc = availableCategories[_rnd.nextInt(availableCategories.length)];
        selectedCategoryId = randomCategoryDoc.id;
        selectedCategoryData = randomCategoryDoc.data();
      }
      usedCategoryIds.add(selectedCategoryId);

      final secretPosition = _rnd.nextInt(101);

      Effect? rolledEffect = Effect.none;
      if (diceRollEnabled) {
        final List<Effect> possibleEffects = Effect.values.where((e) => e != Effect.none).toList();
        rolledEffect = possibleEffects[_rnd.nextInt(possibleEffects.length)];
      }

      String initialRoomStatus = diceRollEnabled ? 'dice_roll' : 'clue_submission';
      // Add a print statement here to see what the next status should be
      print('DEBUG: Determined next room status will be: "$initialRoomStatus"');

      batch.set(roundDocRef(roomId), {
        'secretPosition': secretPosition,
        'categoryLeft': selectedCategoryData['left'],
        'categoryRight': selectedCategoryData['right'],
        'clue': null,
        'guesses': {},
        'roles': playersSnap.docs.asMap().map((index, doc) {
          final playerUid = doc.id;
          Role role;
          if (playerUid == navigatorUid) {
            role = Role.Navigator;
          } else if (saboteurEnabled && playerUid == saboteurUid) {
            role = Role.Saboteur;
          } else {
            role = Role.Seeker;
          }
          return MapEntry(playerUid, role.toString().split('.').last);
        }),
        'groupGuessPosition': 50,
        'score': null,
        'roundStartedTimestamp': FieldValue.serverTimestamp(),
        'effect': rolledEffect.toString().split('.').last,
        'effectRolledAt': rolledEffect != Effect.none ? FieldValue.serverTimestamp() : null,
        'roundNumber': currentRoundNumber,
      });

      batch.update(roomDocRef(roomId), {
        'status': initialRoomStatus,
        'currentRoundNumber': currentRoundNumber,
        'navigatorRotationIndex': (navigatorRotationIndex + 1) % playerOrder.length,
        'saboteurId': saboteurUid,
        'playerOrder': playerOrder,
        'usedCategoryIds': usedCategoryIds,
        'currentCategoryId': selectedCategoryId,
        'currentTrueSliderPosition': secretPosition,
        'roundStartedTimestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('DEBUG: Batch commit successful. Room status should now be updated in Firestore.');

    } catch (e) {
      print('--- DEBUG: AN ERROR OCCURRED IN _setupNewRoundState ---');
      print(e);
    }
    // ^^^ END OF MODIFICATION ^^^
  }



  // --- Round Start (Host Action) ---

  // Host starts a new round: assigns roles, secret position, category.
  // This method now calls _setupNewRoundState
  Future<void> startRound(String roomId) async {
    await _setupNewRoundState(roomId, isFirstRound: true);
  }

  /// Transitions the room status after dice roll.
  Future<void> transitionAfterDiceRoll(String roomId) async {
    await roomDocRef(roomId).update({'status': 'clue_submission'});
  }

  /// Listens to the overall room status to navigate players.
  Stream<String> listenRoomStatus(String roomId) {
    return roomDocRef(roomId).snapshots().map((snap) {
      final data = snap.data();
      return (data?['status'] as String?) ?? 'lobby';
    });
  }

  /// Fetches current player's role for the current round.
  Stream<Role> listenMyRole(String roomId) {
    return roundDocRef(roomId).snapshots().map((snap) {
      final data = snap.data();
      final rolesMap = (data?['roles'] as Map<String, dynamic>?)?.cast<String, String>() ?? {};
      final myRoleString = rolesMap[currentUserUid];
      return Role.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == myRoleString?.toLowerCase(),
        orElse: () => Role.Seeker, // Default to Seeker if not found
      );
    });
  }

  // --- Clue Submission Phase ---

  /// Submits the Navigator's clue and secret position.
  Future<void> submitClue(String roomId, int secret, String clue) async {
    await roundDocRef(roomId).set({
      'clue': clue,
    }, SetOptions(merge: true));

    // After clue is submitted, transition room status to 'guessing'
    await roomDocRef(roomId).update({'status': 'guessing'});
  }

  /// Listens to current round details (clue, secret, category).
  Stream<Round> listenCurrentRound(String roomId) {
    return roundDocRef(roomId).snapshots().map((snap) {
      return Round.fromMap(snap.data() ?? {});
    });
  }

  // --- Guessing Phase ---

  /// Updates the shared group guess slider position.
  Future<void> updateGroupGuess(String roomId, double pos) {
    return roundDocRef(roomId)
        .update({'groupGuessPosition': pos.round()}); // Store as int
  }

  /// Listens to the shared group guess slider position.
  Stream<int> listenGroupGuess(String roomId) =>
      roundDocRef(roomId).snapshots().map((snap) {
        final data = snap.data();
        return (data?['groupGuessPosition'] as num?)?.toInt() ?? 50;
      });

  /// Sets player's ready status during the guessing phase.
  Future<void> setGuessReady(String roomId, bool ready) => playersColRef(roomId)
      .doc(currentUserUid)
      .update({'guessReady': ready});

  /// Listens to all players' `guessReady` status for the guessing phase.
  Stream<List<PlayerStatus>> listenGuessReady(String roomId) =>
      playersColRef(roomId).snapshots().map((snap) {
        return snap.docs
            .map((d) => PlayerStatus.fromSnapshot(d))
            .toList();
      });

  /// Checks if all seekers (and saboteur) are ready with their guess.
  // This is now corrected to properly return a Stream<bool>
  Stream<bool> listenAllSeekersReady(String roomId) {
    return Rx.combineLatest2(
      playersColRef(roomId).snapshots().map((snap) => snap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList()),
      roundDocRef(roomId).snapshots().map((snap) => Round.fromMap(snap.data() ?? {})),
      (List<PlayerStatus> allPlayers, Round currentRound) {
        final rolesMap = currentRound.roles; // Roles are already parsed as Role enum
        if (rolesMap == null || rolesMap.isEmpty) return false;

        String? navigatorUid;
        rolesMap.forEach((uid, role) {
          if (role == Role.Navigator) { // Compare directly with Role enum
            navigatorUid = uid;
          }
        });

        // Filter players to check only seekers and saboteurs (non-navigator)
        final playersToCheck = allPlayers.where((p) => p.uid != navigatorUid).toList();

        // If there are no other players besides the navigator, consider all ready.
        if (playersToCheck.isEmpty) return true;

        return playersToCheck.every((p) => p.guessReady);
      },
    );
  }

  /// Calculates and saves the round score, then transitions to result screen.
  Future<void> finalizeRound(String roomId) async {
    final roomSnap = await roomDocRef(roomId).get();
    if (!roomSnap.exists) return;
    final roomData = roomSnap.data()!;
    final currentRoundNumberInRoom = roomData['currentRoundNumber'] as int;

    final roundSnap = await roundDocRef(roomId).get();
    if (!roundSnap.exists) return;
    final roundData = roundSnap.data()!;
    final Effect currentEffect = Effect.values.firstWhere(
      (e) => e.toString().split('.').last == (roundData['effect'] as String?),
      orElse: () => Effect.none,
    );

    final secret = (roundData['secretPosition'] as num?)?.toInt() ?? 0;
    final guess = (roundData['groupGuessPosition'] as num?)?.toInt() ?? 0;
    final distance = (secret - guess).abs();

    int score;
    if (distance <= 5) {
      score = 6;
    } else if (distance <= 10) {
      score = 3;
    } else if (distance <= 20) {
      score = 1;
    } else {
      score = 0;
    }

    int finalScore = score;
    String navigatorUid = '';
    final rolesMap = (roundData['roles'] as Map<String, dynamic>?)?.cast<String, String>() ?? {};
    rolesMap.forEach((uid, roleString) {
      if (Role.Navigator.toString().split('.').last == roleString) {
        navigatorUid = uid;
      }
    });

    if (currentEffect == Effect.doubleScore) {
      finalScore *= 2;
    } else if (currentEffect == Effect.halfScore) {
      finalScore = (finalScore / 2).round();
    } else if (currentEffect == Effect.token && navigatorUid.isNotEmpty) {
      await playersColRef(roomId).doc(navigatorUid).update({
        'tokens': FieldValue.increment(1),
      });
    }

    await roundDocRef(roomId).update({
      'score': finalScore,
      'roundEndedTimestamp': FieldValue.serverTimestamp(),
    });

    final batch = _db.batch();
    final playersSnap = await playersColRef(roomId).get();

    for (var doc in playersSnap.docs) {
      final playerUid = doc.id;
      final playerRoleString = rolesMap[playerUid];
      if (playerRoleString == Role.Navigator.toString().split('.').last ||
          playerRoleString == Role.Seeker.toString().split('.').last) {
        batch.update(playersColRef(roomId).doc(playerUid), {
          'totalScore': FieldValue.increment(finalScore),
        });
      }
      batch.update(playersColRef(roomId).doc(playerUid), {'guessReady': false});
    }
    await batch.commit();

    final roomHistoryCollection = roomDocRef(roomId).collection('history');
    await roomHistoryCollection.add({
      'roundNumber': currentRoundNumberInRoom,
      'secret': secret,
      'guess': guess,
      'score': finalScore,
      'timestamp': FieldValue.serverTimestamp(),
      'effect': currentEffect.toString().split('.').last,
    });

    await roomDocRef(roomId).update({'status': 'round_end'});
  }

  // --- Result Screen & Next Round / Match End ---

  /// Fetches players with their total scores for match summary.
  Future<List<PigeonUserDetails>> fetchPlayersWithScores(String roomId) async {
    final col = await playersColRef(roomId).get();
    return col.docs.map((doc) {
      final data = doc.data();
      return PigeonUserDetails(
        uid: doc.id,
        displayName: data['displayName'] as String? ?? 'Anonymous',
        totalScore: data['totalScore'] as int? ?? 0,
        tokens: data['tokens'] as int? ?? 0,
      );
    }).toList();
  }

  /// Fetches historical rounds for the scoreboard.
  Future<List<RoundHistoryEntry>> fetchHistory(String roomId) async {
    final snap = await roomDocRef(roomId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((d) => RoundHistoryEntry.fromMap(d.data())).toList();
  }

  /// Host increments round number and resets room state for a new round.
  Future<void> incrementRoundAndReset(String roomId) async {
    final roomSnap = await roomDocRef(roomId).get();
    if (!roomSnap.exists) return;
    final roomData = roomSnap.data()!;
    final currentRoundNumber = roomData['currentRoundNumber'] as int;

    if (currentRoundNumber >= 5) {
      await roomDocRef(roomId).update({'status': 'match_end'});
    } else {
      // Setup the next round state
      await _setupNewRoundState(roomId, isFirstRound: false);

      // Reset ready states for all players in batch for the next round
      final batch = _db.batch();
      final playersSnap = await playersColRef(roomId).get();
      for (var doc in playersSnap.docs) {
        batch.update(playersColRef(roomId).doc(doc.id), {
          'isReady': false,
          'guessReady': false,
        });
      }
      await batch.commit();
    }
  }

  // --- Player Presence (Basic) ---

  /// Updates a player's online status.
  Future<void> updateOnlineStatus(String roomId, bool online) async {
    if (_auth.currentUser == null) return;
    await playersColRef(roomId).doc(currentUserUid).update({
      'online': online,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Stream to notify other players (toast) when someone leaves.
  Stream<String?> listenForPlayerDepartures(String roomId) {
    // This stream combines the current players snapshot with the previously
    // emitted list from _playersSubject to detect actual departures.
    // The previous _playersSubject was removed to simplify this.
    // Re-implementing with a simpler approach based on just player list changes.
    // For proper departure detection across sessions, Cloud Functions are ideal.
    // This current implementation will detect players removed from Firestore.

    return playersColRef(roomId).snapshots().map((snapshot) {
      // Get current list of players
      final currentPlayers = snapshot.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList();
      final currentUids = currentPlayers.map((p) => p.uid).toSet();

      // This is a simplified detection. A more robust one would involve tracking
      // the list of players client-side and comparing.
      // For now, if a player's document is removed, this listener in firebase_service
      // won't fire for that player. The `listenForPlayerDepartures` in each screen
      // needs a cached list of players to compare against.
      // Given the current structure, this method might not reliably provide a name on *every* departure.
      // The `listenToLastPlayerStatus` might be a better signal for overall changes.
      return null; // Returning null for now, as specific departed name tracking is complex without cached state
    });
  }


  /// Stream to get the count of online players in a room and whether current user is the last one.
  /// Also emits the current user's display name if they are the last.
  Stream<Map<String, dynamic>> listenToLastPlayerStatus(String roomId) {
    // Combine stream of players and current user's auth state for comprehensive status
    return playersColRef(roomId).snapshots().map((snap) {
      final players = snap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList();
      final onlinePlayers = players.where((p) => p.online).toList();
      final currentUserId = _auth.currentUser?.uid;

      // Find current user's display name
      final currentUserDisplayName = players.firstWhere(
        (p) => p.uid == currentUserId,
        orElse: () => PlayerStatus(
            uid: currentUserId ?? 'unknown',
            displayName: 'You',
            ready: false,
            online: false,
            guessReady: false,
            role: 'Seeker',
            avatarId: 'bear' // Provide a default avatar
        ),
      ).displayName;


      final isLastPlayer = onlinePlayers.length == 1 && onlinePlayers.first.uid == currentUserId;

      return {
        'onlinePlayerCount': onlinePlayers.length,
        'isLastPlayer': isLastPlayer,
        'currentUserDisplayName': currentUserDisplayName,
      };
    });
  }

  // --- User-specific Settings (e.g., for Room Creation Defaults) ---

  // Document reference for user-specific settings
  DocumentReference<Map<String, dynamic>> _userSettingsDocRef() {
    // Uses the app ID provided by the Canvas environment and the current user's UID
    final appId = _canvasAppId ?? 'default-app-id'; // Use _canvasAppId
    return _db.collection('artifacts').doc(appId).collection('users').doc(currentUserUid).collection('settings').doc('roomCreation');
  }

  /// Fetches saved room creation settings from Firestore.
  Future<Map<String, bool>> fetchRoomCreationSettings() async {
    try {
      final docSnap = await _userSettingsDocRef().get();
      if (docSnap.exists) {
        final data = docSnap.data();
        return {
          'saboteurEnabled': data?['saboteurEnabled'] as bool? ?? false,
          'diceRollEnabled': data?['diceRollEnabled'] as bool? ?? false,
        };
      }
    } catch (e) {
      print('Error fetching room creation settings: $e');
    }
    // Return default values if document doesn't exist or error occurs
    return {
      'saboteurEnabled': false,
      'diceRollEnabled': false,
    };
  }

  /// Saves room creation settings to Firestore.
  Future<void> saveRoomCreationSettings(bool saboteurEnabled, bool diceRollEnabled) async {
    try {
      await _userSettingsDocRef().set(
        {
          'saboteurEnabled': saboteurEnabled,
          'diceRollEnabled': diceRollEnabled,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving room creation settings: $e');
    }
  }

  // NEW: User's current active room ID persistence
  DocumentReference<Map<String, dynamic>> _userCurrentRoomIdDocRef() {
    final appId = _canvasAppId ?? 'default-app-id'; // Use _canvasAppId
    return _db.collection('artifacts').doc(appId).collection('users').doc(currentUserUid).collection('settings').doc('currentRoom');
  }

  /// Saves the current room ID for the user. Set to null to clear.
  Future<void> saveCurrentRoomId(String? roomId) async {
    if (_auth.currentUser == null) return; // Ensure user is signed in
    try {
      if (roomId != null) {
        await _userCurrentRoomIdDocRef().set({
          'roomId': roomId,
          'lastJoined': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Use update with FieldValue.delete() for existing fields, or set empty map if doc might not exist
        await _userCurrentRoomIdDocRef().update({
          'roomId': FieldValue.delete(), // Delete the field
          'lastJoined': FieldValue.delete(),
        }).catchError((e) {
          // If the document/field doesn't exist to update, update() will throw.
          // Catch and ignore this specific error if it's about doc not found.
          if (e is FirebaseException && e.code == 'not-found') {
            print('Document for currentRoomId did not exist during delete attempt (safe to ignore): $e');
          } else {
            print('Error clearing current room ID: $e');
          }
        });
      }
    } catch (e) {
      print('Error saving current room ID: $e');
    }
  }

  /// Listens to the user's current room ID from their settings.
  Stream<String?> listenCurrentUserRoomId() {
    // Ensure currentUserUid is not empty before attempting to listen
    if (currentUserUid.isEmpty) {
      return Stream.value(null); // Emit null if no user is authenticated
    }
    return _userCurrentRoomIdDocRef().snapshots().map((snap) {
      return snap.data()?['roomId'] as String?;
    });
  }

  // --- Clean Up ---
}
