// lib/services/room_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minddrift/providers/auth_provider.dart';
import 'package:minddrift/models/avatar.dart'; // Ensure this path is correct
import 'package:minddrift/services/user_service.dart';

// You may need to import your custom exception classes if they are in a separate file
// For now, they are included here for simplicity.
class RoomOperationException implements Exception {
  final String message;
  RoomOperationException(this.message);
  @override
  String toString() => 'RoomOperationException: $message';
}

class RoomService {
  final FirebaseFirestore _db;
  final AuthProvider _authProvider;
  final Random _rnd = Random();

  RoomService(this._authProvider, {FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  String get _uid {
    final uid = _authProvider.uid;
    if (uid == null) {
      throw RoomOperationException('User is not authenticated. Cannot perform room operations.');
    }
    return uid;
  }

  //==================================================================
  // Public API for RoomService
  //==================================================================

  /// Creates a new game room, including the initial player document for the host.
  Future<String> createRoom({
    required bool saboteurEnabled,
    required bool diceRollEnabled,
    required String selectedBundle,
    required UserService userService,
  }) async {
    if (_uid.isEmpty) {
      throw RoomOperationException('User is not authenticated. Cannot create a room.');
    }

    try {
      final roomId = await _generateUniqueRoomId();

      final roomRef = _db.collection('rooms').doc(roomId);
      final playerRef = roomRef.collection('players').doc(_uid);

      final batch = _db.batch();

      // 1. Create the main room document
      batch.set(roomRef, {
        'creator': _uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'lobby',
        'saboteurEnabled': saboteurEnabled,
        'diceRollEnabled': diceRollEnabled,
        'selectedBundle': selectedBundle,
        'currentRoundNumber': 0,
        'navigatorRotationIndex': 0,
        'playerOrder': [_uid], // Start with the creator in the player order
        'usedCategoryIds': [],
        'saboteurId': null,
        'totalGroupScore': 0,
      });

      // 2. Create the player document for the host
      batch.set(playerRef, {
        'displayName': 'Player-${_uid.substring(0, 4)}',
        'isReady': false,
        'guessReady': false,
        'online': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'tokens': 0,
        'avatarId': Avatars.getRandomAvatarId(),
      });

      await batch.commit();
      print('✅ Room document created successfully: $roomId');

      // Save the current room ID for navigation using UserService
      print('🔍 Saving current room ID for navigation...');
      await userService.saveCurrentRoomId(roomId);
      print('✅ Room creation completed successfully');

      return roomId;
    } on FirebaseException catch (e) {
      throw RoomOperationException('Failed to create room: ${e.message}');
    } catch (e) {
      throw RoomOperationException('An unknown error occurred while creating the room.');
    }
  }

  /// Checks if a room with the given ID exists in Firestore.
  Future<bool> roomExists(String roomId) async {
    try {
      final doc = await _db.collection('rooms').doc(roomId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if room exists: $e');
      return false;
    }
  }

  /// Returns a stream of the room document for real-time updates.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getRoomStream(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots();
  }

  /// Returns a stream of the room's current status string.
  Stream<String> listenRoomStatus(String roomId) {
    return getRoomStream(roomId).map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return 'lobby'; // Default or "not found" status
      }
      return snapshot.data()!['status'] as String? ?? 'lobby';
    });
  }


  //==================================================================
  // Private Helper Methods (moved from FirebaseService)
  //==================================================================

  String _randomCode(int n) => List.generate(
      n, (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[_rnd.nextInt(36)]).join();

  Future<String> _generateUniqueRoomId({int maxAttempts = 20}) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      attempts++;
      // Start with 4 chars, use 5 if collisions are frequent
      final roomId = _randomCode(attempts < 10 ? 4 : 5);
      final exists = await roomExists(roomId);
      if (!exists) {
        return roomId;
      }
    }
    throw RoomOperationException('Unable to generate a unique room ID. Please try again.');
  }

}
