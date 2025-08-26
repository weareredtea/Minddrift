import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wavelength_clone_fresh/widgets/custom_slider_dial.dart';
// Import for DocumentSnapshot

import '../services/firebase_service.dart';
import '../models/round.dart'; // Import Round model for category data
// Import for PlayerStatus
import 'home_screen.dart'; // Import for navigating back to home
import 'scoreboard_screen.dart'; // Import for navigating to scoreboard

class SetupRoundScreen extends StatefulWidget {
  static const routeName = '/setup';
  final String roomId;
  const SetupRoundScreen({super.key, required this.roomId});

  @override
  State<SetupRoundScreen> createState() => _SetupRoundScreenState();
}

class _SetupRoundScreenState extends State<SetupRoundScreen> {
  String _clue = '';
  bool _submitting = false;
  bool _showingLastPlayerDialog = false;

  @override
  void initState() {
    super.initState();
    _setupPlayerListeners();
  }

  void _setupPlayerListeners() {
    // Listen for player departures to show toast messages
    context.read<FirebaseService>().listenForPlayerDepartures(widget.roomId).listen((playerName) {
      if (playerName != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$playerName has exited the room.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    // Listen for last player standing scenario
    context.read<FirebaseService>().listenToLastPlayerStatus(widget.roomId).listen((status) async {
      final onlinePlayerCount = status['onlinePlayerCount'] as int;
      final isLastPlayer = status['isLastPlayer'] as bool;
      final currentUserDisplayName = status['currentUserDisplayName'] as String;
      final roomId = widget.roomId;

      // Get room data to check if current user is creator and it's the very beginning
      final roomSnap = await context.read<FirebaseService>().roomDocRef(roomId).get();
      final roomData = roomSnap.data();
      final isCreator = roomData?['creator'] == context.read<FirebaseService>().currentUserUid;
      final currentRoundNumber = roomData?['currentRoundNumber'] as int? ?? 0;

      // Suppress dialog if creator and it's the very first round (currentRoundNumber is 0 or 1)
      final isInitialRoomCreation = isCreator && currentRoundNumber <= 1; // Adjust based on when roundNumber increments first

      if (isLastPlayer && onlinePlayerCount == 1 && !_showingLastPlayerDialog && mounted && !isInitialRoomCreation) {
        setState(() {
          _showingLastPlayerDialog = true;
        });
        _showLastPlayerDialog(context, currentUserDisplayName, widget.roomId);
      } else if (!isLastPlayer && onlinePlayerCount > 1 && _showingLastPlayerDialog) {
        // If more players join, dismiss the dialog if it's showing
        // Use pop to dismiss a dialog, not popUntil for main navigation
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        setState(() {
          _showingLastPlayerDialog = false;
        });
      }
    });
  }

  Future<void> _showLastPlayerDialog(BuildContext context, String displayName, String roomId) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final fb = dialogContext.read<FirebaseService>();
        return AlertDialog(
          title: const Text('You are the Last Player!'),
          content: Text('All other players have exited the room. You can invite other players, view the total score, or exit.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Invite Friends'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() { _showingLastPlayerDialog = false; });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share room ID: $roomId')),
                );
              },
            ),
            TextButton(
              child: const Text('View Scoreboard'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() { _showingLastPlayerDialog = false; });
                Navigator.pushNamed(context, ScoreboardScreen.routeName, arguments: roomId);
              },
            ),
            TextButton(
              child: const Text('Exit to Home'),
              onPressed: () async {
                await fb.leaveRoom(roomId);
                Navigator.of(dialogContext).pop();
                setState(() { _showingLastPlayerDialog = false; });
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showExitConfirmationDialog(BuildContext context, String roomId) async {
    final fb = context.read<FirebaseService>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Exit Game?'),
          content: const Text('Are you sure you want to exit this room? Other players will be notified.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () async {
                await fb.leaveRoom(roomId);
                Navigator.of(dialogContext).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Helper to get a string representation of the effect
  String _getEffectDescription(Effect? effect) {
    if (effect == null || effect == Effect.none) {
      return '';
    }
    switch (effect) {
      case Effect.doubleScore: return 'Double Score!';
      case Effect.halfScore: return 'Half Score!';
      case Effect.token: return 'Navigator gets a Token!';
      case Effect.reverseSlider: return 'Reverse Slider!';
      case Effect.noClue: return 'No Clue!';
      case Effect.blindGuess: return 'Blind Guess!';
      default: return ''; // Should not happen with exhaustive switch
    }
  }

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final roomId = widget.roomId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigator: Set Your Clue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _showExitConfirmationDialog(context, roomId),
          ),
        ],
      ),
      body: StreamBuilder<Round>(
        stream: fb.listenCurrentRound(roomId),
        builder: (ctx, snap) {
          if (!snap.hasData || snap.data!.secretPosition == null || snap.data!.categoryLeft == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final currentRound = snap.data!;
          final secretPos = currentRound.secretPosition!.toDouble();
          final categoryLeft = currentRound.categoryLeft!;
          final categoryRight = currentRound.categoryRight!;
          final effect = currentRound.effect; // Get the effect
          final effectDescription = _getEffectDescription(effect);

          // Apply 'No Clue' effect if active
          final isNoClueEffect = effect == Effect.noClue;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Your secret position is set — enter your clue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Display active effect if any
                if (effect != null && effect != Effect.none)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Effect: $effectDescription',
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.deepOrange.shade700, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Display category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryLeft,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      categoryRight,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // *** REPLACE SliderDial WITH CustomSliderDial ***
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: CustomSliderDial(
                    value: secretPos,
                    onChanged: (_) {}, // No-op, it's read-only
                    isReadOnly: true,
                  ),
                ),

                // Clue input (disabled if 'No Clue' effect)
                TextField(
                  decoration: InputDecoration(
                    labelText: isNoClueEffect ? 'Clue disabled by effect' : 'One-word clue',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: isNoClueEffect ? null : (v) => setState(() => _clue = v.trim()),
                  enabled: !isNoClueEffect, // Disable if effect is 'No Clue'
                  maxLength: 20, // Optional: Limit clue length
                ),
                if (isNoClueEffect)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Effect active: "No Clue!" - You cannot enter a clue this round.',
                      style: TextStyle(color: Colors.red[700], fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const Spacer(),

                ElevatedButton(
                  onPressed: (_clue.isEmpty && !isNoClueEffect) || _submitting
                      ? null
                      : () async {
                          setState(() => _submitting = true);
                          // If 'No Clue' effect, submit empty clue
                          await fb.submitClue(
                              roomId, secretPos.round(), isNoClueEffect ? '' : _clue);
                          setState(() => _submitting = false);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isNoClueEffect ? 'Confirm No Clue' : 'Lock In Clue',
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
