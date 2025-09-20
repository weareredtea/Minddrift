import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/player_status.dart';
import '../models/round.dart';
import '../models/round_history_entry.dart';
import '../services/test_bot_service.dart';
import '../models/avatar.dart';
import '../pigeon/pigeon.dart';
import '../services/category_service.dart';
import '../models/match_settings.dart';
import '../providers/auth_provider.dart' as auth;

// Custom exception classes for better error handling
class FirebaseServiceException implements Exception {
  final String message;
  final String? code;
  final String? details;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  FirebaseServiceException(
    this.message, {
    this.code,
    this.details,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'FirebaseServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}

class AuthenticationException extends FirebaseServiceException {
  AuthenticationException(super.message, {super.code, super.details, super.stackTrace});
}

class NetworkException extends FirebaseServiceException {
  NetworkException(super.message, {super.code, super.details, super.stackTrace});
}

class PermissionException extends FirebaseServiceException {
  PermissionException(super.message, {super.code, super.details, super.stackTrace});
}

class RoomOperationException extends FirebaseServiceException {
  RoomOperationException(super.message, {super.code, super.details, super.stackTrace});
}

// Exception handler utility
class ExceptionHandler {
  static const String _logPrefix = '[EXCEPTION_HANDLER]';
  
  // Performance-optimized logging with conditional compilation
  static void logError(String operation, dynamic error, {String? context, Map<String, dynamic>? extraData}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final errorInfo = {
        'timestamp': timestamp,
        'operation': operation,
        'error': error.toString(),
        'errorType': error.runtimeType.toString(),
        if (context != null) 'context': context,
        if (extraData != null) ...extraData,
      };
      
      print('$_logPrefix ERROR: ${errorInfo.toString()}');
      
      if (error is FirebaseServiceException && error.stackTrace != null) {
        print('$_logPrefix STACK_TRACE: ${error.stackTrace}');
      }
    }
  }

  // Convert Firebase exceptions to user-friendly messages
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FirebaseServiceException) {
      // Check for emulator-specific issues
      if (error.code == 'EMULATOR_FIREBASE_ISSUE') {
        return 'Emulator detected with connectivity issues. Please test on a real device for best results.';
      }
      return error.message;
    }
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to perform this action. Please check your account status.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please check your internet connection and try again.';
        case 'unauthenticated':
          return 'You need to sign in again. Please restart the app.';
        case 'not-found':
          return 'The requested resource was not found.';
        case 'already-exists':
          return 'This resource already exists.';
        case 'resource-exhausted':
          return 'Service is currently busy. Please try again later.';
        case 'failed-precondition':
          return 'Operation cannot be completed in the current state.';
        case 'aborted':
          return 'Operation was cancelled. Please try again.';
        case 'out-of-range':
          return 'The operation is outside the valid range.';
        case 'unimplemented':
          return 'This feature is not yet implemented.';
        case 'internal':
          return 'An internal error occurred. Please try again.';
        case 'data-loss':
          return 'Data was lost during the operation.';
        default:
          return 'An unexpected error occurred: ${error.message}';
      }
    }
    
    // Check for emulator-specific error patterns
    if (error.toString().contains('emulator') || 
        error.toString().contains('sdk') ||
        error.toString().contains('google_sdk')) {
      return 'Emulator detected with connectivity issues. Please test on a real device for best results.';
    }
    
    if (error.toString().contains('network') || error.toString().contains('connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }
    
    if (error.toString().contains('timeout')) {
      return 'Operation timed out. Please try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Get developer-friendly error details
  static String getDeveloperMessage(dynamic error) {
    if (error is FirebaseServiceException) {
      return '${error.runtimeType}: ${error.message}${error.code != null ? ' (Code: ${error.code})' : ''}${error.details != null ? ' - Details: ${error.details}' : ''}';
    }
    
    if (error is FirebaseException) {
      return 'FirebaseException: ${error.code} - ${error.message}';
    }
    
    return '${error.runtimeType}: ${error.toString()}';
  }
}

// Performance optimization: Cache for expensive operations
class _RoundCache {
  static final Map<String, Round> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};


  static void set(String roomId, Round round) {
    _cache[roomId] = round;
    _cacheTimestamps[roomId] = DateTime.now();
  }

  static void clear(String roomId) {
    _cache.remove(roomId);
    _cacheTimestamps.remove(roomId);
  }

}

// Performance optimization: Memoized player status cache
class _PlayerStatusCache {
  static final Map<String, List<PlayerStatus>> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};


  static void set(String roomId, List<PlayerStatus> players) {
    _cache[roomId] = players;
    _cacheTimestamps[roomId] = DateTime.now();
  }

  static void clear(String roomId) {
    _cache.remove(roomId);
    _cacheTimestamps.remove(roomId);
  }
}


