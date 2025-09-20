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

  /// Check Firebase project connectivity
  Future<bool> testFirebaseConnectivity() async {
    try {
      print('🔍 Testing Firebase connectivity...');
      
      // Try a simple read operation on an existing collection that users can access
      await _db.collection('bundles').limit(1).get().timeout(const Duration(seconds: 10));
      
      print('✅ Firebase connectivity test successful');
      return true;
    } catch (e) {
      print('❌ Firebase connectivity test failed: $e');
      return false;
    }
  }

  /// Get user's UID from AuthProvider
  String get currentUserUid => _authProvider.uid ?? '';

  /// Fetch room creation settings
  Future<Map<String, bool>> fetchRoomCreationSettings() async {
    try {
      if (_uid.isEmpty) {
        print('Warning: Cannot fetch room settings - user not authenticated');
        return {
          'saboteurEnabled': false,
          'diceRollEnabled': false,
        };
      }

      final docSnap = await _userSettingsDocRef().get();
      if (docSnap.exists) {
        final data = docSnap.data();
        return {
          'saboteurEnabled': data?['saboteurEnabled'] as bool? ?? false,
          'diceRollEnabled': data?['diceRollEnabled'] as bool? ?? false,
        };
      }
    } catch (e) {
      print('Error fetching room creation settings: $e');
    }
    return {
      'saboteurEnabled': false,
      'diceRollEnabled': false,
    };
  }

  /// Save room creation settings
  Future<void> saveRoomCreationSettings(bool saboteurEnabled, bool diceRollEnabled, [int numRounds = 5, Set<String>? bundleSelections]) async {
    try {
      final data = {
        'saboteurEnabled': saboteurEnabled,
        'diceRollEnabled': diceRollEnabled,
        'numRounds': numRounds,
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      
      if (bundleSelections != null) {
        data['bundleSelections'] = bundleSelections.toList();
      }
      
      await _userSettingsDocRef().set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving room creation settings: $e');
    }
  }

  /// Save bundle selections
  Future<void> saveBundleSelections(Set<String> selectedBundles) async {
    try {
      await _userSettingsDocRef().set(
        {
          'bundleSelections': selectedBundles.toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving bundle selections: $e');
    }
  }
  
  /// Save music setting
  Future<void> saveMusicSetting(bool musicEnabled) async {
    try {
      await _userSettingsDocRef().set(
        {
          'musicEnabled': musicEnabled,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving music setting: $e');
    }
  }
  
  /// Load music setting
  Future<bool> loadMusicSetting() async {
    try {
      final docSnap = await _userSettingsDocRef().get();
      if (docSnap.exists) {
        final data = docSnap.data();
        return data?['musicEnabled'] as bool? ?? true; // Default to true
      }
    } catch (e) {
      print('Error loading music setting: $e');
    }
    
    return true; // Default to true if loading fails
  }

  /// Load bundle selections
  Future<Set<String>> loadBundleSelections() async {
    try {
      final docSnap = await _userSettingsDocRef().get();
      if (docSnap.exists) {
        final data = docSnap.data();
        final bundleSelections = data?['bundleSelections'] as List<dynamic>?;
        if (bundleSelections != null && bundleSelections.isNotEmpty) {
          return Set<String>.from(bundleSelections);
        }
      }
    } catch (e) {
      print('Error loading bundle selections: $e');
    }
    
    return {'bundle.free'};
  }
}
