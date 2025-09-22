// lib/screens/guess_round_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/providers/game_state_provider.dart';
import 'package:minddrift/widgets/unified_spectrum.dart';
import 'package:minddrift/widgets/global_chat_overlay.dart';
import '../l10n/app_localizations.dart';
import '../services/category_service.dart';
import '../services/navigation_service.dart';

class GuessRoundScreen extends StatelessWidget {
  final String roomId;
  const GuessRoundScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    // --- STEP 1: Get everything from the provider ---
    final gameProvider = context.watch<GameStateProvider>();
    final gameState = gameProvider.state;
    final loc = AppLocalizations.of(context)!;

    final currentRound = gameState.currentRound;
    final myRole = gameState.myPlayerStatus?.role;
    final isNavigator = myRole == 'Navigator';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.seekersMakeGuess),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () => context.read<NavigationService>().exitRoomAndNavigateToHome(context, roomId),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('${AppLocalizations.of(context)!.clue}: ${currentRound.clue ?? '...'}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    elevation: 8,
                    color: const Color(0xFF1A1A2E), // New unified dark background
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: UnifiedSpectrum(
                        startLabel: CategoryService.getLocalizedCategoryText(context, currentRound.categoryId ?? '', true),
                        endLabel: CategoryService.getLocalizedCategoryText(context, currentRound.categoryId ?? '', false),
                        value: (currentRound.groupGuessPosition ?? 50).toDouble(),
                        // The navigator can see the secret value, others cannot.
                        secretValue: isNavigator ? (currentRound.secretPosition ?? 50).toDouble() : null,
                        // The navigator cannot change the guess.
                        isReadOnly: isNavigator,
                        onChanged: (newValue) {
                          // Action: Call the provider method to update the guess.
                          gameProvider.updateGroupGuess(newValue);
                        },
                        showClue: false, // Clue is shown separately above the spectrum
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // The host sees a button to finalize the round when ready.
                if (gameState.isHost)
                  ElevatedButton(
                    // This could be tied to a new state property like `allSeekersReady`
                    onPressed: () => gameProvider.finalizeRound(),
                    child: Text(AppLocalizations.of(context)!.finalizeRound),
                  ),
              ],
            ),
          ),
          GlobalChatOverlay(roomId: roomId, roomName: 'Room $roomId'),
        ],
      ),
    );
  }
}