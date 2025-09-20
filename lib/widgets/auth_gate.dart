// lib/widgets/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../services/firebase_service.dart';
import '../screens/lobby_screen.dart';
import '../screens/ready_screen.dart';
import '../screens/result_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in AuthProvider's status
    final authStatus = context.watch<AuthProvider>().status;

    switch (authStatus) {
      case AuthStatus.authenticated:
        // If authenticated, show the main app content (RoomNavigator)
        return const RoomNavigator();
      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
        // While authenticating or if unauthenticated (before sign-in attempt), show a loading screen
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Connecting...'),
              ],
            ),
          ),
        );
      case AuthStatus.uninitialized:
        // A brief moment before the auth stream provides a value
         return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.error:
        // If an error occurs, show an error screen with a retry button
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Connection Failed',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.watch<AuthProvider>().errorMessage ?? 'An unknown error occurred.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Allow the user to retry the sign-in process
                      context.read<AuthProvider>().signInAnonymously();
                    },
                    child: const Text('Retry'),
                  )
                ],
              ),
            ),
          ),
        );
    }
  }
}

// 4. RoomNavigator no longer needs to check auth state.
// Its only job is to handle navigation based on the user's room status.
class RoomNavigator extends StatelessWidget {
  const RoomNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final fb = context.watch<FirebaseService>();

    // The StreamBuilder for FirebaseAuth.instance.authStateChanges() is REMOVED.
    // AuthGate now handles this logic.

    return StreamBuilder<String?>(
      stream: fb.listenCurrentUserRoomId(),
      builder: (context, roomSnapshot) {
        // ... (the rest of your RoomNavigator and RoomStatusNavigator logic remains the same)
        // This part is already well-structured for handling room state changes.
        final roomId = roomSnapshot.data;
        if (roomId == null) {
          return const HomeScreen();
        }

        return RoomStatusNavigator(roomId: roomId);
      },
    );
  }
}

class RoomStatusNavigator extends StatelessWidget {
  final String roomId;

  const RoomStatusNavigator({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final fb = context.watch<FirebaseService>();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: fb.roomDocRef(roomId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const HomeScreen();
        }

        final roomData = snapshot.data!.data()!;
        final status = roomData['status'] as String? ?? 'lobby';

        switch (status) {
          case 'lobby':
            return LobbyScreen(roomId: roomId);
          case 'ready':
            return ReadyScreen(roomId: roomId);
          case 'playing':
            return const HomeScreen(); // Placeholder - RoundScreen doesn't exist
          case 'result':
            return ResultScreen(roomId: roomId);
          case 'gameOver':
            return const HomeScreen(); // Placeholder - GameOverScreen doesn't exist
          default:
            return const HomeScreen();
        }
      },
    );
  }
}
