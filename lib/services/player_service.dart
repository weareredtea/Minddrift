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

  /// Manually adds or removes a test bot from the room.
  Future<void> manageTestBot(String roomId, {required bool addBot}) async {
    const botUid = 'test-bot-001'; // The bot's fixed user ID
    final botPlayerRef = _playersColRef(roomId).doc(botUid);
    final roomRef = _roomDocRef(roomId);

    if (addBot) {
      // Add the bot to the room
      await _db.runTransaction((transaction) async {
        // 1. Create the bot player document
        transaction.set(botPlayerRef, {
          'displayName': 'Robo-Drifter',
          'isReady': false,
          'guessReady': false,
          'online': true, // The bot is always "online"
          'lastSeen': FieldValue.serverTimestamp(),
          'tokens': 0,
          'avatarId': 'bot_avatar', // A unique avatar ID for the bot
        }, SetOptions(merge: true));

        // 2. Add the bot to the room's playerOrder array
        transaction.update(roomRef, {
          'playerOrder': FieldValue.arrayUnion([botUid]),
        });
      });
    } else {
      // Remove the bot from the room
      await _db.runTransaction((transaction) async {
        // 1. Remove bot from playerOrder
        transaction.update(roomRef, {
          'playerOrder': FieldValue.arrayRemove([botUid]),
        });

        // 2. Delete the bot player document
        transaction.delete(botPlayerRef);
      });
    }
  }

  /// Checks if a specific player is ready in the room.
  Future<bool> isPlayerReady(String roomId, String playerUid) async {
    final playerDoc = await _playersColRef(roomId).doc(playerUid).get();
    if (!playerDoc.exists) return false;
    return playerDoc.data()?['isReady'] as bool? ?? false;
  }

  /// Checks if a specific player has submitted their guess.
  Future<bool> isPlayerGuessReady(String roomId, String playerUid) async {
    final playerDoc = await _playersColRef(roomId).doc(playerUid).get();
    if (!playerDoc.exists) return false;
    return playerDoc.data()?['guessReady'] as bool? ?? false;
  }

  /// Sets the ready status for a specific player (used by bot).
  Future<void> setPlayerReady(String roomId, bool ready, {String? uid}) async {
    final targetUid = uid ?? _uid;
    if (targetUid.isEmpty) return;
    await _playersColRef(roomId).doc(targetUid).update({'isReady': ready});
  }

  /// Sets the guess ready status for a specific player (used by bot).
  Future<void> setGuessReady(String roomId, bool guessReady, {String? uid}) async {
    final targetUid = uid ?? _uid;
    if (targetUid.isEmpty) return;
    await _playersColRef(roomId).doc(targetUid).update({'guessReady': guessReady});
  }
}
