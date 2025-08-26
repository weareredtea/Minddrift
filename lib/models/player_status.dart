// lib/models/player_status.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerStatus {
  final String uid;
  final String displayName;
  final bool ready;
  final bool online;
  final bool guessReady;
  final String? role;
  final String avatarId; // *** NEW: Added avatarId field ***

  PlayerStatus({
    required this.uid,
    required this.displayName,
    required this.ready,
    required this.online,
    this.guessReady = false,
    this.role,
    required this.avatarId, // *** NEW: Include avatarId in the constructor ***
  });

  factory PlayerStatus.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final m = snap.data()!;
    return PlayerStatus(
      uid: snap.id,
      displayName: m['displayName'] as String? ?? 'Anonymous',
      ready: m['isReady'] as bool? ?? false,
      online: m['online'] as bool? ?? false,
      guessReady: m['guessReady'] as bool? ?? false,
      role: m['role'] as String?,
      avatarId: m['avatarId'] as String? ?? 'bear', // *** NEW: Parse avatarId, provide default ***
    );
  }
}
