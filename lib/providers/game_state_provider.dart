// lib/providers/game_state_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:minddrift/models/game_state.dart';
import 'package:minddrift/models/player_status.dart';
import 'package:minddrift/services/game_service.dart';
import 'package:minddrift/services/player_service.dart';
import 'package:minddrift/services/room_service.dart';
import 'package:minddrift/providers/auth_provider.dart';

class GameStateProvider extends ChangeNotifier {
  final String _roomId;
  final AuthProvider _authProvider;
  final RoomService _roomService;
  final PlayerService _playerService;
  final GameService _gameService;

  late GameState _state;
  final List<StreamSubscription> _subscriptions = [];

  GameState get state => _state;

  GameStateProvider({
    required String roomId,
    required AuthProvider authProvider,
    required RoomService roomService,
    required PlayerService playerService,
    required GameService gameService,
  })  : _roomId = roomId,
        _authProvider = authProvider,
        _roomService = roomService,
        _playerService = playerService,
        _gameService = gameService {
    _state = GameState.initial(_roomId);
    _initialize();
  }

  void _initialize() {
    // 1. Listen to Room Status
    final roomSub = _roomService.getRoomStream(_roomId).listen((roomDoc) {
      if (!roomDoc.exists) return;
      final roomData = roomDoc.data() ?? {};
      _state = _state.copyWith(
        roomStatus: roomData['status'] as String? ?? 'lobby',
        isHost: roomData['creator'] == _authProvider.uid,
        totalGroupScore: (roomData['totalGroupScore'] as num?)?.toInt() ?? _state.totalGroupScore,
      );
      notifyListeners();
    });

    // 2. Listen to Players
    final playerSub = _playerService.listenToPlayers(_roomId).listen((players) {
      final myStatus = players.firstWhere(
        (p) => p.uid == _authProvider.uid,
        orElse: () => PlayerStatus(
          uid: _authProvider.uid!,
          displayName: 'Player-${_authProvider.uid!.substring(0, 4)}',
          ready: false,
          online: true,
          avatarId: 'bear',
        ),
      );
      _state = _state.copyWith(players: players, myPlayerStatus: myStatus);
      notifyListeners();
    });

    // 3. Listen to Current Round
    final roundSub = _gameService.listenCurrentRound(_roomId).listen((round) {
      _state = _state.copyWith(currentRound: round);
      notifyListeners();
    });

    _subscriptions.addAll([roomSub, playerSub, roundSub]);
  }

  // --- UI ACTIONS ---
  // The UI will call these methods instead of the services directly.

  Future<void> setReady(bool isReady) async {
    await _playerService.setReady(_roomId, isReady);
  }

  Future<void> startRound() async {
    if (state.isHost && state.allPlayersReady) {
      await _gameService.startRound(_roomId);
    }
  }

  Future<void> transitionAfterRoleReveal(String roomId) async {
    await _gameService.transitionAfterRoleReveal(roomId);
  }

  Future<void> submitClue(int secret, String clue) async {
    await _gameService.submitClue(_roomId, secret, clue);
  }

  Future<void> incrementRoundAndReset() async {
    // This action is host-only, but we can add the check here for safety.
    if (state.isHost) {
      await _gameService.incrementRoundAndReset(_roomId);
    }
  }

  /// Action for the host to continue after the dice roll.
  Future<void> transitionAfterDiceRoll() async {
    if (state.isHost) {
      await _gameService.transitionAfterDiceRoll(_roomId);
    }
  }

  /// Action for a player to update the group's guess on the spectrum.
  Future<void> updateGroupGuess(double position) async {
    // This action can be performed by any player in the 'guessing' state.
    await _gameService.updateGroupGuess(_roomId, position);
  }

  /// Action for the host to finalize the round after everyone has guessed.
  Future<void> finalizeRound() async {
    if (state.isHost) {
      await _gameService.finalizeRound(_roomId);
    }
  }

  /// Action for a player to set their guess ready status.
  Future<void> setGuessReady(bool isReady) async {
    await _playerService.setGuessReady(_roomId, isReady);
  }
  
  // Add other game actions here as needed...

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
