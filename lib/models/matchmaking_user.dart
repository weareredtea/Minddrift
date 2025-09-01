// lib/models/matchmaking_user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchmakingStatus {
  online,    // User is online and looking for games
  inGame,    // User is currently in a game
  offline,   // User is offline
}

class MatchmakingUser {
  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final MatchmakingStatus status;
  final DateTime lastSeen;
  final List<String> preferredBundles;
  final int gamesPlayed;
  final double averageScore;
  final String? currentRoomId;

  const MatchmakingUser({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.status,
    required this.lastSeen,
    required this.preferredBundles,
    required this.gamesPlayed,
    required this.averageScore,
    this.currentRoomId,
  });

  // Create from Firestore document
  factory MatchmakingUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchmakingUser(
      id: doc.id,
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'],
      status: MatchmakingStatus.values.firstWhere(
        (e) => e.toString() == 'MatchmakingStatus.${data['status']}',
        orElse: () => MatchmakingStatus.offline,
      ),
      lastSeen: data['lastSeen']?.toDate() ?? DateTime.now(),
      preferredBundles: List<String>.from(data['preferredBundles'] ?? []),
      gamesPlayed: data['gamesPlayed'] ?? 0,
      averageScore: (data['averageScore'] ?? 0.0).toDouble(),
      currentRoomId: data['currentRoomId'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'status': status.toString().split('.').last,
      'lastSeen': lastSeen,
      'preferredBundles': preferredBundles,
      'gamesPlayed': gamesPlayed,
      'averageScore': averageScore,
      'currentRoomId': currentRoomId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  MatchmakingUser copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? avatarUrl,
    MatchmakingStatus? status,
    DateTime? lastSeen,
    List<String>? preferredBundles,
    int? gamesPlayed,
    double? averageScore,
    String? currentRoomId,
  }) {
    return MatchmakingUser(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      preferredBundles: preferredBundles ?? this.preferredBundles,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      averageScore: averageScore ?? this.averageScore,
      currentRoomId: currentRoomId ?? this.currentRoomId,
    );
  }

  // Check if user is available for matchmaking
  bool get isAvailable => status == MatchmakingStatus.online;

  // Get formatted last seen time
  String get formattedLastSeen {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case MatchmakingStatus.online:
        return '#4CAF50'; // Green
      case MatchmakingStatus.inGame:
        return '#FF9800'; // Orange
      case MatchmakingStatus.offline:
        return '#9E9E9E'; // Grey
    }
  }

  // Get status text
  String get statusText {
    switch (status) {
      case MatchmakingStatus.online:
        return 'Online';
      case MatchmakingStatus.inGame:
        return 'In Game';
      case MatchmakingStatus.offline:
        return 'Offline';
    }
  }
}
