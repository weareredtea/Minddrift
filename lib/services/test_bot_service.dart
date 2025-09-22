// lib/services/test_bot_service.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:minddrift/models/round.dart';
import 'package:minddrift/services/game_service.dart';
import 'package:minddrift/services/player_service.dart';
import 'package:minddrift/services/room_service.dart';

class TestBotService {
  static TestBotService? _instance;

  final String roomId;
  final RoomService _roomService;
  final PlayerService _playerService;
  final GameService _gameService;

  final String botUid = 'test-bot-001';
  final Random _random = Random();
  StreamSubscription? _roomSubscription;

  Timer? _actionTimer;
  String _lastActedStatus = '';

  TestBotService._internal({
    required this.roomId,
    required RoomService roomService,
    required PlayerService playerService,
    required GameService gameService,
  })  : _roomService = roomService,
        _playerService = playerService,
        _gameService = gameService {
    if (kDebugMode) {
      print('🤖 TestBotService started for room: $roomId');
    }
    _listenToRoomChanges();
  }

  /// Starts the bot service for a specific room.
  static void start({
    required String roomId,
    required RoomService roomService,
    required PlayerService playerService,
    required GameService gameService,
  }) {
    _instance?.dispose();
    _instance = TestBotService._internal(
      roomId: roomId,
      roomService: roomService,
      playerService: playerService,
      gameService: gameService,
    );
  }

  /// Stops the bot service.
  static void stop() {
    _instance?.dispose();
    _instance = null;
  }

  void _listenToRoomChanges() {
    // REFACTORED: Listen to the room stream from the specialized RoomService.
    _roomSubscription = _roomService.getRoomStream(roomId).listen((roomSnap) async {
      if (!roomSnap.exists) {
        dispose();
        return;
      }

      final roomData = roomSnap.data();
      final roomStatus = roomData?['status'] as String?;
      if (kDebugMode) {
        print('🤖 Bot observes room status: $roomStatus');
      }

      if (roomStatus == _lastActedStatus) return;
      _actionTimer?.cancel();

      // REFACTORED: Get round data from the GameService.
      final round = await _gameService.getCurrentRound(roomId);
      final myRole = round?.roles?[botUid];

      // Schedule a new action after a random delay to simulate a player.
      _actionTimer = Timer(Duration(seconds: _random.nextInt(3) + 2), () async {
        if (kDebugMode) {
          print('🤖 Bot executing action for status: $roomStatus');
        }

        switch (roomStatus) {
          case 'clue_submission':
            if (kDebugMode) {
              print('🤖 Bot checking clue submission conditions:');
              print('🤖 Bot role: $myRole');
              print('🤖 Is Navigator? ${myRole == Role.Navigator}');
              print('🤖 Round clue: "${round?.clue}"');
              print('🤖 Clue is null? ${round?.clue == null}');
              print('🤖 Clue is empty? ${round?.clue?.isEmpty == true}');
              print('🤖 Can submit clue? ${myRole == Role.Navigator && (round?.clue == null || round?.clue?.isEmpty == true)}');
            }
            
            if (myRole == Role.Navigator && (round?.clue == null || round?.clue?.isEmpty == true)) {
              final clue = _generateRandomClue();
              final secret = round?.secretPosition ?? 50;
              if (kDebugMode) {
                print('🤖 Bot (Navigator) attempting to submit clue: "$clue" with secret: $secret');
              }
              try {
                // REFACTORED: Use GameService to submit the clue.
                await _gameService.submitClue(roomId, secret, clue);
                if (kDebugMode) {
                  print('🤖 Bot (Navigator) successfully submitted clue: "$clue"');
                }
              } catch (e) {
                if (kDebugMode) {
                  print('🤖 Bot failed to submit clue: $e');
                }
              }
            } else {
              if (kDebugMode) {
                print('🤖 Bot cannot submit clue - Role: $myRole, Clue exists: ${round?.clue != null}');
              }
            }
            break;

          case 'guessing':
            if (myRole == Role.Seeker || myRole == Role.Saboteur) {
              // REFACTORED: Use PlayerService to check player status.
              final playerIsGuessReady = await _playerService.isPlayerGuessReady(roomId, botUid);
              if (!playerIsGuessReady) {
                final randomGuess = _random.nextInt(101).toDouble();
                // REFACTORED: Use GameService and PlayerService for guessing actions.
                await _gameService.updateGroupGuess(roomId, randomGuess);
                await _playerService.setGuessReady(roomId, true, uid: botUid);
                if (kDebugMode) {
                  print('🤖 Bot (Seeker/Saboteur) made a guess at: $randomGuess');
                }
              }
            }
            break;

          case 'lobby':
          case 'round_end':
            // REFACTORED: Use PlayerService to check player status.
            final playerIsReady = await _playerService.isPlayerReady(roomId, botUid);
            if (!playerIsReady) {
              // REFACTORED: Use PlayerService to set the ready state.
              await _playerService.setPlayerReady(roomId, true, uid: botUid);
              if (kDebugMode) {
                print('🤖 Bot is now ready.');
              }
            }
            break;
        }
      });

      _lastActedStatus = roomStatus ?? '';
    });
  }

  String _generateRandomClue() {
    const words = ['Sky', 'Ocean', 'Fire', 'Love', 'Hate', 'Fast', 'Slow', 'Big', 'Small', 'Sun', 'Moon', 'War', 'Peace'];
    return (List.from(words)..shuffle()).take(3).join(' ');
  }

  void dispose() {
    if (kDebugMode) {
      print('🤖 TestBotService disposed for room: $roomId');
    }
    _actionTimer?.cancel();
    _roomSubscription?.cancel();
    _instance = null;
  }
}