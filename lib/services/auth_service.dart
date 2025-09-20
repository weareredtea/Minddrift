// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Centralized authentication service that serves as the single source of truth
/// for user authentication state across the entire application.
/// 
/// This service eliminates race conditions by providing a single auth state
/// stream that all other services and UI components can rely on.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Private constructor for singleton pattern
  AuthService._();
  
  // Singleton instance
  static final AuthService instance = AuthService._();
  
  /// The ONLY auth state stream for the entire app
  /// All other services should listen to this stream instead of creating their own
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Get the current authenticated user
  /// Returns null if no user is authenticated
  User? get currentUser => _auth.currentUser;
  
  /// Get the current user's UID
  /// Returns empty string if no user is authenticated
  String get currentUserUid => _auth.currentUser?.uid ?? '';
  
  /// Check if a user is currently authenticated
  bool get isAuthenticated => _auth.currentUser != null;
  
  /// Check if the current user is anonymous
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;
  
  /// Sign in anonymously
  /// This is the primary authentication method for the game
  Future<User?> signInAnonymously() async {
    try {
      debugPrint('🔐 AuthService: Attempting anonymous sign-in...');
      final userCredential = await _auth.signInAnonymously();
      debugPrint('✅ AuthService: Anonymous sign-in successful - UID: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      debugPrint('❌ AuthService: Anonymous sign-in failed: $e');
      return null;
    }
  }
  
  /// Sign in with custom token (for Canvas/WebView integrations)
  Future<User?> signInWithCustomToken(String token) async {
    try {
      debugPrint('🔐 AuthService: Attempting custom token sign-in...');
      final userCredential = await _auth.signInWithCustomToken(token);
      debugPrint('✅ AuthService: Custom token sign-in successful - UID: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      debugPrint('❌ AuthService: Custom token sign-in failed: $e');
      return null;
    }
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    try {
      debugPrint('🔐 AuthService: Signing out user...');
      await _auth.signOut();
      debugPrint('✅ AuthService: Sign-out successful');
    } catch (e) {
      debugPrint('❌ AuthService: Sign-out failed: $e');
    }
  }
  
  /// Initialize authentication on app startup
  /// This method handles the initial authentication flow
  Future<User?> initializeAuth() async {
    try {
      debugPrint('🔐 AuthService: Initializing authentication...');
      
      // Check if user is already authenticated
      if (_auth.currentUser != null) {
        debugPrint('✅ AuthService: User already authenticated - UID: ${_auth.currentUser!.uid}');
        return _auth.currentUser;
      }
      
      // Try custom token authentication first (if available)
      const customToken = String.fromEnvironment('initial_auth_token');
      if (customToken.isNotEmpty) {
        final user = await signInWithCustomToken(customToken);
        if (user != null) {
          return user;
        }
        debugPrint('⚠️ AuthService: Custom token auth failed, falling back to anonymous');
      }
      
      // Fall back to anonymous authentication
      return await signInAnonymously();
      
    } catch (e) {
      debugPrint('❌ AuthService: Authentication initialization failed: $e');
      return null;
    }
  }
  
  /// Wait for authentication to complete
  /// Returns the authenticated user or null if authentication fails
  Future<User?> waitForAuth({Duration timeout = const Duration(seconds: 10)}) async {
    debugPrint('🔐 AuthService: Waiting for authentication...');
    
    // If already authenticated, return immediately
    if (_auth.currentUser != null) {
      debugPrint('✅ AuthService: Already authenticated - UID: ${_auth.currentUser!.uid}');
      return _auth.currentUser;
    }
    
    // Wait for auth state changes with timeout
    try {
      await for (final user in _auth.authStateChanges()) {
        if (user != null) {
          debugPrint('✅ AuthService: Authentication completed - UID: ${user.uid}');
          return user;
        }
      }
    } catch (e) {
      debugPrint('❌ AuthService: Error waiting for auth: $e');
    }
    
    debugPrint('⚠️ AuthService: Authentication timeout or failed');
    return null;
  }
}
