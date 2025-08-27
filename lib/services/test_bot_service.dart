// lib/services/test_bot_service.dart

import 'dart:async';
import 'dart:math';

import 'package:wavelength_clone_fresh/models/round.dart';
import 'package:wavelength_clone_fresh/services/firebase_service.dart';

class TestBotService {
  static TestBotService? _instance;

  final String roomId;
  final FirebaseService _firebaseService;
  final String botUid = 'test-bot-001';
  final Random _random = Random();
  StreamSubscription? _roomSubscription;

  // --- NEW: Using timers to prevent loops ---
  Timer? _actionTimer;
  String _lastActedStatus = ''; // Prevents re-triggering timers for the same state

  TestBotService._internal(this.roomId, this._firebaseService) {
    print('🤖 TestBotService started for room: $roomId');
    _listenToRoomChanges();
  }

  static void start(String roomId, FirebaseService firebaseService) {
    _instance?.dispose();
    _instance = TestBotService._internal(roomId, firebaseService);
  }

  static void stop() {
    _instance?.dispose();
    _instance = null;
  }

  void _listenToRoomChanges() {
    // We only need to listen to the room document now to get the status.
    _roomSubscription = _firebaseService.roomDocRef(roomId).snapshots().listen((roomSnap) async {
      if (!roomSnap.exists) {
        dispose();
        return;
      }

      final roomStatus = roomSnap.data()?['status'] as String?;
      print('🤖 Bot observes room status: $roomStatus');

      // If we've already scheduled an action for this status, do nothing.
      if (roomStatus == _lastActedStatus) return;

      // Cancel any previously running timer.
      _actionTimer?.cancel();

      final roundSnap = await _firebaseService.roundDocRef(roomId).get();
      // If the round doesn't exist yet (e.g., in lobby), we might not need to act.
      final round = roundSnap.exists ? Round.fromMap(roundSnap.data()!) : null;
      final myRole = round?.roles?[botUid];

      // Schedule a new action based on the current state.
      _actionTimer = Timer(Duration(seconds: _random.nextInt(3) + 3), () async {
        switch (roomStatus) {
          case 'clue_submission':
            if (myRole == Role.Navigator && round?.clue == null) {
              final clue = _generateRandomClue();
               final secret = round?.secretPosition ?? 50;
              await _firebaseService.submitClue(roomId, secret, clue);
              print('🤖 Bot (Navigator) submitted clue: "$clue"');
            }
            break;

          case 'guessing':
            if (myRole == Role.Seeker || myRole == Role.Saboteur) {
              final playerDoc = await _firebaseService.playersColRef(roomId).doc(botUid).get();
              if (playerDoc.exists && playerDoc.data()?['guessReady'] == false) {
                 final randomGuess = _random.nextInt(101).toDouble();
                 await _firebaseService.updateGroupGuess(roomId, randomGuess);
                 await _firebaseService.setGuessReady(roomId, true, uid: botUid);
                 print('🤖 Bot (Seeker) made a guess at: $randomGuess');
              }
            }
            break;
            
          case 'lobby':
          case 'ready_phase':
            final playerDoc = await _firebaseService.playersColRef(roomId).doc(botUid).get();
            if (playerDoc.exists && playerDoc.data()?['isReady'] == false) {
               await _firebaseService.setReady(roomId, true, uid: botUid);
               print('🤖 Bot is ready in the lobby.');
            }
            break;

          case 'round_end':
             final playerDoc = await _firebaseService.playersColRef(roomId).doc(botUid).get();
             if (playerDoc.exists && playerDoc.data()?['isReady'] == false) {
               await _firebaseService.setReady(roomId, true, uid: botUid);
             }
             break;
        }
      });
      
      // Remember the status we just scheduled an action for.
      _lastActedStatus = roomStatus ?? '';
    });
  }

  String _generateRandomClue() {
    const words = ['Sky', 'Ocean', 'Fire', 'Earth', 'Love', 'Hate', 'Fast', 'Slow', 'Big', 'Small', 'Cat', 'Dog', 'Sun', 'Moon', 'War', 'Peace'];
    final shuffled = List.from(words)..shuffle();
    return shuffled.take(4).join(' ');
  }

  void dispose() {
    print('🤖 TestBotService disposed.');
    _actionTimer?.cancel();
    _roomSubscription?.cancel();
    _instance = null;
  }
}