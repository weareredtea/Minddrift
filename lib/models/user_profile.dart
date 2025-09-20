// lib/models/user_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String uid;
  final String displayName;
  final String avatarId;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.avatarId,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'MindDrifter',
      avatarId: data['avatarId'] as String? ?? 'bear', // Default avatar
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'avatarId': avatarId,
      'uid': uid,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? avatarId,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      avatarId: avatarId ?? this.avatarId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.uid == uid &&
        other.displayName == displayName &&
        other.avatarId == avatarId;
  }

  @override
  int get hashCode => uid.hashCode ^ displayName.hashCode ^ avatarId.hashCode;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, displayName: $displayName, avatarId: $avatarId)';
  }
}
