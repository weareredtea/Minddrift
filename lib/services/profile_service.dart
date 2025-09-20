// lib/services/profile_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/avatar.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection => _db.collection('users');

  /// Provides a real-time stream of a user's profile.
  Stream<UserProfile> getProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      // Return a default profile if the document doesn't exist yet
      return UserProfile(uid: uid, displayName: 'MindDrifter', avatarId: 'bear');
    });
  }

  /// Creates the initial user profile document when a new user signs up.
  Future<void> createInitialProfile(User user) async {
    final docRef = _usersCollection.doc(user.uid);
    final doc = await docRef.get();

    // Only create a profile if one doesn't already exist
    if (!doc.exists) {
      final initialProfile = UserProfile(
        uid: user.uid,
        displayName: 'MindDrifter', // Default username
        avatarId: Avatars.getRandomAvatarId(), // Random free avatar
      );
      await docRef.set(initialProfile.toFirestore());
    }
  }

  /// Updates the user's profile data.
  Future<void> updateProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.uid).set(profile.toFirestore(), SetOptions(merge: true));
  }

  /// Gets a user's profile once (non-streaming).
  Future<UserProfile?> getProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
