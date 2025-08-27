// lib/main.dart

import 'dart:io';

import 'package:animations/animations.dart'; // *** NEW: Import animations package ***
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wavelength_clone_fresh/screens/role_reveal_screen.dart';
import 'package:wavelength_clone_fresh/services/audio_service.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'models/round.dart';
import 'screens/home_screen.dart';
import 'screens/ready_screen.dart';
import 'screens/setup_round_screen.dart';
import 'screens/waiting_clue_screen.dart';
import 'screens/guess_round_screen.dart';
import 'screens/result_screen.dart';
import 'screens/match_summary_screen.dart';
import 'screens/dice_roll_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/store_screen.dart';
import 'theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'providers/purchase_provider.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter/foundation.dart'; // Import this to check for debug mode


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// *** NEW: Preload sounds for better performance ***
  await AudioService().preloadSounds(); 
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- FINAL EMULATOR CONFIGURATION BLOCK ---
  if (kDebugMode) {
    try {
      print('DEBUG MODE: Forcing sign out to clear cached token...');
      // THIS IS THE NEW, CRUCIAL LINE:
      await FirebaseAuth.instance.signOut();
      
      print('DEBUG MODE: Connecting to local Firebase Emulators...');
      final String host = Platform.isAndroid ? '10.0.2.2' : 'localhost';

      // Point Auth to the local emulator
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);

      // Point Firestore to the local emulator
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      
      print('Successfully connected to local emulators on host: $host');
    } catch (e) {
      print('Error connecting to local emulators: $e');
    }
  }
  // --- END OF EMULATOR CONFIGURATION BLOCK ---
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
            providers: [
        ChangeNotifierProvider(create: (_) => FirebaseService()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Mind Drift',
            theme: AppTheme.darkTheme, // Use static theme initially
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Theme(
                data: AppTheme.getDarkTheme(context),
                child: const RoomNavigator(),
              ),
            ),
            routes: {
              SettingsScreen.routeName: (_) => Builder(
                builder: (context) => Theme(
                  data: AppTheme.getDarkTheme(context),
                  child: const SettingsScreen(),
                ),
              ),
              '/tutorial': (_) => Builder(
                builder: (context) => Theme(
                  data: AppTheme.getDarkTheme(context),
                  child: const TutorialScreen(),
                ),
              ),
              StoreScreen.routeName: (_) => Builder(
                builder: (context) => Theme(
                  data: AppTheme.getDarkTheme(context),
                  child: const StoreScreen(),
                ),
              ),
            },
          );
        },
      ),
    );
  }
}

class RoomNavigator extends StatelessWidget {
  const RoomNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final fb = context.watch<FirebaseService>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // *** NEW: PageTransitionSwitcher for Auth State ***
        return PageTransitionSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: !authSnapshot.hasData
              ? Builder(
                  builder: (context) => Theme(
                    data: AppTheme.getDarkTheme(context),
                    child: const HomeScreen(key: ValueKey('home')),
                  ),
                )
              : RoomStatusNavigator(key: const ValueKey('room_navigator'), firebaseService: fb),
        );
      },
    );
  }
}

// New widget to handle room status navigation to work with PageTransitionSwitcher
class RoomStatusNavigator extends StatelessWidget {
  final FirebaseService firebaseService;

  const RoomStatusNavigator({
    super.key,
    required this.firebaseService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: firebaseService.listenCurrentUserRoomId(),
      builder: (context, roomSnapshot) {
        final roomId = roomSnapshot.data;
        if (roomId == null) {
          // If user leaves a room, they will see the HomeScreen.
          // PageTransitionSwitcher will handle the animation.
          return Builder(
            builder: (context) => Theme(
              data: AppTheme.getDarkTheme(context),
              child: const HomeScreen(),
            ),
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: firebaseService.roomDocRef(roomId).snapshots(),
          builder: (context, gameSnapshot) {
            if (!gameSnapshot.hasData || !gameSnapshot.data!.exists) {
              return Builder(
                builder: (context) => Theme(
                  data: AppTheme.getDarkTheme(context),
                  child: const HomeScreen(),
                ),
              );
            }

            final roomStatus = gameSnapshot.data!.data()?['status'] as String? ?? 'lobby';

            // *** NEW: PageTransitionSwitcher for Game State ***
            return PageTransitionSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              // The child is determined by the roomStatus
              child: Builder(
                builder: (context) => Theme(
                  data: AppTheme.getDarkTheme(context),
                  child: _buildScreenForStatus(roomStatus, roomId),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper function to return the correct screen widget with a key
  Widget _buildScreenForStatus(String status, String roomId) {
    switch (status) {
      // *** NEW: Add the 'role_reveal' case ***
      case 'role_reveal':
        return RoleRevealScreen(key: const ValueKey('role_reveal'), roomId: roomId);
      case 'lobby':
      case 'ready_phase':
        return ReadyScreen(key: const ValueKey('ready'), roomId: roomId);
      case 'dice_roll':
        return DiceRollScreen(key: const ValueKey('dice'), roomId: roomId);
      case 'clue_submission':
        return StreamBuilder<Role>(
          key: const ValueKey('clue'),
          stream: firebaseService.listenMyRole(roomId),
          builder: (context, roleSnapshot) {
            final myRole = roleSnapshot.data;
            if (myRole == Role.Navigator) {
              return SetupRoundScreen(roomId: roomId);
            } else {
              return WaitingClueScreen(roomId: roomId);
            }
          },
        );
      case 'guessing':
        return GuessRoundScreen(key: const ValueKey('guess'), roomId: roomId);
      case 'round_end':
        return ResultScreen(key: const ValueKey('result'), roomId: roomId);
      case 'match_end':
        return MatchSummaryScreen(key: const ValueKey('summary'), roomId: roomId);
      default:
        return HomeScreen(key: const ValueKey('home_default'));
    }
  }
}
