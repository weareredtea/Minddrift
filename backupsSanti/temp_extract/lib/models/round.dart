// lib/models/round.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for various round effects
enum Effect {
  doubleScore, halfScore, token, reverseSlider, noClue, blindGuess, // Added more effects to reach 6 total
  none // Default/no effect
}

// Enum for player roles within a round
enum Role { Navigator, Seeker, Saboteur }

class Round {
  final String? clue;
  final int? secretPosition; // The true position on the slider (0-100)
  final Map<String,int>? guesses; // Not used for group guess, but good for individual tracking if needed
  final Map<String,Role>? roles; // Map of UID to Role for the current round
  final Effect? effect; // Current round's special effect
  final String? categoryLeft; // Left side of the category (e.g., "HOT")
  final String? categoryRight; // Right side of the category (e.g., "COLD")
  final DateTime? effectRolledAt; // Timestamp for effect activation (to control display duration)
  final int? groupGuessPosition; // The final group's submitted position (0-100)
  final int? score; // Score for the current round
  final int? roundNumber; // Added roundNumber to Round for convenience

  Round({
    this.clue,
    this.secretPosition,
    this.guesses,
    this.roles,
    this.effect,
    this.categoryLeft,
    this.categoryRight,
    this.effectRolledAt,
    this.groupGuessPosition,
    this.score,
    this.roundNumber, // Initialize roundNumber
  });

  /// Public converter: parse Effect from its lowercase name.
  static Effect effectFromString(String? s) {
    if (s == null) return Effect.none;
    return Effect.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == s.toLowerCase(),
      orElse: () => Effect.none,
    );
  }

  /// Public converter: parse Role from its lowercase name.
  static Role roleFromString(String? s) {
    if (s == null) return Role.Seeker; // Default to Seeker if role is not explicitly set
    return Role.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == s.toLowerCase(),
      orElse: () => Role.Seeker, // Default to Seeker if not found
    );
  }

  factory Round.fromMap(Map<String, dynamic> m) {
    return Round(
      clue: m['clue'] as String?,
      secretPosition: (m['secretPosition'] as num?)?.toInt(),
      guesses: (m['guesses'] as Map?)?.cast<String,int>(),
      roles: (m['roles'] as Map?)?.cast<String,String>().map((k,v) {
        // Convert string role back to Role enum
        return MapEntry(k, roleFromString(v));
      }),
      effect: effectFromString(m['effect'] as String?),
      categoryLeft: m['categoryLeft'] as String?,
      categoryRight: m['categoryRight'] as String?,
      effectRolledAt: (m['effectRolledAt'] as Timestamp?)?.toDate(),
      groupGuessPosition: (m['groupGuessPosition'] as num?)?.toInt(),
      score: (m['score'] as num?)?.toInt(),
      roundNumber: (m['roundNumber'] as num?)?.toInt(), // Parse roundNumber
    );
  }
}
