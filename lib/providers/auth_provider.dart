// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enum to represent the authentication status
enum AuthStatus {
  uninitialized,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authStateSubscription;

  // Private state variables
  User? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;

  // Public getters
  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get uid => _user?.uid;

  AuthProvider({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance {
    _initialize();
  }

  /// Initializes the provider and starts listening to auth state changes.
  void _initialize() {
    // Start listening to the auth state stream
    _authStateSubscription = _auth.authStateChanges().listen(
      _onAuthStateChanged,
      onError: (error) {
        print('🚨 Auth State Stream Error: $error');
        _status = AuthStatus.error;
        _errorMessage = 'An unexpected error occurred. Please restart the app.';
        notifyListeners();
      },
    );
  }

  /// Handles auth state changes from the stream.
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      // Automatically try to sign in if the user is logged out
      await signInAnonymously();
    } else {
      _user = user;
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  /// Signs the user in anonymously with retry logic.
  Future<void> signInAnonymously() async {
    if (_status == AuthStatus.authenticating) return;

    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInAnonymously();
      // The stream listener (_onAuthStateChanged) will handle the successful state change
    } on FirebaseAuthException catch (e) {
      print('🚨 Anonymous Sign-In Error: ${e.message}');
      _user = null;
      _status = AuthStatus.error;
      _errorMessage = 'Failed to connect. Please check your internet connection and restart the app.';
      notifyListeners();
    }
  }

  /// Signs the user out.
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
