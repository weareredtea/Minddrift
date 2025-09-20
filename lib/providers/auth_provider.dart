// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Central authentication provider that serves as the single source of truth
/// for user authentication state across the entire application.
/// 
/// This provider listens to the AuthService's single auth stream and notifies
/// the rest of the app about authentication changes. All other services and
/// UI widgets should get their auth information from this provider.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  User? _user;
  bool _isInitialized = false;
  bool _isLoading = false;
  
  /// The current authenticated user
  /// Returns null if no user is authenticated
  User? get user => _user;
  
  /// Get the current user's UID
  /// Returns empty string if no user is authenticated
  String get currentUserUid => _user?.uid ?? '';
  
  /// Check if a user is currently authenticated
  bool get isAuthenticated => _user != null;
  
  /// Check if the current user is anonymous
  bool get isAnonymous => _user?.isAnonymous ?? true;
  
  /// Check if the auth provider has been initialized
  bool get isInitialized => _isInitialized;
  
  /// Check if authentication is currently in progress
  bool get isLoading => _isLoading;
  
  AuthProvider() {
    _initialize();
  }
  
  /// Initialize the auth provider by listening to the single auth stream
  void _initialize() {
    debugPrint('🔐 AuthProvider: Initializing...');
    
    // Listen to the SINGLE auth stream from our service
    _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (error) {
        debugPrint('❌ AuthProvider: Auth state error: $error');
        _setLoading(false);
        // Don't notify listeners immediately to avoid rebuild loops
        Future.microtask(() => notifyListeners());
      },
    );
  }
  
  /// Handle authentication state changes
  void _onAuthStateChanged(User? user) {
    debugPrint('🔄 AuthProvider: Auth state changed - User: ${user?.uid ?? "null"}');
    
    _user = user;
    _isInitialized = true;
    _setLoading(false);
    
    // Use Future.microtask to avoid immediate rebuild loops
    Future.microtask(() => notifyListeners());
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
  }
  
  /// Initialize authentication (called by AuthGate)
  Future<void> initializeAuth() async {
    if (_isLoading || _isInitialized) {
      debugPrint('🔐 AuthProvider: Already initialized or loading, skipping...');
      return;
    }
    
    debugPrint('🔐 AuthProvider: Starting authentication initialization...');
    _setLoading(true);
    Future.microtask(() => notifyListeners());
    
    try {
      await _authService.initializeAuth();
      // The auth state listener will handle the result
    } catch (e) {
      debugPrint('❌ AuthProvider: Authentication initialization failed: $e');
      _setLoading(false);
      Future.microtask(() => notifyListeners());
    }
  }
  
  /// Sign in anonymously
  Future<bool> signInAnonymously() async {
    debugPrint('🔐 AuthProvider: Signing in anonymously...');
    _setLoading(true);
    Future.microtask(() => notifyListeners());
    
    try {
      final user = await _authService.signInAnonymously();
      // The auth state listener will handle the result
      return user != null;
    } catch (e) {
      debugPrint('❌ AuthProvider: Anonymous sign-in failed: $e');
      _setLoading(false);
      Future.microtask(() => notifyListeners());
      return false;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    debugPrint('🔐 AuthProvider: Signing out...');
    _setLoading(true);
    Future.microtask(() => notifyListeners());
    
    try {
      await _authService.signOut();
      // The auth state listener will handle the result
    } catch (e) {
      debugPrint('❌ AuthProvider: Sign-out failed: $e');
      _setLoading(false);
      Future.microtask(() => notifyListeners());
    }
  }
  
  /// Wait for authentication to complete
  Future<User?> waitForAuth({Duration timeout = const Duration(seconds: 10)}) async {
    debugPrint('🔐 AuthProvider: Waiting for authentication...');
    
    // If already authenticated, return immediately
    if (_user != null) {
      debugPrint('✅ AuthProvider: Already authenticated - UID: ${_user!.uid}');
      return _user;
    }
    
    // Wait for initialization
    if (!_isInitialized) {
      debugPrint('⏳ AuthProvider: Waiting for initialization...');
      final stopwatch = Stopwatch()..start();
      
      while (!_isInitialized && stopwatch.elapsed < timeout) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      stopwatch.stop();
      
      if (!_isInitialized) {
        debugPrint('⚠️ AuthProvider: Initialization timeout');
        return null;
      }
    }
    
    debugPrint('✅ AuthProvider: Authentication ready - UID: ${_user?.uid ?? "null"}');
    return _user;
  }
}