class FirebaseService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _rnd = Random();
  
  // --- NEW: Dependency Injection ---
  // The service now depends on AuthProvider for auth state.
  final auth.AuthProvider _authProvider;

  // --- UPDATED: Constructor ---
  // It now requires an AuthProvider instance.
  FirebaseService(this._authProvider) {
    // The auth initialization is now handled by AuthProvider.
  }

  final String _canvasAppId = const String.fromEnvironment('app_id', defaultValue: 'default-app-id');

  // Performance optimization: Clean up caches when leaving room
  void _cleanupCaches(String roomId) {
    // Clear caches
    _RoundCache.clear(roomId);
    _PlayerStatusCache.clear(roomId);
    
    // Clear debounced update timers
    _updateTimers[roomId]?.cancel();
    _updateTimers.remove(roomId);
    _pendingUpdates.remove(roomId);
  }


  Future<void> _checkNetworkConnectivity() async {
    try {
      // Quick connectivity check with shorter timeout
      final connectivityResult = await Connectivity().checkConnectivity().timeout(
        const Duration(seconds: 3), // Reduced from default timeout
      );
      
      ExceptionHandler.logError('network_check', 'Connectivity check result', 
        extraData: {'connectivity': connectivityResult.toString()});
      
      if (connectivityResult == ConnectivityResult.none) {
        throw NetworkException(
          'No internet connection available. Please check your network settings and try again.',
          code: 'NO_CONNECTIVITY',
          details: 'Connectivity result: $connectivityResult',
          stackTrace: StackTrace.current,
        );
      }
      
      // Skip Firebase connectivity check on emulator to avoid network issues
      final isEmulator = await _isRunningOnEmulator();
      if (isEmulator) {
        ExceptionHandler.logError('network_check', 'Skipping Firebase connectivity check on emulator');
        return; // Allow emulator to proceed without Firebase connectivity check
      }
      
      // Skip additional Firebase connectivity check to speed up startup
      // The app will handle network errors gracefully when they occur
      ExceptionHandler.logError('network_check', 'Skipping Firebase service connectivity check for faster startup');
      
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      // Don't throw on connectivity check failure - let the app start and handle errors later
      ExceptionHandler.logError('network_check', 'Connectivity check failed, continuing anyway', 
        extraData: {'error': e.toString()});
    }
  }

  // Enhanced method to check Firebase connectivity with retry
  Future<bool> _checkFirebaseConnectivityWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        ExceptionHandler.logError('firebase_connectivity', 'Checking Firebase connectivity', 
          extraData: {'attempt': attempt, 'maxRetries': maxRetries});
        
        // Try to access a collection that exists (bundles collection - users can read)
        await _db.collection('bundles').limit(1).get().timeout(const Duration(seconds: 5));
        
        ExceptionHandler.logError('firebase_connectivity', 'Firebase connectivity verified', 
          extraData: {'attempt': attempt});
        return true;
        
      } catch (e) {
        ExceptionHandler.logError('firebase_connectivity', 'Firebase connectivity check failed', 
          extraData: {'attempt': attempt, 'error': e.toString()});
        
        if (attempt == maxRetries) {
          return false;
        }
        
        // Wait before retry
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return false;
  }

  Future<bool> _isRunningOnEmulator() async {
    try {
      // Check for common emulator indicators
      final androidId = await _getAndroidId();
      final isEmulator = androidId.contains('sdk') || 
                         androidId.contains('google_sdk') ||
                         androidId.contains('emulator');
      
      ExceptionHandler.logError('device_check', 'Device type detection', 
        extraData: {'androidId': androidId, 'isEmulator': isEmulator});
      
      return isEmulator;
    } catch (e) {
      ExceptionHandler.logError('device_check', 'Device type detection failed', 
        extraData: {'error': e.toString()});
      return false; // Assume real device if detection fails
    }
  }

  Future<String> _getAndroidId() async {
    try {
      // This is a simplified approach - in a real app you'd use device_info_plus
      return 'unknown'; // Placeholder - would need device_info_plus package
    } catch (e) {
      return 'unknown';
    }
  }

  Future<void> _validateUserIsHost(String roomId, String operation) async {
    try {
      final roomDoc = await _db.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw RoomOperationException(
          'Room not found.',
          code: 'ROOM_NOT_FOUND',
          details: 'Room $roomId does not exist',
          stackTrace: StackTrace.current,
        );
      }
      
      final roomData = roomDoc.data()!;
      final creatorUid = roomData['creator'] as String? ?? '';
      
      if (creatorUid != currentUserUid) {
        throw PermissionException(
          'Only the host can start the round.',
          code: 'NOT_HOST',
          details: 'User $currentUserUid is not the host (creator: $creatorUid)',
          stackTrace: StackTrace.current,
        );
      }
      
      ExceptionHandler.logError(operation, 'Host validation successful');
      
    } catch (e) {
      if (e is FirebaseServiceException) {
        rethrow;
      }
      throw RoomOperationException(
        'Failed to validate host permissions.',
        code: 'HOST_VALIDATION_FAILED',
        details: e.toString(),
        stackTrace: StackTrace.current,
      );
    }
  }

  Future<void> _setupNewRoundStateWithException({required String roomId, required bool isFirstRound, required String operation}) async {
    try {
      ExceptionHandler.logError(operation, 'Setting up new round state', 
        extraData: {'isFirstRound': isFirstRound});
      
      await _setupNewRoundState(roomId, isFirstRound: isFirstRound);
      
      ExceptionHandler.logError(operation, 'New round state setup completed');
      
    } catch (e) {
      throw _convertFirebaseException(e, operation, 'Failed to setup new round state');
    }
  }


  // --- UPDATED: currentUserUid getter ---
  // It gets the UID directly from the AuthProvider.
  String get currentUserUid => _authProvider.uid ?? '';


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

  Future<bool> _validateBundleOwnership(String bundleId) async {
    try {
      // For now, we'll assume the user owns the bundle if it's the free bundle
      // In a real implementation, this would check against the user's owned bundles
      if (bundleId == 'bundle.free') return true;
      
      // TODO: Implement proper bundle ownership validation
      // This would check against the user's purchased bundles in Firestore
      return true; // Temporary: assume user owns the bundle
    } catch (e) {
      print('Error validating bundle ownership: $e');
      return false;
    }
  }

  String _randomCode(int n) =>
      List.generate(n, (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[_rnd.nextInt(36)])
          .join();

  Future<bool> roomExists(String roomId) async =>
      (await _db.collection('rooms').doc(roomId).get()).exists;

  Future<String> createRoom(bool saboteurEnabled, bool diceRollEnabled, String selectedBundle) async {
    const operation = 'create_room';
    
    try {
      ExceptionHandler.logError(operation, 'Starting room creation', 
        extraData: {
          'saboteurEnabled': saboteurEnabled,
          'diceRollEnabled': diceRollEnabled,
          'selectedBundle': selectedBundle,
        });

      // Step 1: Check network connectivity and Firebase access
      final isEmulator = await _isRunningOnEmulator();
      if (!isEmulator) {
        await _checkNetworkConnectivity();
        
        // Test Firebase connectivity specifically
        final firebaseConnected = await testFirebaseConnectivity();
        if (!firebaseConnected) {
          throw NetworkException(
            'Cannot connect to Firebase servers. Please check your internet connection.',
            code: 'FIREBASE_UNREACHABLE',
            details: 'Firebase connectivity test failed',
            stackTrace: StackTrace.current,
          );
        }
      } else {
        ExceptionHandler.logError(operation, 'Skipping network connectivity check on emulator');
      }

      // Step 2: Validate authentication - now handled by AuthProvider
      if (currentUserUid.isEmpty) {
        throw AuthenticationException(
          'User authentication required. Please restart the app and try again.',
          code: 'AUTH_REQUIRED',
          details: 'currentUserUid is empty - authentication handled by AuthProvider',
          stackTrace: StackTrace.current,
        );
      }

      // Step 3: Validate bundle ownership
      await _validateBundleOwnershipWithException(selectedBundle, operation);

      // Step 4: Generate unique room ID
      final roomId = await _generateUniqueRoomId(operation);

      // Step 5: Create room document
      await _createRoomDocument(roomId, saboteurEnabled, diceRollEnabled, selectedBundle, operation);

      // Step 6: Create player document
      await _createPlayerDocument(roomId, operation);

      // Step 7: Save current room ID
      await _saveCurrentRoomIdWithException(roomId, operation);

      ExceptionHandler.logError(operation, 'Room creation completed successfully', 
        extraData: {'roomId': roomId});

      notifyListeners();
      return roomId;

    } catch (e) {
      ExceptionHandler.logError(operation, 'Room creation failed', 
        extraData: {'error': e.toString()});
      
      // Re-throw as appropriate exception type
      if (e is FirebaseServiceException) {
        rethrow;
      }
      
      if (e is FirebaseException) {
        throw _convertFirebaseException(e, operation);
      }
      
      throw RoomOperationException(
        'Failed to create room: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
        details: e.toString(),
        stackTrace: StackTrace.current,
      );
    }
  }

  // Helper methods for room creation with proper exception handling
  Future<void> _ensureUserAuthenticated(String operation) async {
    if (currentUserUid.isEmpty) {
      ExceptionHandler.logError(operation, 'User not authenticated');
      
      throw AuthenticationException(
        'User authentication required. Please restart the app and try again.',
        code: 'AUTH_REQUIRED',
        details: 'currentUserUid is empty - authentication handled by AuthProvider',
        stackTrace: StackTrace.current,
      );
    }
  }

  Future<void> _validateBundleOwnershipWithException(String bundleId, String operation) async {
    try {
      if (!await _validateBundleOwnership(bundleId)) {
        throw PermissionException(
          'You must own this bundle to host a game with it. Please purchase the bundle first.',
          code: 'BUNDLE_NOT_OWNED',
          details: 'Bundle validation failed for: $bundleId',
          stackTrace: StackTrace.current,
        );
      }
    } catch (e) {
      if (e is FirebaseServiceException) {
        rethrow;
      }
      throw PermissionException(
        'Failed to validate bundle ownership. Please try again.',
        code: 'BUNDLE_VALIDATION_FAILED',
        details: e.toString(),
        stackTrace: StackTrace.current,
      );
    }
  }

  Future<String> _generateUniqueRoomId(String operation) async {
    try {
      String roomId;
      int attempts = 0;
      const maxAttempts = 20; // Increased from 10 to 20
      
      do {
        // Use longer room codes for better uniqueness
        roomId = _randomCode(attempts < 10 ? 4 : 5); // Start with 4, then 5 characters
        attempts++;
        
        ExceptionHandler.logError(operation, 'Attempting to generate room ID', 
          extraData: {'attempt': attempts, 'roomId': roomId});
        
        if (attempts > maxAttempts) {
          throw RoomOperationException(
            'Unable to generate a unique room ID. Please try again.',
            code: 'ROOM_ID_GENERATION_FAILED',
            details: 'Exceeded maximum attempts ($maxAttempts)',
            stackTrace: StackTrace.current,
          );
        }
        
        // Add timeout to roomExists check
        final exists = await roomExists(roomId).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            ExceptionHandler.logError(operation, 'Room existence check timed out');
            return false; // Assume room doesn't exist if check times out
          },
        );
        
        if (!exists) break;
        
      } while (true);
      
      ExceptionHandler.logError(operation, 'Generated unique room ID', 
        extraData: {'roomId': roomId, 'attempts': attempts});
      
      return roomId;
    } catch (e) {
      if (e is FirebaseServiceException) {
        rethrow;
      }
      throw RoomOperationException(
        'Failed to generate room ID. Please try again.',
        code: 'ROOM_ID_ERROR',
        details: e.toString(),
        stackTrace: StackTrace.current,
      );
    }
  }

  Future<void> _createRoomDocument(String roomId, bool saboteurEnabled, bool diceRollEnabled, String selectedBundle, String operation) async {
    try {
      final roomRef = _db.collection('rooms').doc(roomId);
      
      await roomRef.set({
        'creator': currentUserUid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'lobby',
        'saboteurEnabled': saboteurEnabled,
        'diceRollEnabled': diceRollEnabled,
        'selectedBundle': selectedBundle,
        'currentRoundNumber': 0,
        'navigatorRotationIndex': 0,
        'playerOrder': [currentUserUid],
        'usedCategoryIds': [],
        'saboteurId': null,
        'totalGroupScore': 0,
      });
      
      ExceptionHandler.logError(operation, 'Room document created successfully');
    } catch (e) {
      throw _convertFirebaseException(e, operation, 'Failed to create room document');
    }
  }

  Future<void> _createPlayerDocument(String roomId, String operation) async {
    try {
      final roomRef = _db.collection('rooms').doc(roomId);
      final String randomAvatarId = Avatars.getRandomAvatarId();
      
      await roomRef.collection('players').doc(currentUserUid).set({
        'displayName': 'Player-${currentUserUid.substring(0, 4)}',
        'isReady': false,
        'guessReady': false,
        'online': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'tokens': 0,
        'avatarId': randomAvatarId,
      });
      
      ExceptionHandler.logError(operation, 'Player document created successfully');
    } catch (e) {
      throw _convertFirebaseException(e, operation, 'Failed to create player document');
    }
  }

  Future<void> _saveCurrentRoomIdWithException(String roomId, String operation) async {
    try {
      await saveCurrentRoomId(roomId);
      ExceptionHandler.logError(operation, 'Current room ID saved successfully');
    } catch (e) {
      throw _convertFirebaseException(e, operation, 'Failed to save current room ID');
    }
  }

  FirebaseServiceException _convertFirebaseException(dynamic error, String operation, [String? customMessage]) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return PermissionException(
            customMessage ?? 'You don\'t have permission to create rooms. Please check your account status.',
            code: error.code,
            details: error.message,
            stackTrace: StackTrace.current,
          );
        case 'unavailable':
          return NetworkException(
            customMessage ?? 'Service temporarily unavailable. Please check your internet connection and try again.',
            code: error.code,
            details: error.message,
            stackTrace: StackTrace.current,
          );
        case 'unauthenticated':
          return AuthenticationException(
            customMessage ?? 'You need to sign in again. Please restart the app.',
            code: error.code,
            details: error.message,
            stackTrace: StackTrace.current,
          );
        default:
          return RoomOperationException(
            customMessage ?? 'Failed to create room: ${error.message}',
            code: error.code,
            details: error.message,
            stackTrace: StackTrace.current,
          );
      }
    }
    
    return RoomOperationException(
      customMessage ?? 'An unexpected error occurred while creating the room.',
      code: 'UNKNOWN_ERROR',
      details: error.toString(),
      stackTrace: StackTrace.current,
    );
  }

  Stream<PlayerStatus?> listenNavigator(String roomId) {
    return Rx.combineLatest2(
      listenCurrentRound(roomId),
      playersColRef(roomId).snapshots(),
      (Round round, QuerySnapshot<Map<String, dynamic>> playersSnap) {
        if (round.roles == null) return null;
        
        String? navigatorUid;
        round.roles!.forEach((uid, role) {
          if (role == Role.Navigator) {
            navigatorUid = uid;
          }
        });

        if (navigatorUid == null) return null;

        final playerDocs = playersSnap.docs;
        try {
          final navigatorDoc = playerDocs.firstWhere((doc) => doc.id == navigatorUid);
          return PlayerStatus.fromSnapshot(navigatorDoc);
        } catch (e) {
          return null;
        }
      },
    );
  }

  // Paste this entire method inside your FirebaseService class

  /// Fetches historical rounds for the scoreboard.
  Future<List<RoundHistoryEntry>> fetchHistory(String roomId) async {
    final snap = await _db
        .collection('rooms')
        .doc(roomId)
        .collection('rounds')
        .doc('current')
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((d) => RoundHistoryEntry.fromMap(d.data())).toList();
  }


  Future<void> joinRoom(String roomId) async {
    if (currentUserUid.isEmpty) {
      throw Exception("User is not authenticated. Cannot join a room.");
    }

    final roomRef = _db.collection('rooms').doc(roomId);
    final playerRef = roomRef.collection('players').doc(currentUserUid);

    // Get user's custom username or fallback to default
    final displayName = await _getUserDisplayName();

    await playerRef.set({
      'displayName': displayName,
      'isReady': false,
      'guessReady': false,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'tokens': 0,
      'avatarId': Avatars.getRandomAvatarId(),
    }, SetOptions(merge: true));

    await roomRef.update({
      'playerOrder': FieldValue.arrayUnion([currentUserUid]),
    });

    await saveCurrentRoomId(roomId);
    notifyListeners();
  }

  Future<void> leaveRoom(String roomId) async {
    TestBotService.stop();
    if (_authProvider.user == null) return;
    final currentUserDisplayName = (await playersColRef(roomId).doc(currentUserUid).get()).data()?['displayName'] as String? ?? 'A player';

    await playersColRef(roomId).doc(currentUserUid).delete();

    await roomDocRef(roomId).update({
      'playerOrder': FieldValue.arrayRemove([currentUserUid]),
    });

    await saveCurrentRoomId(null);

    // Performance optimization: Clean up caches
    _cleanupCaches(roomId);

    print('$currentUserDisplayName has left room $roomId');
  }

  // Removed _seedCategories method - now using CategoryService for efficient client-side filtering

  DocumentReference<Map<String,dynamic>> roomDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId);

  DocumentReference<Map<String,dynamic>> roundDocRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('rounds').doc('current');

  CollectionReference<Map<String,dynamic>> playersColRef(String roomId) =>
      _db.collection('rooms').doc(roomId).collection('players');

  DocumentReference<Map<String,dynamic>> userDocRef(String userId) =>
      _db.collection('users').doc(userId);

  /// Get user's display name from custom_usernames or fallback to default
  Future<String> _getUserDisplayName() async {
    try {
      // First, try to get custom username
      final customUsernameQuery = await _db
          .collection('custom_usernames')
          .where('userId', isEqualTo: currentUserUid)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (customUsernameQuery.docs.isNotEmpty) {
        final customUsername = customUsernameQuery.docs.first.data()['username'] as String?;
        if (customUsername != null && customUsername.isNotEmpty) {
          return customUsername;
        }
      }

      // Fallback to Firebase Auth display name
      final authDisplayName = _authProvider.user?.displayName;
      if (authDisplayName != null && authDisplayName.isNotEmpty) {
        return authDisplayName;
      }

      // Final fallback to Player-XXXX format
      return 'Player-${currentUserUid.substring(0, 4)}';
    } catch (e) {
      // If anything fails, use the fallback
      return 'Player-${currentUserUid.substring(0, 4)}';
    }
  }

  /// Save match settings for the user
  Future<void> saveMatchSettings(MatchSettings settings) async {
    if (currentUserUid.isEmpty) return;

    try {
      await _db
          .collection('users')
          .doc(currentUserUid)
          .set({
        'matchSettings': settings.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save match settings: $e');
    }
  }

  /// Load match settings for the user
  Future<MatchSettings> loadMatchSettings() async {
    if (currentUserUid.isEmpty) return MatchSettings.defaultSettings;

    try {
      final doc = await _db.collection('users').doc(currentUserUid).get();
      
      if (!doc.exists) return MatchSettings.defaultSettings;
      
      final data = doc.data() as Map<String, dynamic>;
      final settingsData = data['matchSettings'] as Map<String, dynamic>?;
      
      if (settingsData == null) return MatchSettings.defaultSettings;
      
      return MatchSettings.fromMap(settingsData);
    } catch (e) {
      return MatchSettings.defaultSettings;
    }
  }

  Future<List<PigeonUserDetails>> fetchPlayers(String roomId) async {
    final querySnapshot = await playersColRef(roomId).get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return PigeonUserDetails(
        uid: doc.id,
        displayName: data['displayName'] as String? ?? 'Anonymous',
        totalScore: 0,
        tokens: data['tokens'] as int? ?? 0,
      );
    }).toList();
  }

  Future<void> setReady(String roomId, bool ready, {String? uid}) => playersColRef(roomId)
    .doc(uid ?? currentUserUid)
    .update({'isReady': ready});

  Stream<List<PlayerStatus>> listenToReady(String roomId) {
    return playersColRef(roomId).snapshots().map((snap) {
      final players = snap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList();
      _PlayerStatusCache.set(roomId, players); // Cache the result
      return players;
    });
  }

  Future<void> _setupNewRoundState(String roomId, {required bool isFirstRound}) async {
    print('DEBUG: _setupNewRoundState function started.');
    try {
      final roomSnap = await roomDocRef(roomId).get();
      if (!roomSnap.exists) return;
      final roomData = roomSnap.data()!;

      List<String> playerOrder = List<String>.from(roomData['playerOrder'] ?? []);
      List<String> usedCategoryIds = List<String>.from(roomData['usedCategoryIds'] ?? []);
      final saboteurEnabled = roomData['saboteurEnabled'] as bool? ?? false;
      final diceRollEnabled = roomData['diceRollEnabled'] as bool? ?? false;

      if (playerOrder.isEmpty || isFirstRound) {
        final playersSnap = await playersColRef(roomId).get();
        playerOrder = playersSnap.docs.map((d) => d.id).toList();
        playerOrder.shuffle();
        print('🔍 Setup round - Player order from collection: $playerOrder');
      } else {
        print('🔍 Setup round - Player order from room data: $playerOrder');
      }

      final currentRoundNumber = (roomData['currentRoundNumber'] as int) + 1;
      final navigatorRotationIndex = (roomData['navigatorRotationIndex'] as int);
      final navigatorUid = playerOrder[navigatorRotationIndex % playerOrder.length];
      
      print('🔍 Setup round - Navigator calculation:');
      print('🔍 Current round number: $currentRoundNumber');
      print('🔍 Navigator rotation index: $navigatorRotationIndex');
      print('🔍 Player order length: ${playerOrder.length}');
      print('🔍 Calculated navigator UID: $navigatorUid');
      print('🔍 Is navigator UID in playerOrder? ${playerOrder.contains(navigatorUid)}');

      String? saboteurUid = roomData['saboteurId'] as String?;
      if (saboteurEnabled && saboteurUid == null) {
        final potentialSaboteurs = playerOrder.where((uid) => uid != navigatorUid).toList();
        if (potentialSaboteurs.isNotEmpty) {
          saboteurUid = potentialSaboteurs[_rnd.nextInt(potentialSaboteurs.length)];
        }
      }

      final batch = _db.batch();
      final playersSnap = await playersColRef(roomId).get();
      print('🔍 Setup round - Processing players for roles: ${playersSnap.docs.map((d) => d.id)}');
      print('🔍 Setup round - Navigator UID: $navigatorUid');
      print('🔍 Setup round - Saboteur UID: $saboteurUid');
      
      for (var doc in playersSnap.docs) {
        final playerUid = doc.id;
        Role role;
        if (playerUid == navigatorUid) {
          role = Role.Navigator;
        } else if (saboteurEnabled && playerUid == saboteurUid) {
          role = Role.Saboteur;
        } else {
          role = Role.Seeker;
        }
        
        print('🔍 Setup round - Assigning role to $playerUid: $role');
        
        batch.update(playersColRef(roomId).doc(playerUid), {
          'role': role.toString().split('.').last,
          'isReady': false,
          'guessReady': false,
        });
      }

      // Use CategoryService for efficient client-side category selection with room bundle
      // Get the bundle selected for this room
      final roomBundle = roomData['selectedBundle'] as String? ?? 'bundle.free';
      final allAvailableCategories = CategoryService.getCategoriesByBundle(roomBundle);
      final availableCategories = allAvailableCategories
          .where((category) => !usedCategoryIds.contains(category.id))
          .toList();
      
      String selectedCategoryId;
      Map<String, dynamic> selectedCategoryData;

      if (availableCategories.isEmpty) {
        usedCategoryIds = [];
        final randomCategory = allAvailableCategories[_rnd.nextInt(allAvailableCategories.length)];
        selectedCategoryId = randomCategory.id;
        selectedCategoryData = randomCategory.toMap();
      } else {
        final randomCategory = availableCategories[_rnd.nextInt(availableCategories.length)];
        selectedCategoryId = randomCategory.id;
        selectedCategoryData = randomCategory.toMap();
      }
      usedCategoryIds.add(selectedCategoryId);

      final secretPosition = _rnd.nextInt(101);

      Effect? rolledEffect = Effect.none;
      if (diceRollEnabled) {
        final List<Effect> possibleEffects = Effect.values.where((e) => e != Effect.none).toList();
        rolledEffect = possibleEffects[_rnd.nextInt(possibleEffects.length)];
      }

      String initialRoomStatus = 'role_reveal';
      print('DEBUG: Determined next room status will be: "$initialRoomStatus"');

      batch.set(roundDocRef(roomId), {
        'secretPosition': secretPosition,
        'categoryLeft': selectedCategoryData['left']['en'], // Store English as fallback
        'categoryRight': selectedCategoryData['right']['en'], // Store English as fallback
        'categoryId': selectedCategoryId, // Store the category ID for localization
        'clue': null,
        'guesses': {},
        'roles': playersSnap.docs.asMap().map((index, doc) {
          final playerUid = doc.id;
          Role role;
          if (playerUid == navigatorUid) {
            role = Role.Navigator;
          } else if (saboteurEnabled && playerUid == saboteurUid) {
            role = Role.Saboteur;
          } else {
            role = Role.Seeker;
          }
          
          final roleString = role.toString().split('.').last;
          print('🔍 Assigning role to $playerUid: $role -> "$roleString"');
          
          return MapEntry(playerUid, roleString);
        }),
        'groupGuessPosition': 50,
        'score': null,
        'roundStartedTimestamp': FieldValue.serverTimestamp(),
        'effect': rolledEffect.toString().split('.').last,
        'effectRolledAt': rolledEffect != Effect.none ? FieldValue.serverTimestamp() : null,
        'roundNumber': currentRoundNumber,
      });

      batch.update(roomDocRef(roomId), {
        'status': initialRoomStatus,
        'currentRoundNumber': currentRoundNumber,
        'navigatorRotationIndex': (navigatorRotationIndex + 1) % playerOrder.length,
        'saboteurId': saboteurUid,
        'playerOrder': playerOrder,
        'usedCategoryIds': usedCategoryIds,
        'currentCategoryId': selectedCategoryId,
        'currentTrueSliderPosition': secretPosition,
        'roundStartedTimestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('DEBUG: Batch commit successful. Room status should now be updated in Firestore.');

    } catch (e) {
      print('--- DEBUG: AN ERROR OCCURRED IN _setupNewRoundState ---');
      print(e);
    }
  }

  Future<void> transitionAfterRoleReveal(String roomId) async {
    final roomSnap = await roomDocRef(roomId).get();
    if (!roomSnap.exists) return;

    final diceRollEnabled = roomSnap.data()?['diceRollEnabled'] as bool? ?? false;
    print('DEBUG: Dice roll enabled? $diceRollEnabled');
    
    final nextStatus = diceRollEnabled ? 'dice_roll' : 'clue_submission';
    await roomDocRef(roomId).update({'status': nextStatus});
  }

  Future<void> startRound(String roomId) async {
    const operation = 'start_round';
    
    try {
      ExceptionHandler.logError(operation, 'Starting round', 
        extraData: {'roomId': roomId});

      // Step 1: Check Firebase connectivity (skip on emulator)
      final isEmulator = await _isRunningOnEmulator();
      if (!isEmulator) {
        final isFirebaseConnected = await _checkFirebaseConnectivityWithRetry();
        if (!isFirebaseConnected) {
          throw NetworkException(
            'Unable to connect to game services. Please check your internet connection and try again.',
            code: 'FIREBASE_CONNECTIVITY_FAILED',
            details: 'Firebase connectivity check failed after retries',
            stackTrace: StackTrace.current,
          );
        }
      } else {
        ExceptionHandler.logError(operation, 'Skipping Firebase connectivity check on emulator');
      }

      // Step 2: Validate authentication
      await _ensureUserAuthenticated(operation);

      // Step 3: Validate user is host
      await _validateUserIsHost(roomId, operation);

      // Step 4: Setup new round state
      await _setupNewRoundStateWithException(roomId: roomId, isFirstRound: true, operation: operation);

      ExceptionHandler.logError(operation, 'Round started successfully');

    } catch (e) {
      ExceptionHandler.logError(operation, 'Round start failed', 
        extraData: {'error': e.toString()});
      
      // Re-throw as appropriate exception type
      if (e is FirebaseServiceException) {
        rethrow;
      }
      
      if (e is FirebaseException) {
        throw _convertFirebaseException(e, operation);
      }
      
      throw RoomOperationException(
        'Failed to start round: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
        details: e.toString(),
        stackTrace: StackTrace.current,
      );
    }
  }

  Future<void> transitionAfterDiceRoll(String roomId) async {
    await roomDocRef(roomId).update({'status': 'clue_submission'});
  }

  Stream<String> listenRoomStatus(String roomId) {
    return roomDocRef(roomId).snapshots().handleError((error) {
      ExceptionHandler.logError('room_status_stream', 'Error listening to room status', 
        extraData: {'roomId': roomId, 'error': error.toString()});
      
      // Return a stream that emits 'lobby' on error to prevent app crashes
      return 'lobby';
    }).map((snap) {
      final data = snap.data();
      final status = (data?['status'] as String?) ?? 'lobby';
      
      ExceptionHandler.logError('room_status_stream', 'Room status update', 
        extraData: {'roomId': roomId, 'status': status});
      
      return status;
    });
  }

  Stream<Role> listenMyRole(String roomId) {
    return roundDocRef(roomId).snapshots().map((snap) {
      final data = snap.data();
      final rolesMap = (data?['roles'] as Map<String, dynamic>?)?.cast<String, String>() ?? {};
      final myRoleString = rolesMap[currentUserUid];
      return Role.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == myRoleString?.toLowerCase(),
        orElse: () => Role.Seeker,
      );
    });
  }

  Future<void> submitClue(String roomId, int secret, String clue) async {
    await roundDocRef(roomId).set({
      'clue': clue,
    }, SetOptions(merge: true));

    await roomDocRef(roomId).update({'status': 'guessing'});
  }

  Stream<Round> listenCurrentRound(String roomId) {
    return roundDocRef(roomId).snapshots().map((snap) {
      final round = Round.fromMap(snap.data() ?? {});
      _RoundCache.set(roomId, round); // Cache the result
      return round;
    });
  }

  // Performance optimization: Cache for debounced updates
  static final Map<String, Timer> _updateTimers = {};
  static final Map<String, double> _pendingUpdates = {};

  Future<void> updateGroupGuess(String roomId, double pos) async {
    // Performance optimization: Debounce rapid updates to reduce Firebase writes
    _updateTimers[roomId]?.cancel();
    _pendingUpdates[roomId] = pos;
    
    _updateTimers[roomId] = Timer(const Duration(milliseconds: 50), () { // Reduced from 100ms to 50ms for better responsiveness
      final finalPos = _pendingUpdates[roomId];
      if (finalPos != null) {
        roundDocRef(roomId).update({'groupGuessPosition': finalPos.round()});
        _pendingUpdates.remove(roomId);
      }
    });
  }

  Stream<int> listenGroupGuess(String roomId) {
    return roundDocRef(roomId).snapshots().map((snap) {
      final data = snap.data();
      return (data?['groupGuessPosition'] as num?)?.toInt() ?? 50;
    });
  }

  Future<void> setGuessReady(String roomId, bool ready, {String? uid}) => playersColRef(roomId)
    .doc(uid ?? currentUserUid)
    .update({'guessReady': ready});

  Future<void> addBotToRoom(String roomId) async {
    const operation = 'add_bot';
    
    try {
      ExceptionHandler.logError(operation, 'Adding bot to room', 
        extraData: {'roomId': roomId});
      
      const botUid = 'test-bot-001';
      final playerRef = playersColRef(roomId).doc(botUid);

      // Check if bot already exists
      final existingBot = await playerRef.get();
      if (existingBot.exists) {
        ExceptionHandler.logError(operation, 'Bot already exists in room', 
          extraData: {'roomId': roomId, 'botUid': botUid});
        print('🤖 TestBot already exists in room $roomId');
        return; // Bot already exists, no need to add again
      }

      await playerRef.set({
        'displayName': 'TestBot 🤖',
        'isReady': false,
        'guessReady': false,
        'online': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'tokens': 0,
        'avatarId': Avatars.getRandomAvatarId(),
        'isBot': true, // Required by Firebase rules
      }, SetOptions(merge: true));

      // Get current playerOrder and add bot to it
      final currentRoomSnap = await roomDocRef(roomId).get();
      final currentPlayerOrder = List<String>.from(currentRoomSnap.data()?['playerOrder'] ?? []);
      
      if (!currentPlayerOrder.contains(botUid)) {
        currentPlayerOrder.add(botUid);
        await roomDocRef(roomId).update({
          'playerOrder': currentPlayerOrder,
        });
        print('🤖 Bot added to playerOrder: $currentPlayerOrder');
      } else {
        print('🤖 Bot already in playerOrder: $currentPlayerOrder');
      }
      
      // Verify the bot was added to playerOrder
      final updatedRoomSnap = await roomDocRef(roomId).get();
      final updatedPlayerOrder = List<String>.from(updatedRoomSnap.data()?['playerOrder'] ?? []);
      print('🤖 Bot added - Updated playerOrder: $updatedPlayerOrder');
      print('🤖 Bot UID in playerOrder: ${updatedPlayerOrder.contains(botUid)}');
      
      ExceptionHandler.logError(operation, 'Bot added successfully', 
        extraData: {'roomId': roomId, 'botUid': botUid});
      print('🤖 TestBot added to room $roomId');
      
    } catch (e) {
      ExceptionHandler.logError(operation, 'Failed to add bot', 
        extraData: {'roomId': roomId, 'error': e.toString()});
      print('❌ Failed to add bot: $e');
      rethrow;
    }
  }

  Stream<List<PlayerStatus>> listenGuessReady(String roomId) {
    // Performance optimization: Reuse the same stream as listenToReady since they listen to the same data
    return listenToReady(roomId);
  }

  Stream<bool> listenAllSeekersReady(String roomId) {
    return Rx.combineLatest2(
      playersColRef(roomId).snapshots().map((snap) => snap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList()),
      roundDocRef(roomId).snapshots().map((snap) => Round.fromMap(snap.data() ?? {})),
      (List<PlayerStatus> allPlayers, Round currentRound) {
        final rolesMap = currentRound.roles;
        if (rolesMap == null || rolesMap.isEmpty) return false;

        String? navigatorUid;
        rolesMap.forEach((uid, role) {
          if (role == Role.Navigator) {
            navigatorUid = uid;
          }
        });

        final playersToCheck = allPlayers.where((p) => p.uid != navigatorUid).toList();

        if (playersToCheck.isEmpty) return true;

        return playersToCheck.every((p) => p.guessReady);
      },
    );
  }

  Future<void> finalizeRound(String roomId) async {
    await _db.runTransaction((transaction) async {
      final roomRef = roomDocRef(roomId);
      final roundRef = roundDocRef(roomId);

      final roomSnap = await transaction.get(roomRef);
      final roundSnap = await transaction.get(roundRef);

      if (!roomSnap.exists || !roundSnap.exists) {
        throw Exception("Room or Round does not exist!");
      }

      if (roomSnap.data()?['status'] != 'guessing') {
        print('Round already finalized. Skipping.');
        return;
      }
      
      final roundData = roundSnap.data()!;
      final Effect currentEffect = Effect.values.firstWhere(
        (e) => e.toString().split('.').last == (roundData['effect'] as String?),
        orElse: () => Effect.none,
      );

      final secret = (roundData['secretPosition'] as num?)?.toInt() ?? 0;
      final guess = (roundData['groupGuessPosition'] as num?)?.toInt() ?? 0;
      final distance = (secret - guess).abs();

      int score;
      if (distance <= 2) {
        score = 6;
      } else if (distance <= 5) {
        score = 4;
      } else if (distance <= 10) {
        score = 3;
      } else if (distance <= 15) {
        score = 2;
      } else if (distance <= 20) {
        score = 1;
      } else {
        score = 0;
      }

      int finalScore = score;
      String navigatorUid = '';
      final rolesMap = (roundData['roles'] as Map<String, dynamic>?)?.cast<String, String>() ?? {};
      rolesMap.forEach((uid, roleString) {
        if (Role.Navigator.toString().split('.').last == roleString) {
          navigatorUid = uid;
        }
      });

      if (currentEffect == Effect.doubleScore) {
        finalScore *= 2;
      } else if (currentEffect == Effect.halfScore) {
        finalScore = (finalScore / 2).round();
      } else if (currentEffect == Effect.token && navigatorUid.isNotEmpty) {
        await playersColRef(roomId).doc(navigatorUid).update({
          'tokens': FieldValue.increment(1),
        });
      }

      transaction.update(roundRef, {
        'score': finalScore,
        'roundEndedTimestamp': FieldValue.serverTimestamp(),
      });

      transaction.update(roomRef, {
        'totalGroupScore': FieldValue.increment(finalScore),
        'status': 'round_end',
      });
    });

    final roundSnap = await roundDocRef(roomId).get();
    final roomSnap = await roomDocRef(roomId).get();
    final roundData = roundSnap.data()!;
    final secret = (roundData['secretPosition'] as num?)?.toInt() ?? 0;
    final guess = (roundData['groupGuessPosition'] as num?)?.toInt() ?? 0;
    final finalScore = roundData['score'];
    final currentRoundNumberInRoom = roomSnap.data()?['currentRoundNumber'];
    final effectString = roundData['effect'];

    final roomHistoryCollection = _db.collection('rooms').doc(roomId).collection('rounds').doc('current').collection('history');
    await roomHistoryCollection.add({
      'roundNumber': currentRoundNumberInRoom,
      'secret': secret,
      'guess': guess,
      'score': finalScore,
      'timestamp': FieldValue.serverTimestamp(),
      'effect': effectString,
    });
  }

  Future<void> incrementRoundAndReset(String roomId) async {
    final roomSnap = await roomDocRef(roomId).get();
    if (!roomSnap.exists) return;
    final roomData = roomSnap.data()!;
    final currentRoundNumber = roomData['currentRoundNumber'] as int;

    if (currentRoundNumber >= 5) {
      await roomDocRef(roomId).update({'status': 'match_end'});
    } else {
      await _setupNewRoundState(roomId, isFirstRound: false);

      final batch = _db.batch();
      final playersSnap = await playersColRef(roomId).get();
      for (var doc in playersSnap.docs) {
        batch.update(playersColRef(roomId).doc(doc.id), {
          'isReady': false,
          'guessReady': false,
        });
      }
      await batch.commit();
    }
  }

  Future<void> updateOnlineStatus(String roomId, bool online) async {
    if (_authProvider.user == null) return;
    await playersColRef(roomId).doc(currentUserUid).update({
      'online': online,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Stream<String?> listenForPlayerDepartures(String roomId) {
    return playersColRef(roomId).snapshots().map((snapshot) {
      return null;
    });
  }

  Stream<Map<String, dynamic>> listenToLastPlayerStatus(String roomId) {
    return playersColRef(roomId).snapshots().map((snap) {
      final players = snap.docs.map((d) => PlayerStatus.fromSnapshot(d)).toList();
      final onlinePlayers = players.where((p) => p.online).toList();
      final currentUserId = _authProvider.user?.uid;

      final currentUserDisplayName = players.firstWhere(
        (p) => p.uid == currentUserId,
        orElse: () => PlayerStatus(
            uid: currentUserId ?? 'unknown',
            displayName: 'You',
            ready: false,
            online: false,
            guessReady: false,
            role: 'Seeker',
            avatarId: 'bear'
        ),
      ).displayName;


      final isLastPlayer = onlinePlayers.length == 1 && onlinePlayers.first.uid == currentUserId;

      return {
        'onlinePlayerCount': onlinePlayers.length,
        'isLastPlayer': isLastPlayer,
        'currentUserDisplayName': currentUserDisplayName,
      };
    });
  }

  DocumentReference<Map<String, dynamic>> _userSettingsDocRef() {
    final appId = _canvasAppId;
    final uid = currentUserUid;
    
    if (uid.isEmpty) {
      throw Exception('User not authenticated - cannot access user settings');
    }
    
    return _db.collection('artifacts').doc(appId).collection('users').doc(uid).collection('settings').doc('roomCreation');
  }

  Future<Map<String, bool>> fetchRoomCreationSettings() async {
    try {
      // Ensure user is authenticated before accessing settings
      if (currentUserUid.isEmpty) {
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

  DocumentReference<Map<String, dynamic>> _userCurrentRoomIdDocRef() {
    final appId = _canvasAppId;
    return _db.collection('artifacts').doc(appId).collection('users').doc(currentUserUid).collection('settings').doc('currentRoom');
  }

  Future<void> saveCurrentRoomId(String? roomId) async {
    if (_authProvider.user == null) return;
    try {
      if (roomId != null) {
        await _userCurrentRoomIdDocRef().set({
          'roomId': roomId,
          'lastJoined': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // More robust cleanup - try delete first, then update if that fails
        try {
          await _userCurrentRoomIdDocRef().delete();
        } catch (e) {
          if (e is FirebaseException && e.code == 'not-found') {
            // Document doesn't exist, which is what we want
            print('Current room document already deleted (safe to ignore)');
          } else {
            // Try update as fallback
            await _userCurrentRoomIdDocRef().update({
              'roomId': FieldValue.delete(),
              'lastJoined': FieldValue.delete(),
            });
          }
        }
      }
    } catch (e) {
      print('Error saving current room ID: $e');
      // In case of error, try to force clear the document
      try {
        await _userCurrentRoomIdDocRef().delete();
      } catch (deleteError) {
        print('Failed to force delete current room document: $deleteError');
      }
    }
  }

  Stream<String?> listenCurrentUserRoomId() {
    if (currentUserUid.isEmpty) {
      return Stream.value(null);
    }
    return _userCurrentRoomIdDocRef().snapshots().map((snap) {
      final roomId = snap.data()?['roomId'] as String?;
      // Validate that the room still exists before returning it
      if (roomId != null) {
        // Check if room exists asynchronously and clear if it doesn't
        _validateAndClearStaleRoomId(roomId);
      }
      return roomId;
    });
  }

  // Helper method to validate room exists and clear stale data
  Future<void> _validateAndClearStaleRoomId(String roomId) async {
    try {
      final exists = await roomExists(roomId);
      if (!exists) {
        print('Room $roomId no longer exists, clearing stale current room data');
        await saveCurrentRoomId(null);
      }
    } catch (e) {
      print('Error validating room $roomId: $e');
      // If we can't validate, clear the data to be safe
      await saveCurrentRoomId(null);
    }
  }

  // Aggressive cleanup method to clear any stale room data on startup
  Future<void> _cleanupStaleRoomData() async {
    try {
      if (currentUserUid.isEmpty) return;
      
      print('🧹 Cleaning up stale room data on startup...');
      
      // Force clear any existing current room data
      await saveCurrentRoomId(null);
      
      print('✅ Stale room data cleanup completed');
    } catch (e) {
      print('❌ Error during stale room data cleanup: $e');
    }
  }
}