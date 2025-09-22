import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/widgets/radial_spectrum.dart';
import 'package:minddrift/widgets/spectrum_card.dart';
import 'package:minddrift/widgets/effect_card.dart';
import 'package:minddrift/widgets/keyboard_aware_scroll_view.dart';
// Import for DocumentSnapshot

import '../providers/game_state_provider.dart';
import '../services/category_service.dart'; // Import CategoryService for localization
import '../models/round.dart'; // Import Round model for category data
import '../theme/app_theme.dart'; // Import for AppColors
// Import for PlayerStatus
import 'home_screen.dart'; // Import for navigating back to home
import '../l10n/app_localizations.dart';
import '../widgets/global_chat_overlay.dart';

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

  @override
  void initState() {
    super.initState();
    // Player listeners are now handled by GameStateProvider
  }

  Future<void> _showExitConfirmationDialog(BuildContext context, String roomId) async {
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
                // Leave room functionality is now handled by NavigationService
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
    final gameState = context.watch<GameStateProvider>().state;
    final gameProvider = context.read<GameStateProvider>();
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
      body: Stack(
        children: [
          SafeArea(
            bottom: false, // Don't add bottom safe area, we'll handle it manually
            child: Builder(
              builder: (ctx) {
                // Check if we have the essential round data
                final currentRound = gameState.currentRound;
                if (currentRound.secretPosition == null || 
                    currentRound.categoryLeft == null || 
                    currentRound.categoryId == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(AppLocalizations.of(context)!.settingUpRound, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }
                final secretPos = currentRound.secretPosition!.toDouble();
                final categoryId = currentRound.categoryId!; // We already checked it's not null
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
                          await gameProvider.submitClue(
                              secretPos.round(), isNoClueEffect ? '' : _clue);
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
          // Global Chat Overlay
          GlobalChatOverlay(
            roomId: widget.roomId,
            roomName: 'Room ${widget.roomId}',
          ),
        ],
      ),
    );
  }
}
