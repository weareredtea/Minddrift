// lib/screens/dice_roll_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wavelength_clone_fresh/screens/dialog_helpers.dart';
import 'dart:async'; // For Timer

import '../services/firebase_service.dart';
import '../models/round.dart'; // Import Round and Effect enum
import '../widgets/effect_card.dart';
import '../l10n/app_localizations.dart';
// Import for PlayerStatus
// Import for navigating back to home
// Import for navigating to scoreboard

class DiceRollScreen extends StatefulWidget {
  static const routeName = '/dice_roll';
  final String roomId;
  const DiceRollScreen({super.key, required this.roomId});

  @override
  State<DiceRollScreen> createState() => _DiceRollScreenState();
}

class _DiceRollScreenState extends State<DiceRollScreen> {
  Timer? _timer;
  bool _animationComplete = false; // To control initial animation state
  bool _navigatedAway = false; // Prevent multiple navigations
  bool _showingLastPlayerDialog = false; // Flag for last player dialog

  @override
  void initState() {
    super.initState();
    // This listener will initiate the timer once the effectRolledAt timestamp appears
    // and handle the navigation.
    context.read<FirebaseService>().listenCurrentRound(widget.roomId).listen((round) {
      if (round.effectRolledAt != null && !_navigatedAway) {
        // Calculate remaining time
        final serverTime = DateTime.now(); // This assumes client time is reasonably close to server time
        final timeElapsed = serverTime.difference(round.effectRolledAt!);
        const duration = Duration(seconds: 5);
        final remainingDuration = duration - timeElapsed;

        if (remainingDuration.isNegative) {
          // If already past 3 seconds, navigate immediately
          _triggerTransition();
        } else {
          // If still within 3 seconds, set a timer for the remaining time
          setState(() {
            _animationComplete = true; // Show the final effect
          });
          _timer?.cancel(); // Cancel any existing timer
          _timer = Timer(remainingDuration, () {
            _triggerTransition();
          });
        }
      }
    });

    // Listen for player departures to show toast messages
    context.read<FirebaseService>().listenForPlayerDepartures(widget.roomId).listen((playerName) {
      if (playerName != null && mounted) {
        final loc = AppLocalizations.of(context);
        if (loc != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.playerExited(playerName)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });

    // Listen for last player standing scenario
    context.read<FirebaseService>().listenToLastPlayerStatus(widget.roomId).listen((status) {
      final onlinePlayerCount = status['onlinePlayerCount'] as int;
      final isLastPlayer = status['isLastPlayer'] as bool;
      final currentUserDisplayName = status['currentUserDisplayName'] as String;

      if (isLastPlayer && onlinePlayerCount == 1 && !_showingLastPlayerDialog && mounted) {
        setState(() {
          _showingLastPlayerDialog = true;
        });
        showLastPlayerDialog(context, currentUserDisplayName, widget.roomId);
      } else if (!isLastPlayer && onlinePlayerCount > 1 && _showingLastPlayerDialog) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  void _triggerTransition() {
    if (!_navigatedAway) {
      setState(() {
        _navigatedAway = true;
      });
      // Call FirebaseService to update room status, which RoomNavigator will pick up
      context.read<FirebaseService>().transitionAfterDiceRoll(widget.roomId);
    }
  }

  // Helper to get a string representation of the effect
  String _getEffectDescription(Effect? effect) {
    switch (effect) {
      case Effect.doubleScore:
        return 'Double Score!';
      case Effect.halfScore:
        return 'Half Score!';
      case Effect.token:
        return 'Navigator gets a Token!';
      case Effect.reverseSlider:
        return 'Reverse Slider!';
      case Effect.noClue:
        return 'No Clue!';
      case Effect.blindGuess:
        return 'Blind Guess!';
      case Effect.none:
      default:
        return 'No Special Effect';
    }
  }


  

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
              backgroundColor: Colors.black.withValues(alpha: 0.7), // Semi-transparent overlay
      appBar: AppBar( // Added AppBar
        backgroundColor: Colors.transparent, // Transparent to blend with overlay
        elevation: 0, // No shadow
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white), // White icon for contrast
            onPressed: () => showExitConfirmationDialog(context, widget.roomId),
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder<Round>(
          stream: fb.listenCurrentRound(widget.roomId),
          builder: (ctx, snap) {
            if (!snap.hasData || snap.data!.effect == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  Text(
                    loc.rollingTheDice,
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              );
            }

            final rolledEffect = snap.data!.effect!;
            final effectDescription = _getEffectDescription(rolledEffect);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_animationComplete) // Simple animation placeholder
                  Text(
                    '🎲', // Dice emoji as a placeholder for animation
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 100),
                  ),
                if (_animationComplete) // Show final effect after "animation"
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.casino, size: 60, color: Colors.deepOrange),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 300,
                          child: EffectCard(
                            effect: rolledEffect,
                            customDescription: effectDescription,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rolledEffect == Effect.none ? '' : '(Round Score will be affected)',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
