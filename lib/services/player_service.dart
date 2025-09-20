// lib/services/player_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minddrift/models/player_status.dart';
import 'package:minddrift/models/round.dart';
import 'package:minddrift/models/avatar.dart';
import 'package:minddrift/providers/auth_provider.dart';
import 'package:minddrift/services/user_service.dart';

class PlayerService {
  final FirebaseFirestore _db;
  final AuthProvider _authProvider;

  PlayerService(this._authProvider, {FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  String get _uid => _authProvider.uid!;

  CollectionReference<Map<String, dynamic>> _playersColRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('players');

  DocumentReference<Map<String, dynamic>> _roomDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId);
      
  DocumentReference<Map<String, dynamic>> _roundDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('rounds').doc('current');

  //==================================================================
  // Public API for PlayerService
  //==================================================================

  /// Allows the current user to join an existing room.
  Future<void> joinRoom(String roomId, {required UserService userService}) async {
    if (_uid.isEmpty) {
      throw Exception("User is not authenticated. Cannot join a room.");
    }

    final roomRef = _roomDocRef(roomId);
    final playerRef = _playersColRef(roomId).doc(_uid);
    
    // In a future step, this could come from a new UserService
    final displayName = 'Player-${_uid.substring(0, 4)}';

    // Use a transaction to ensure atomicity
    await _db.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);
      if (!roomSnapshot.exists) {
        throw Exception("Room not found. Please check the code and try again.");
      }
      
      // 1. Create the player document
      transaction.set(playerRef, {
        'displayName': displayName,
        'isReady': false,
        'guessReady': false,
        'online': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'tokens': 0,
        'avatarId': Avatars.getRandomAvatarId(),
      }, SetOptions(merge: true));

      // 2. Add the player to the room's playerOrder array
      transaction.update(roomRef, {
        'playerOrder': FieldValue.arrayUnion([_uid]),
      });
    });

    // Save the current room ID for navigation
    await userService.saveCurrentRoomId(roomId);
  }

  /// Removes the current user's player document from a room.
  Future<void> leaveRoom(String roomId, {required UserService userService}) async {
    if (_uid.isEmpty) return; // Fail silently if no user

    final roomRef = _roomDocRef(roomId);
    final playerRef = _playersColRef(roomId).doc(_uid);
    
    // Use a transaction to safely leave the room
    await _db.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);
      if (!roomSnapshot.exists) {
        // If room doesn't exist, there's nothing to do.
        return;
      }

      // 1. Remove player from playerOrder
      transaction.update(roomRef, {
        'playerOrder': FieldValue.arrayRemove([_uid]),
      });

      // 2. Delete the player document
      transaction.delete(playerRef);
    });

    // Clear the current room ID
    await userService.saveCurrentRoomId(null);
  }

  /// Sets the ready status for the current player.
  Future<void> setReady(String roomId, bool ready) async {
    if (_uid.isEmpty) return;
    await _playersColRef(roomId).doc(_uid).update({'isReady': ready});
  }

  /// Listens to the status of all players in a room.
  Stream<List<PlayerStatus>> listenToPlayers(String roomId) {
    return _playersColRef(roomId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PlayerStatus.fromSnapshot(doc)).toList();
    });
  }

  /// Listens for the current player's assigned role in the current round.
  Stream<Role> listenMyRole(String roomId) {
    return _roundDocRef(roomId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return Role.Seeker; // Default role
      }
      final data = snap.data()!;
      final rolesMap = (data['roles'] as Map<String, dynamic>?)?.cast<String, String>() ?? {};
      final myRoleString = rolesMap[_uid];
      
      return Role.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == myRoleString?.toLowerCase(),
        orElse: () => Role.Seeker,
      );
    });
  }
}
