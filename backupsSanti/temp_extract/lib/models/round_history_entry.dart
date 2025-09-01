// lib/models/round_history_entry.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RoundHistoryEntry {
  final int roundNumber;
  final int? secret;
  final int? guess;
  final int? score;
  final int? guessA, scoreA, guessB, scoreB;
  final DateTime timestamp;
  final String? effect; // <-- 1. ADD this final field

  RoundHistoryEntry({
    required this.roundNumber,
    this.secret,
    this.guess,
    this.score,
    this.guessA,
    this.scoreA,
    this.guessB,
    this.scoreB,
    required this.timestamp,
    this.effect, // <-- 2. ADD this to the constructor
  });

  factory RoundHistoryEntry.fromMap(Map<String, dynamic> m) {
    return RoundHistoryEntry(
      roundNumber: m['roundNumber'] as int,
      secret:      m['secret']      as int?,
      guess:       m['guess']       as int?,
      score:       m['score']       as int?,
      guessA:      m['guessA']      as int?,
      scoreA:      m['scoreA']      as int?,
      guessB:      m['guessB']      as int?,
      scoreB:      m['scoreB']      as int?, // Note: I also fixed a small bug here for you
      timestamp:   (m['timestamp'] as Timestamp).toDate(),
      effect:      m['effect']      as String?, // <-- 3. ADD this line to read from the database
    );
  }
}