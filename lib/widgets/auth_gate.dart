// lib/widgets/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../services/firebase_service.dart';
import '../services/room_service.dart';
import '../services/player_service.dart';
import '../screens/lobby_screen.dart';
import '../screens/role_reveal_screen.dart';
import '../screens/dice_roll_screen.dart';
import '../screens/setup_round_screen.dart';
import '../screens/waiting_clue_screen.dart';
import '../screens/guess_round_screen.dart';
import '../screens/result_screen.dart';
import '../screens/match_summary_screen.dart';
import '../models/round.dart';

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
    final roomService = context.watch<RoomService>();

    // The StreamBuilder for FirebaseAuth.instance.authStateChanges() is REMOVED.
    // AuthGate now handles this logic.

    return StreamBuilder<String?>(
      stream: roomService.listenCurrentUserRoomId(),
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

        // --- UPDATED NAVIGATION LOGIC ---
        switch (status) {
          case 'lobby':
            return LobbyScreen(roomId: roomId);
          
          case 'role_reveal':
            return RoleRevealScreen(roomId: roomId);
          
          case 'dice_roll':
            return DiceRollScreen(roomId: roomId);

          case 'clue_submission':
            // Role-based navigation: Navigator gets SetupRoundScreen, Seekers get WaitingClueScreen
            return _RoleBasedNavigator(
              roomId: roomId,
              navigatorScreen: SetupRoundScreen(roomId: roomId),
              seekerScreen: WaitingClueScreen(roomId: roomId),
            );

          case 'guessing':
            // Both Navigator and Seekers get GuessRoundScreen (role logic handled internally)
            return GuessRoundScreen(roomId: roomId);

          case 'round_end':
            return ResultScreen(roomId: roomId);
            
          case 'match_end':
            return MatchSummaryScreen(roomId: roomId);

          default:
            return const HomeScreen();
        }
      },
    );
  }
}

/// Helper widget to handle role-based navigation for clue_submission phase
class _RoleBasedNavigator extends StatelessWidget {
  final String roomId;
  final Widget navigatorScreen;
  final Widget seekerScreen;

  const _RoleBasedNavigator({
    required this.roomId,
    required this.navigatorScreen,
    required this.seekerScreen,
  });

  @override
  Widget build(BuildContext context) {
    final playerService = context.watch<PlayerService>();
    
    return StreamBuilder<Role>(
      stream: playerService.listenMyRole(roomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final myRole = snapshot.data!;
        
        // Navigator gets SetupRoundScreen, Seekers get WaitingClueScreen
        if (myRole == Role.Navigator) {
          return navigatorScreen;
        } else {
          return seekerScreen;
        }
      },
    );
  }
}
