// lib/services/profile_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/avatar.dart';
import '../models/user_profile.dart';
import '../models/custom_username.dart';
import 'wallet_service.dart';

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

  // --- NEW: Avatar-specific Update Method ---
  Future<void> updateUserAvatar(String newAvatarId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _usersCollection.doc(user.uid).update({'avatarId': newAvatarId});
  }

  // --- NEW: Username Change Orchestration Method ---
  Future<void> changeUsername(String newUsername, {int gemCost = 100}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Step 1: Validate username format
    if (!CustomUsername.isValidUsername(newUsername)) {
      throw Exception(CustomUsername.getValidationError(newUsername));
    }

    // Step 2: Validate username availability
    final usernameQuery = await _db
        .collection('custom_usernames')
        .where('username', isEqualTo: newUsername.toLowerCase())
        .where('isActive', isEqualTo: true)
        .get();

    // Username is available if no docs found, or if the only doc is the current user's
    final isAvailable = usernameQuery.docs.isEmpty || 
        (usernameQuery.docs.length == 1 && usernameQuery.docs.first.data()['userId'] == user.uid);

    if (!isAvailable) {
      throw Exception('Username is already taken');
    }

    // Step 3: Charge the user gems for the change
    final success = await WalletService.spendGemsForUsernameChange(cost: gemCost);

    if (!success) {
      throw Exception('Not enough gems to change username');
    }

    // Step 4: If payment was successful, update the profile
    await _usersCollection.doc(user.uid).update({'displayName': newUsername});

    // Step 5: Update custom_usernames collection
    // Deactivate current username if exists
    final currentUsernameQuery = await _db
        .collection('custom_usernames')
        .where('userId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .get();

    for (final doc in currentUsernameQuery.docs) {
      await doc.reference.update({'isActive': false});
    }

    // Create new username
    final customUsername = CustomUsername(
      id: '', // Will be set by Firestore
      userId: user.uid,
      username: newUsername.toLowerCase(),
      createdAt: DateTime.now(),
      isActive: true,
      isVerified: true,
    );

    await _db.collection('custom_usernames').add(customUsername.toFirestore());

    // Step 6: Update Firebase Auth display name
    await user.updateDisplayName(newUsername);
  }
}
