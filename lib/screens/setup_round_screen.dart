import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/widgets/radial_spectrum.dart';
import 'package:minddrift/widgets/spectrum_card.dart';
import 'package:minddrift/widgets/effect_card.dart';
import 'package:minddrift/widgets/keyboard_aware_scroll_view.dart';
// Import for DocumentSnapshot

import '../services/firebase_service.dart';
import '../services/category_service.dart'; // Import CategoryService for localization
import '../models/round.dart'; // Import Round model for category data
import '../theme/app_theme.dart'; // Import for AppColors
// Import for PlayerStatus
import 'home_screen.dart'; // Import for navigating back to home
import 'scoreboard_screen.dart'; // Import for navigating to scoreboard
import '../l10n/app_localizations.dart';

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
        final loc = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(loc.youAreLastPlayer),
          content: Text(loc.lastPlayerMessage),
          actions: <Widget>[
            TextButton(
              child: Text(loc.inviteFriends),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() { _showingLastPlayerDialog = false; });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.shareRoomId(roomId))),
                );
              },
            ),
            TextButton(
              child: Text(loc.viewScoreboard),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() { _showingLastPlayerDialog = false; });
                Navigator.pushNamed(context, ScoreboardScreen.routeName, arguments: roomId);
              },
            ),
            TextButton(
              child: Text(loc.exitToHome),
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
        final loc = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(loc.exitGame),
          content: Text(loc.exitGameConfirmation),
          actions: <Widget>[
            TextButton(
              child: Text(loc.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(loc.exit),
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



  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final loc = AppLocalizations.of(context)!;
    final roomId = widget.roomId;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.setupRoundTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _showExitConfirmationDialog(context, roomId),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false, // Don't add bottom safe area, we'll handle it manually
        child: StreamBuilder<Round>(
        stream: fb.listenCurrentRound(roomId),
        builder: (ctx, snap) {
          if (!snap.hasData || snap.data!.secretPosition == null || snap.data!.categoryLeft == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final currentRound = snap.data!;
          final secretPos = currentRound.secretPosition!.toDouble();
                          final categoryId = currentRound.categoryId ?? '';
                final categoryLeft = CategoryService.getLocalizedCategoryText(context, categoryId, true);
                final categoryRight = CategoryService.getLocalizedCategoryText(context, categoryId, false);
          final effect = currentRound.effect; // Get the effect

          // Apply 'No Clue' effect if active
          final isNoClueEffect = effect == Effect.noClue;

          return KeyboardAwareColumn(
            padding: const EdgeInsets.all(16),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                // Role explanation card
                Card(
                  child: ListTile(
                    leading: Icon(Icons.explore_rounded, color: AppColors.accent, size: 32),
                    title: Text(
                      loc.youAreNavigator,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      loc.navigatorDescription,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  loc.secretPositionSet,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),

                // Display active effect if any
                if (effect != null && effect != Effect.none)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: EffectCard(effect: effect),
                  ),

                // *** REPLACE WITH RadialSpectrum ***
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SpectrumCard(
                    startLabel: categoryLeft,
                    endLabel: categoryRight,
                    child: RadialSpectrumWidget(
                      value: secretPos,
                      secretValue: secretPos, // Show the secret position
                      onChanged: (_) {}, // No-op, it's read-only
                      isReadOnly: true,
                    ),
                  ),
                ),

                // Clue input (disabled if 'No Clue' effect)
                TextField(
                  decoration: InputDecoration(
                    labelText: isNoClueEffect ? loc.clueDisabledByEffect : loc.oneWordClue,
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.purpleAccent[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 16),

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
                        isNoClueEffect ? loc.confirmNoClue : loc.submitClue,
                        style: Theme.of(context).textTheme.labelLarge,
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
