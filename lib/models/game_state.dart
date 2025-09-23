// lib/models/game_state.dart
import 'package:flutter/foundation.dart';
import 'package:minddrift/models/player_status.dart';
import 'package:minddrift/models/round.dart';

@immutable
class GameState {
  final String roomId;
  final String roomStatus;
  final List<PlayerStatus> players;
  final Round currentRound;
  final bool isHost;
  final PlayerStatus? myPlayerStatus;
  final int totalGroupScore;

  const GameState({
    required this.roomId,
    required this.roomStatus,
    this.players = const [],
    required this.currentRound,
    this.isHost = false,
    this.myPlayerStatus,
    this.totalGroupScore = 0,
  });

  // Helper getters to simplify UI logic
  bool get allPlayersReady => players.isNotEmpty && players.every((p) => p.ready);

  // Creates an initial or loading state
  factory GameState.initial(String roomId) {
    return GameState(
      roomId: roomId,
      roomStatus: 'loading',
      currentRound: Round(),
      totalGroupScore: 0,
    );
  }

  GameState copyWith({
    String? roomStatus,
    List<PlayerStatus>? players,
    Round? currentRound,
    bool? isHost,
    PlayerStatus? myPlayerStatus,
    int? totalGroupScore,
  }) {
    return GameState(
      roomId: roomId,
      roomStatus: roomStatus ?? this.roomStatus,
      players: players ?? this.players,
      currentRound: currentRound ?? this.currentRound,
      isHost: isHost ?? this.isHost,
      myPlayerStatus: myPlayerStatus ?? this.myPlayerStatus,
      totalGroupScore: totalGroupScore ?? this.totalGroupScore,
    );
  }
}
