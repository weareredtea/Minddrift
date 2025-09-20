// lib/widgets/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../screens/home_screen.dart';

/// Authentication gate that ensures the user is authenticated before
/// allowing access to the main application.
/// 
/// This widget implements the "Auth Gate" pattern to prevent race conditions
/// and ensure all services have a valid user ID before they start.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Initialize authentication when the gate is shown
    // Use a slight delay to avoid immediate rebuild loops
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        final authProvider = context.read<app_auth.AuthProvider>();
        authProvider.initializeAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint('🔐 AuthGate: Building with state - Initialized: ${authProvider.isInitialized}, Loading: ${authProvider.isLoading}, Authenticated: ${authProvider.isAuthenticated}');
        
        // Show loading screen while authentication is in progress
        if (authProvider.isLoading || !authProvider.isInitialized) {
          return const AuthLoadingScreen();
        }
        
        // If user is authenticated, proceed to the main app
        if (authProvider.isAuthenticated) {
          debugPrint('✅ AuthGate: User authenticated, proceeding to HomeScreen');
          return const HomeScreen();
        }
        
        // If no user is authenticated, show the anonymous sign-in screen
        debugPrint('🔐 AuthGate: No user authenticated, showing sign-in screen');
        return const AnonymousSignInScreen();
      },
    );
  }
}

/// Loading screen shown while authentication is in progress
class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game logo or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4A00E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            
            // Loading text
            const Text(
              'Connecting...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            const Text(
              'Setting up your game session',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen shown when attempting anonymous sign-in
class AnonymousSignInScreen extends StatefulWidget {
  const AnonymousSignInScreen({super.key});

  @override
  State<AnonymousSignInScreen> createState() => _AnonymousSignInScreenState();
}

class _AnonymousSignInScreenState extends State<AnonymousSignInScreen> {
  bool _isSigningIn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Automatically attempt anonymous sign-in
    _attemptSignIn();
  }

  Future<void> _attemptSignIn() async {
    if (_isSigningIn) return;
    
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    final authProvider = context.read<app_auth.AuthProvider>();
    final success = await authProvider.signInAnonymously();
    
    if (!success && mounted) {
      setState(() {
        _isSigningIn = false;
        _errorMessage = 'Failed to connect. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A00E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Welcome to MindDrift',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                'The ultimate party game of perception and guessing',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Loading indicator or error message
              if (_isSigningIn) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Setting up your session...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ] else if (_errorMessage != null) ...[
                // Error message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Retry button
                ElevatedButton(
                  onPressed: _attemptSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A00E0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
