// lib/services/game_service.dart
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minddrift/models/round.dart';
import 'package:minddrift/providers/auth_provider.dart';
import 'package:minddrift/services/category_service.dart';

class GameService {
  final FirebaseFirestore _db;
  final AuthProvider _authProvider;
  final Random _rnd = Random();

  // Debouncing for group guess updates
  static final Map<String, Timer> _updateTimers = {};
  static final Map<String, double> _pendingUpdates = {};

  // Performance optimization: Cache for expensive operations
  static final Map<String, Round> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  GameService(this._authProvider, {FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  String get _uid => _authProvider.uid!;

  DocumentReference<Map<String, dynamic>> _roomDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId);
      
  DocumentReference<Map<String, dynamic>> _roundDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('rounds').doc('current');

  CollectionReference<Map<String, dynamic>> _playersColRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('players');

  //==================================================================
  // Public API for GameService
  //==================================================================

  /// Kicks off the first round of the game. Host-only action.
  Future<void> startRound(String roomId) async {
    final roomDoc = await _roomDocRef(roomId).get();
    if (!roomDoc.exists || roomDoc.data()?['creator'] != _uid) {
      throw Exception("Only the host can start the round.");
    }
    await _setupNewRoundState(roomId, isFirstRound: true);
  }

  /// Transitions the room state after the role reveal phase.
  Future<void> transitionAfterRoleReveal(String roomId) async {
    final roomSnap = await _roomDocRef(roomId).get();
    if (!roomSnap.exists) return;

    final diceRollEnabled = roomSnap.data()?['diceRollEnabled'] as bool? ?? false;
    print('DEBUG: Dice roll enabled? $diceRollEnabled');
    
    final nextStatus = diceRollEnabled ? 'dice_roll' : 'clue_submission';
    await _roomDocRef(roomId).update({'status': nextStatus});
  }

  /// Transitions the room state after the dice roll phase.
  Future<void> transitionAfterDiceRoll(String roomId) async {
    await _roomDocRef(roomId).update({'status': 'clue_submission'});
  }

  /// Submits the clue from the Navigator.
  Future<void> submitClue(String roomId, int secret, String clue) async {
    await _roundDocRef(roomId).set({
      'clue': clue,
    }, SetOptions(merge: true));

    await _roomDocRef(roomId).update({'status': 'guessing'});
  }

  /// Updates the group's guess position on the spectrum.
  Future<void> updateGroupGuess(String roomId, double pos) async {
    // Performance optimization: Debounce rapid updates to reduce Firebase writes
    _updateTimers[roomId]?.cancel();
    _pendingUpdates[roomId] = pos;
    
    _updateTimers[roomId] = Timer(const Duration(milliseconds: 50), () { // Reduced from 100ms to 50ms for better responsiveness
      final finalPos = _pendingUpdates[roomId];
      if (finalPos != null) {
        _roundDocRef(roomId).update({'groupGuessPosition': finalPos.round()});
        _pendingUpdates.remove(roomId);
      }
    });
  }

  /// Listens to the data for the current round.
  Stream<Round> listenCurrentRound(String roomId) {
    return _roundDocRef(roomId).snapshots().map((snap) {
      final round = Round.fromMap(snap.data() ?? {});
      _cache[roomId] = round; // Cache the result
      _cacheTimestamps[roomId] = DateTime.now();
      return round;
    });
  }

  /// Gets the current round data synchronously.
  Future<Round?> getCurrentRound(String roomId) async {
    try {
      final snap = await _roundDocRef(roomId).get();
      if (!snap.exists) return null;
      return Round.fromMap(snap.data() ?? {});
    } catch (e) {
      print('Error getting current round: $e');
      return null;
    }
  }

  /// Calculates the score, finalizes the round, and moves the state to 'round_end'.
  Future<void> finalizeRound(String roomId) async {
    await _db.runTransaction((transaction) async {
      final roomRef = _roomDocRef(roomId);
      final roundRef = _roundDocRef(roomId);

      final roomSnap = await transaction.get(roomRef);
      final roundSnap = await transaction.get(roundRef);

      if (!roomSnap.exists || !roundSnap.exists) {
        throw Exception("Room or Round does not exist!");
      }

      if (roomSnap.data()?['status'] != 'guessing') {
        print('Round already finalized. Skipping.');
        return;
      }
      
      final roundData = roundSnap.data()!;
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

      // Update round document with final score
      transaction.update(roundRef, {
        'score': score, // Fixed: Use 'score' field name to match Round model
        'finalDistance': distance,
        'finalizedAt': FieldValue.serverTimestamp(),
      });

      // Update room status to round_end
      transaction.update(roomRef, {
        'status': 'round_end',
        'totalGroupScore': FieldValue.increment(score),
      });
    });
  }

  /// Resets player readiness and sets up the next round, or ends the match.
  Future<void> incrementRoundAndReset(String roomId) async {
    final roomSnap = await _roomDocRef(roomId).get();
    if (!roomSnap.exists) return;
    final roomData = roomSnap.data()!;
    final currentRoundNumber = roomData['currentRoundNumber'] as int;

    if (currentRoundNumber >= 5) {
      await _roomDocRef(roomId).update({'status': 'match_end'});
    } else {
      await _setupNewRoundState(roomId, isFirstRound: false);

      final batch = _db.batch();
      final playersSnap = await _playersColRef(roomId).get();
      for (var doc in playersSnap.docs) {
        batch.update(_playersColRef(roomId).doc(doc.id), {
          'isReady': false,
          'guessReady': false,
        });
      }
      await batch.commit();
    }
  }

  //==================================================================
  // Private Helper: Setup New Round (Core Logic)
  //==================================================================
  
  Future<void> _setupNewRoundState(String roomId, {required bool isFirstRound}) async {
    print('DEBUG: _setupNewRoundState function started.');
    try {
      final roomSnap = await _roomDocRef(roomId).get();
      if (!roomSnap.exists) return;
      final roomData = roomSnap.data()!;

      List<String> playerOrder = List<String>.from(roomData['playerOrder'] ?? []);
      final saboteurEnabled = roomData['saboteurEnabled'] as bool? ?? false;

      if (playerOrder.isEmpty || isFirstRound) {
        final playersSnap = await _playersColRef(roomId).get();
        playerOrder = playersSnap.docs.map((d) => d.id).toList();
        playerOrder.shuffle();
        print('🔍 Setup round - Player order from collection: $playerOrder');
      } else {
        print('🔍 Setup round - Player order from room data: $playerOrder');
      }

      final currentRoundNumber = (roomData['currentRoundNumber'] as int) + 1;
      final navigatorRotationIndex = (roomData['navigatorRotationIndex'] as int);
      final navigatorUid = playerOrder[navigatorRotationIndex % playerOrder.length];
      
      print('🔍 Setup round - Navigator calculation:');
      print('🔍 Current round number: $currentRoundNumber');
      print('🔍 Navigator rotation index: $navigatorRotationIndex');
      print('🔍 Player order length: ${playerOrder.length}');
      print('🔍 Calculated navigator UID: $navigatorUid');

      String? saboteurUid = roomData['saboteurId'] as String?;
      if (saboteurEnabled && saboteurUid == null) {
        final potentialSaboteurs = playerOrder.where((uid) => uid != navigatorUid).toList();
        if (potentialSaboteurs.isNotEmpty) {
          saboteurUid = potentialSaboteurs[_rnd.nextInt(potentialSaboteurs.length)];
        }
      }

      final batch = _db.batch();
      final playersSnap = await _playersColRef(roomId).get();
      
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
        
        batch.update(_playersColRef(roomId).doc(playerUid), {
          'role': role.toString().split('.').last.toLowerCase(),
        });
      }

      // Select a random category for this round
      final selectedBundle = roomData['selectedBundle'] as String? ?? 'bundle.free';
      final usedCategoryIds = List<String>.from(roomData['usedCategoryIds'] ?? []);
      final ownedBundles = {selectedBundle}; // For now, just use the selected bundle
      
      final selectedCategory = CategoryService.getRandomCategory(ownedBundles, usedCategoryIds);
      if (selectedCategory == null) {
        throw Exception('No categories available for bundle: $selectedBundle');
      }

      // Update room document
      batch.update(_roomDocRef(roomId), {
        'currentRoundNumber': currentRoundNumber,
        'navigatorRotationIndex': navigatorRotationIndex + 1,
        'playerOrder': playerOrder,
        'saboteurId': saboteurUid,
        'status': 'role_reveal',
        'usedCategoryIds': usedCategoryIds..add(selectedCategory.id), // Add the selected category to used list
      });
      
      // Generate a random secret position (0-100)
      final secretPosition = _rnd.nextInt(101);

      // Create round document
      batch.set(_roundDocRef(roomId), {
        'roles': playerOrder.fold<Map<String, String>>({}, (map, uid) {
          final role = uid == navigatorUid 
              ? Role.Navigator 
              : (saboteurEnabled && uid == saboteurUid) 
                  ? Role.Saboteur 
                  : Role.Seeker;
          map[uid] = role.toString().split('.').last.toLowerCase();
          return map;
        }),
        'navigatorUid': navigatorUid,
        'saboteurUid': saboteurUid,
        'clue': '',
        'groupGuessPosition': 50,
        'secretPosition': secretPosition,
        'roundNumber': currentRoundNumber,
        'categoryId': selectedCategory.id,
        'categoryLeft': selectedCategory.getLeftText('en'),
        'categoryRight': selectedCategory.getRightText('en'),
      });

      await batch.commit();
      print('✅ Round setup completed successfully');

    } catch (e) {
      print('--- DEBUG: AN ERROR OCCURRED IN _setupNewRoundState ---');
      print(e);
    }
  }
}
