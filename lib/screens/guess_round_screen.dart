// lib/screens/guess_round_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/providers/game_state_provider.dart';
import 'package:minddrift/models/player_status.dart';
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
    final isNavigator = myRole?.toLowerCase() == 'navigator';
    
    if (kDebugMode) {
      print('🚨 DEBUG: GuessRoundScreen - MyRole: $myRole, IsNavigator: $isNavigator');
      print('🚨 DEBUG: MyPlayerStatus: ${gameState.myPlayerStatus}');
    }

    return Scaffold(
      appBar: AppBar(
        // Role-specific title (use literal to avoid new localization keys)
        title: Text(isNavigator ? 'Observing your team' : loc.seekersMakeGuess),
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('${AppLocalizations.of(context)!.clue}: ${currentRound.clue ?? '...'}', style: Theme.of(context).textTheme.headlineSmall),
                if (isNavigator)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'You are the Navigator. Watch as the Seekers place their guess.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  color: const Color(0xFF1A1A2E), // New unified dark background
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: UnifiedSpectrum(
                      startLabel: CategoryService.getPositiveCategoryText(context, currentRound.categoryId ?? ''),
                      endLabel: CategoryService.getNegativeCategoryText(context, currentRound.categoryId ?? ''),
                      value: (currentRound.groupGuessPosition ?? 50).toDouble(),
                      // The navigator can see the secret value, others cannot.
                      secretValue: isNavigator ? (currentRound.secretPosition ?? 50).toDouble() : null,
                      // The navigator cannot change the guess.
                      isReadOnly: isNavigator,
                      onChanged: isNavigator ? (_) {
                        // Navigator cannot change the guess - no-op
                      } : (newValue) {
                        // Action: Call the provider method to update the guess.
                        gameProvider.updateGroupGuess(newValue);
                      },
                      showClue: false, // Clue is shown separately above the spectrum
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Seekers' Tray
                _buildSeekersTray(context, gameState.players),
                const SizedBox(height: 16),
                // Context-aware action buttons
                _buildActionButtons(context, gameProvider, gameState),
                const SizedBox(height: 20), // Extra padding at bottom for scroll
              ],
            ),
          ),
          GlobalChatOverlay(roomId: roomId, roomName: 'Room $roomId'),
        ],
      ),
    );
  }

  Widget _buildSeekersTray(BuildContext context, List<PlayerStatus> players) {
    final seekers = players.where((p) => p.role == 'Seeker').toList();
    if (seekers.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: seekers.map((seeker) {
          final initial = seeker.displayName.isNotEmpty ? seeker.displayName[0].toUpperCase() : '?';
          final ready = seeker.guessReady;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: Text(
                    initial,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (ready)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameStateProvider gameProvider, dynamic gameState) {
    // --- Get all necessary state variables for clarity ---
    final isHost = gameState.isHost as bool;
    final myStatus = gameState.myPlayerStatus as PlayerStatus?;
    if (myStatus == null) {
      if (kDebugMode) {
        print('🚨 DEBUG: myStatus is null, returning empty widget');
      }
      return const SizedBox.shrink(); // Safety check
    }

    final myRole = myStatus.role;
    final isMeReady = myStatus.guessReady;
    
    if (kDebugMode) {
      print('🚨 DEBUG: Action Buttons - Role: $myRole, IsHost: $isHost, IsMeReady: $isMeReady');
    }

    final seekers = (gameState.players as List<PlayerStatus>).where((p) => p.role?.toLowerCase() == 'seeker').toList();
    final totalSeekers = seekers.length;
    final readySeekersCount = seekers.where((p) => p.guessReady).length;
    final areAllSeekersReady = totalSeekers > 0 && readySeekersCount == totalSeekers;

    // --- Build Widgets Based on Precise Rules ---

    Widget buildSeekerButton() {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            // Toggle ready state through GameStateProvider for consistent state updates
            final gameProvider = context.read<GameStateProvider>();
            gameProvider.setGuessReady(!isMeReady);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isMeReady ? Colors.green[600] : Colors.blue[600],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'I\'m Ready ($readySeekersCount/$totalSeekers)',
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    Widget buildHostButton() {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: areAllSeekersReady ? () => gameProvider.finalizeRound() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[600],
            disabledBackgroundColor: Colors.grey[700],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'View Round Results',
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // --- Return the correct layout based on Role and Host status ---

    if (myRole?.toLowerCase() == 'seeker') {
      if (kDebugMode) {
        print('🚨 DEBUG: Building Seeker buttons - TotalSeekers: $totalSeekers, ReadyCount: $readySeekersCount');
      }
      return Column(
        children: [
          buildSeekerButton(),
          // If the Seeker is ALSO the host, show the host button when everyone is ready.
          if (isHost && areAllSeekersReady) ...[
            const SizedBox(height: 12),
            buildHostButton(),
          ],
        ],
      );
    }

    if (myRole?.toLowerCase() == 'navigator') {
      // The Navigator only sees a button if they are the Host and everyone is ready.
      if (isHost && areAllSeekersReady) {
        return buildHostButton();
      }
      // Otherwise, the Navigator sees no buttons.
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink(); // Fallback
  }
}