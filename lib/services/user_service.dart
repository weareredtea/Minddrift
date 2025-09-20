// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minddrift/providers/auth_provider.dart';
import 'package:minddrift/models/match_settings.dart'; // Ensure this path is correct

class UserService {
  final FirebaseFirestore _db;
  final AuthProvider _authProvider;
  
  // This should match the value used in your environment variables or a constant file
  final String _canvasAppId = const String.fromEnvironment('app_id', defaultValue: 'default-app-id');

  UserService(this._authProvider, {FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  String get _uid => _authProvider.uid!;

  DocumentReference<Map<String, dynamic>> _userSettingsDocRef() {
    if (_uid.isEmpty) {
      throw Exception('User not authenticated - cannot access user settings');
    }
    return _db.collection('artifacts').doc(_canvasAppId).collection('users').doc(_uid).collection('settings').doc('roomCreation');
  }

  DocumentReference<Map<String, dynamic>> _userCurrentRoomDocRef() {
    if (_uid.isEmpty) {
      throw Exception('User not authenticated');
    }
    return _db.collection('artifacts').doc(_canvasAppId).collection('users').doc(_uid).collection('settings').doc('currentRoom');
  }

  //==================================================================
  // Public API for UserService
  //==================================================================

  /// Saves the user's preferred match settings.
  Future<void> saveMatchSettings(MatchSettings settings) async {
    await _userSettingsDocRef().set(settings.toMap(), SetOptions(merge: true));
  }

  /// Loads the user's preferred match settings.
  Future<MatchSettings> loadMatchSettings() async {
    final doc = await _userSettingsDocRef().get();
    if (doc.exists && doc.data() != null) {
      return MatchSettings.fromMap(doc.data()!);
    }
    return MatchSettings.defaultSettings;
  }

  /// Saves the ID of the room the user is currently in.
  Future<void> saveCurrentRoomId(String? roomId) async {
    if (_uid.isEmpty) {
      print('⚠️ Cannot save room ID - user not authenticated');
      return;
    }
    
    try {
      if (roomId != null) {
        await _userCurrentRoomDocRef().set({'roomId': roomId});
        print('✅ Successfully saved current room ID: $roomId');
      } else {
        await _userCurrentRoomDocRef().delete();
        print('✅ Successfully cleared current room ID');
      }
    } catch (e) {
      print('❌ Error saving current room ID: $e');
      // Don't rethrow to avoid breaking room creation
    }
  }

  /// Listens to the user's current room ID to enable automatic navigation.
  Stream<String?> listenCurrentUserRoomId() {
    if (_uid.isEmpty) return Stream.value(null);
    return _userCurrentRoomDocRef().snapshots().map((snap) {
      if (snap.exists && snap.data() != null) {
        return snap.data()!['roomId'] as String?;
      }
      return null;
    });
  }
}
