import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wavelength_clone_fresh/models/avatar.dart';
import 'package:wavelength_clone_fresh/services/test_bot_service.dart';

import '../models/player_status.dart';
import '../models/round.dart';
import '../models/round_history_entry.dart';
import '../pigeon/pigeon.dart';


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

  final String _canvasAppId = const String.fromEnvironment('app_id', defaultValue: 'default-app-id');
  final String _canvasInitialAuthToken = const String.fromEnvironment('initial_auth_token');

  FirebaseService() {
    _initializeFirebaseAndAuth();
  }

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

  String get currentUserUid => _auth.currentUser?.uid ?? '';

  String _randomCode(int n) =>
      List.generate(n, (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[_rnd.nextInt(36)])
          .join();

  Future<bool> roomExists(String roomId) async =>
      (await _db.collection('rooms').doc(roomId).get()).exists;

  Future<String> createRoom(bool saboteurEnabled, bool diceRollEnabled) async {
    if (currentUserUid.isEmpty) {
      throw Exception("User is not authenticated. Cannot create a room.");
    }

    String roomId;
    do {
      roomId = _randomCode(4);
    } while (await roomExists(roomId));

    final roomRef = _db.collection('rooms').doc(roomId);
    final String randomAvatarId = Avatars.getRandomAvatarId();

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
      'totalGroupScore': 0,
    });

    await roomRef.collection('players').doc(currentUserUid).set({
      'displayName': 'Player-${currentUserUid.substring(0, 4)}',
      'isReady': false,
      'guessReady': false,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'tokens': 0,
      'avatarId': randomAvatarId,
    });

    await _seedCategories(roomId);
    await saveCurrentRoomId(roomId);

    notifyListeners();
    return roomId;
  }

  Stream<PlayerStatus?> listenNavigator(String roomId) {
    return Rx.combineLatest2(
      listenCurrentRound(roomId),
      playersColRef(roomId).snapshots(),
      (Round round, QuerySnapshot<Map<String, dynamic>> playersSnap) {
        if (round.roles == null) return null;
        
        String? navigatorUid;
        round.roles!.forEach((uid, role) {
          if (role == Role.Navigator) {
            navigatorUid = uid;
          }
        });

        if (navigatorUid == null) return null;

        final playerDocs = playersSnap.docs;
        try {
          final navigatorDoc = playerDocs.firstWhere((doc) => doc.id == navigatorUid);
          return PlayerStatus.fromSnapshot(navigatorDoc);
        } catch (e) {
          return null;
        }
      },
    );
  }

  // Paste this entire method inside your FirebaseService class

  /// Fetches historical rounds for the scoreboard.
  Future<List<RoundHistoryEntry>> fetchHistory(String roomId) async {
    final snap = await _db
        .collection('rooms')
        .doc(roomId)
        .collection('rounds')
        .doc('current')
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((d) => RoundHistoryEntry.fromMap(d.data())).toList();
  }

  Stream<ReadyScreenViewModel> listenToReadyScreenViewModel(String roomId) {
    return Rx.combineLatest2(
      roomDocRef(roomId).snapshots(),
      playersColRef(roomId).snapshots(),
      (roomDoc, playersSnap) {
        final roomData = roomDoc.data() ?? {};
        final hostUid = roomData['creator'] as String? ?? '';
        final myUid = currentUserUid;
        final isHost = hostUid == myUid;

        final players = playersSnap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList();
        final allPlayersReady = players.isNotEmpty && players.every((p) => p.ready);
        
        PlayerStatus? me;
        if (players.any((p) => p.uid == myUid)) {
           me = players.firstWhere((p) => p.uid == myUid);
        }

        return ReadyScreenViewModel(
          isHost: isHost,
          allPlayersReady: allPlayersReady,
          players: players,
          me: me,
        );
      },
    );
  }

  Future<void> joinRoom(String roomId) async {
    if (currentUserUid.isEmpty) {
      throw Exception("User is not authenticated. Cannot join a room.");
    }

    final roomRef = _db.collection('rooms').doc(roomId);
    final playerRef = roomRef.collection('players').doc(currentUserUid);

    await playerRef.set({
      'displayName': 'Player-${currentUserUid.substring(0, 4)}',
      'isReady': false,
      'guessReady': false,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'tokens': 0,
      'avatarId': Avatars.getRandomAvatarId(),
    }, SetOptions(merge: true));

    await roomRef.update({
      'playerOrder': FieldValue.arrayUnion([currentUserUid]),
    });

    await saveCurrentRoomId(roomId);
    notifyListeners();
  }

  Future<void> leaveRoom(String roomId) async {
    TestBotService.stop();
    if (_auth.currentUser == null) return;
    final currentUserDisplayName = (await playersColRef(roomId).doc(currentUserUid).get()).data()?['displayName'] as String? ?? 'A player';

    await playersColRef(roomId).doc(currentUserUid).delete();

    await roomDocRef(roomId).update({
      'playerOrder': FieldValue.arrayRemove([currentUserUid]),
    });

    await saveCurrentRoomId(null);

    print('$currentUserDisplayName has left room $roomId');
  }

  Future<void> _seedCategories(String roomId) async {
    final cats = [
      {'id':'hot_cold','left':'HOT','right':'COLD'},
      {'id':'calm_noisy','left':'CALM','right':'NOISY'},
      // ... and all other categories
      {'id':'young_old','left':'YOUNG','right':'OLD'},
    ];
    final col = _db.collection('rooms').doc(roomId).collection('categories');
    for (var c in cats) {
      await col.doc(c['id']!).set(c);
    }
  }

  DocumentReference<Map<String,dynamic>> roomDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId);

  DocumentReference<Map<String,dynamic>> roundDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('rounds').doc('current');

  CollectionReference<Map<String,dynamic>> playersColRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('players');

  Future<List<PigeonUserDetails>> fetchPlayers(String roomId) async {
    final querySnapshot = await playersColRef(roomId).get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return PigeonUserDetails(
        uid: doc.id,
        displayName: data['displayName'] as String? ?? 'Anonymous',
        totalScore: 0,
        tokens: data['tokens'] as int? ?? 0,
      );
    }).toList();
  }

  Future<void> setReady(String roomId, bool ready, {String? uid}) => playersColRef(roomId)
    .doc(uid ?? currentUserUid)
    .update({'isReady': ready});

  Stream<List<PlayerStatus>> listenToReady(String roomId) =>
      playersColRef(roomId).snapshots().map((snap) {
        return snap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList();
      });

  Future<void> _setupNewRoundState(String roomId, {required bool isFirstRound}) async {
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

      String initialRoomStatus = 'role_reveal';
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
  }

  Future<void> transitionAfterRoleReveal(String roomId) async {
    final roomSnap = await roomDocRef(roomId).get();
    if (!roomSnap.exists) return;

    final diceRollEnabled = roomSnap.data()?['diceRollEnabled'] as bool? ?? false;
    print('DEBUG: Dice roll enabled? $diceRollEnabled');
    
    final nextStatus = diceRollEnabled ? 'dice_roll' : 'clue_submission';
    await roomDocRef(roomId).update({'status': nextStatus});
  }

  Future<void> startRound(String roomId) async {
    await _setupNewRoundState(roomId, isFirstRound: true);
  }

  Future<void> transitionAfterDiceRoll(String roomId) async {
    await roomDocRef(roomId).update({'status': 'clue_submission'});
  }

  Stream<String> listenRoomStatus(String roomId) {
    return roomDocRef(roomId).snapshots().map((snap) {
      final data = snap.data();
      return (data?['status'] as String?) ?? 'lobby';
    });
  }

  Stream<Role> listenMyRole(String roomId) {
    return roundDocRef(roomId).snapshots().map((snap) {
      final data = snap.data();
      final rolesMap = (data?['roles'] as Map<String, dynamic>?)?.cast<String, String>() ?? {};
      final myRoleString = rolesMap[currentUserUid];
      return Role.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == myRoleString?.toLowerCase(),
        orElse: () => Role.Seeker,
      );
    });
  }

  Future<void> submitClue(String roomId, int secret, String clue) async {
    await roundDocRef(roomId).set({
      'clue': clue,
    }, SetOptions(merge: true));

    await roomDocRef(roomId).update({'status': 'guessing'});
  }

  Stream<Round> listenCurrentRound(String roomId) {
    return roundDocRef(roomId).snapshots().map((snap) {
      return Round.fromMap(snap.data() ?? {});
    });
  }

  Future<void> updateGroupGuess(String roomId, double pos) {
    return roundDocRef(roomId)
        .update({'groupGuessPosition': pos.round()});
  }

  Stream<int> listenGroupGuess(String roomId) =>
      roundDocRef(roomId).snapshots().map((snap) {
        final data = snap.data();
        return (data?['groupGuessPosition'] as num?)?.toInt() ?? 50;
      });

  Future<void> setGuessReady(String roomId, bool ready, {String? uid}) => playersColRef(roomId)
    .doc(uid ?? currentUserUid)
    .update({'guessReady': ready});

  Future<void> addBotToRoom(String roomId) async {
    const botUid = 'test-bot-001';
    final playerRef = playersColRef(roomId).doc(botUid);

    await playerRef.set({
      'displayName': 'TestBot 🤖',
      'isReady': false,
      'guessReady': false,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'tokens': 0,
      'avatarId': Avatars.getRandomAvatarId(),
    }, SetOptions(merge: true));

    await roomDocRef(roomId).update({
      'playerOrder': FieldValue.arrayUnion([botUid]),
    });
    print('🤖 TestBot added to room $roomId');
}

  Stream<List<PlayerStatus>> listenGuessReady(String roomId) =>
      playersColRef(roomId).snapshots().map((snap) {
        return snap.docs
            .map((d) => PlayerStatus.fromSnapshot(d))
            .toList();
      });

  Stream<bool> listenAllSeekersReady(String roomId) {
    return Rx.combineLatest2(
      playersColRef(roomId).snapshots().map((snap) => snap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList()),
      roundDocRef(roomId).snapshots().map((snap) => Round.fromMap(snap.data() ?? {})),
      (List<PlayerStatus> allPlayers, Round currentRound) {
        final rolesMap = currentRound.roles;
        if (rolesMap == null || rolesMap.isEmpty) return false;

        String? navigatorUid;
        rolesMap.forEach((uid, role) {
          if (role == Role.Navigator) {
            navigatorUid = uid;
          }
        });

        final playersToCheck = allPlayers.where((p) => p.uid != navigatorUid).toList();

        if (playersToCheck.isEmpty) return true;

        return playersToCheck.every((p) => p.guessReady);
      },
    );
  }

  Future<void> finalizeRound(String roomId) async {
    await _db.runTransaction((transaction) async {
      final roomRef = roomDocRef(roomId);
      final roundRef = roundDocRef(roomId);

      final roomSnap = await transaction.get(roomRef);
      final roundSnap = await transaction.get(roundRef);

      if (!roomSnap.exists || !roundSnap.exists) {
        throw Exception("Room or Round does not exist!");
      }

      if (roomSnap.data()?['status'] != 'guessing') {
        print('Round already finalized. Skipping.');
        return;
      }
      
      final roomData = roomSnap.data()!;
      final currentRoundNumberInRoom = roomData['currentRoundNumber'] as int;

      final roundData = roundSnap.data()!;
      final Effect currentEffect = Effect.values.firstWhere(
        (e) => e.toString().split('.').last == (roundData['effect'] as String?),
        orElse: () => Effect.none,
      );

      final secret = (roundData['secretPosition'] as num?)?.toInt() ?? 0;
      final guess = (roundData['groupGuessPosition'] as num?)?.toInt() ?? 0;
      final distance = (secret - guess).abs();

      int score;
      if (distance <= 2) {
        score = 6;
      } else if (distance <= 5) {
        score = 4;
      } else if (distance <= 10) {
        score = 3;
      } else if (distance <= 15) {
        score = 2;
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

      transaction.update(roundRef, {
        'score': finalScore,
        'roundEndedTimestamp': FieldValue.serverTimestamp(),
      });

      transaction.update(roomRef, {
        'totalGroupScore': FieldValue.increment(finalScore),
        'status': 'round_end',
      });
    });

    final roundSnap = await roundDocRef(roomId).get();
    final roomSnap = await roomDocRef(roomId).get();
    final roundData = roundSnap.data()!;
    final secret = (roundData['secretPosition'] as num?)?.toInt() ?? 0;
    final guess = (roundData['groupGuessPosition'] as num?)?.toInt() ?? 0;
    final finalScore = roundData['score'];
    final currentRoundNumberInRoom = roomSnap.data()?['currentRoundNumber'];
    final effectString = roundData['effect'];

    final roomHistoryCollection = _db.collection('rooms').doc(roomId).collection('rounds').doc('current').collection('history');
    await roomHistoryCollection.add({
      'roundNumber': currentRoundNumberInRoom,
      'secret': secret,
      'guess': guess,
      'score': finalScore,
      'timestamp': FieldValue.serverTimestamp(),
      'effect': effectString,
    });
  }

  Future<void> incrementRoundAndReset(String roomId) async {
    final roomSnap = await roomDocRef(roomId).get();
    if (!roomSnap.exists) return;
    final roomData = roomSnap.data()!;
    final currentRoundNumber = roomData['currentRoundNumber'] as int;

    if (currentRoundNumber >= 5) {
      await roomDocRef(roomId).update({'status': 'match_end'});
    } else {
      await _setupNewRoundState(roomId, isFirstRound: false);

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

  Future<void> updateOnlineStatus(String roomId, bool online) async {
    if (_auth.currentUser == null) return;
    await playersColRef(roomId).doc(currentUserUid).update({
      'online': online,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Stream<String?> listenForPlayerDepartures(String roomId) {
    return playersColRef(roomId).snapshots().map((snapshot) {
      return null;
    });
  }

  Stream<Map<String, dynamic>> listenToLastPlayerStatus(String roomId) {
    return playersColRef(roomId).snapshots().map((snap) {
      final players = snap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList();
      final onlinePlayers = players.where((p) => p.online).toList();
      final currentUserId = _auth.currentUser?.uid;

      final currentUserDisplayName = players.firstWhere(
        (p) => p.uid == currentUserId,
        orElse: () => PlayerStatus(
            uid: currentUserId ?? 'unknown',
            displayName: 'You',
            ready: false,
            online: false,
            guessReady: false,
            role: 'Seeker',
            avatarId: 'bear'
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

  DocumentReference<Map<String, dynamic>> _userSettingsDocRef() {
    final appId = _canvasAppId ?? 'default-app-id';
    return _db.collection('artifacts').doc(appId).collection('users').doc(currentUserUid).collection('settings').doc('roomCreation');
  }

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
    return {
      'saboteurEnabled': false,
      'diceRollEnabled': false,
    };
  }

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

  DocumentReference<Map<String, dynamic>> _userCurrentRoomIdDocRef() {
    final appId = _canvasAppId ?? 'default-app-id';
    return _db.collection('artifacts').doc(appId).collection('users').doc(currentUserUid).collection('settings').doc('currentRoom');
  }

  Future<void> saveCurrentRoomId(String? roomId) async {
    if (_auth.currentUser == null) return;
    try {
      if (roomId != null) {
        await _userCurrentRoomIdDocRef().set({
          'roomId': roomId,
          'lastJoined': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await _userCurrentRoomIdDocRef().update({
          'roomId': FieldValue.delete(),
          'lastJoined': FieldValue.delete(),
        }).catchError((e) {
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

  Stream<String?> listenCurrentUserRoomId() {
    if (currentUserUid.isEmpty) {
      return Stream.value(null);
    }
    return _userCurrentRoomIdDocRef().snapshots().map((snap) {
      return snap.data()?['roomId'] as String?;
    });
  }
}