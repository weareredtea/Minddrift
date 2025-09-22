// lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/providers/game_state_provider.dart';
import 'package:minddrift/services/audio_service.dart';
import 'package:minddrift/widgets/bundle_indicator.dart';
import 'package:minddrift/widgets/global_chat_overlay.dart';
import 'package:minddrift/widgets/unified_spectrum.dart';
import 'package:minddrift/widgets/result_animations.dart';
import '../l10n/app_localizations.dart';
import '../services/category_service.dart';
import '../services/navigation_service.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatefulWidget {
  final String roomId;
  const ResultScreen({super.key, required this.roomId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AudioService _audioService = AudioService();
  bool _hasPlayedScoreSound = false;

  @override
  Widget build(BuildContext context) {
    // --- STEP 1: Get the state and provider ---
    // No more StreamBuilders! Just a simple watch.
    final gameState = context.watch<GameStateProvider>().state;
    final loc = AppLocalizations.of(context)!;

    // Extract data directly from the unified state object
    final currentRound = gameState.currentRound;
    final players = gameState.players;
    final navigator = players.firstWhere(
      (p) => p.role == 'Navigator',
      orElse: () => players.first,
    );

    // --- STEP 2: Handle one-time effects ---
    // Logic for playing a sound only once when the score appears.
    final score = currentRound.score ?? 0;
    if (!_hasPlayedScoreSound && score > 0) {
      if (score >= 4) {
        _audioService.playCheerSound();
      } else {
        _audioService.playScoreSound(score);
      }
      _hasPlayedScoreSound = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.roundResultTitle),
        automaticallyImplyLeading: false,
        actions: [
          // This dialog can be simplified later if we move its logic into the provider
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () { /* ... scoring explanation dialog ... */ },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              // Dialogs now call the NavigationService for a clean exit
              context.read<NavigationService>().exitRoomAndNavigateToHome(context, widget.roomId);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- STEP 3: Build the UI from the state object ---
          // No more checking for connection state or null data here.
          // The UI is built directly and cleanly from the GameState.
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      loc.navigatorWas(navigator.displayName),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    BundleIndicator(
                      categoryId: gameState.currentRound.categoryId ?? 'bundle.free',
                      showIcon: true,
                      showLabel: true,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 8,
                      color: const Color(0xFF1A1A2E), // New unified dark background
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: UnifiedSpectrum(
                          startLabel: CategoryService.getLocalizedCategoryText(context, currentRound.categoryId ?? '', true),
                          endLabel: CategoryService.getLocalizedCategoryText(context, currentRound.categoryId ?? '', false),
                          value: (currentRound.groupGuessPosition ?? 50).toDouble(),
                          secretValue: (currentRound.secretPosition ?? 50).toDouble(),
                          onChanged: (_) {},
                          isReadOnly: true,
                          showClue: false, // Result screen doesn't show clue in spectrum
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text('$score', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.accent, fontSize: 48)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Conditional animations based on score
              if (score == 6) const BullseyeAnimation(),
              if (score >= 3 && score <= 4) const ThumbsUpAnimation(),
              if (score >= 1 && score <= 2) const GentlePoofAnimation(),
              if (score == 0) const TumbleweedAnimation(),
            ],
          ),
          GlobalChatOverlay(roomId: widget.roomId, roomName: 'Room ${widget.roomId}'),
        ],
      ),
      // --- STEP 4: Pass the state to the controls widget ---
      // The controls are now simpler and receive all data they need.
      bottomNavigationBar: NextRoundControls(roomId: widget.roomId),
    );
  }
}

// --- REFACTORED CONTROLS WIDGET ---
class NextRoundControls extends StatelessWidget {
  final String roomId;
  const NextRoundControls({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    // Get the provider for actions and the state for building the UI
    final gameProvider = context.watch<GameStateProvider>();
    final gameState = gameProvider.state;
    final loc = AppLocalizations.of(context)!;

    // Find the current player's status from the unified state
    final me = gameState.myPlayerStatus;
    if (me == null) {
      return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
    }

    final isMatchEnd = (gameState.currentRound.roundNumber ?? 0) >= 5;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            // --- ACTION: Call the provider method ---
            onPressed: me.ready ? null : () => gameProvider.setReady(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: me.ready ? AppColors.surface : AppColors.primary,
            ),
            child: Text(me.ready ? loc.ready : (isMatchEnd ? loc.readyForSummary : loc.readyForNextRound)),
          ),
          if (me.ready && !gameState.allPlayersReady)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                loc.waitingForOtherPlayersToGetReady,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          if (gameState.isHost) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              // --- ACTION: Call the provider method ---
              onPressed: gameState.allPlayersReady ? () => gameProvider.incrementRoundAndReset() : null,
              child: Text(isMatchEnd ? loc.showMatchSummary : loc.startNextRound),
            ),
          ],
        ],
      ),
    );
  }
}