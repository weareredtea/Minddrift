// lib/screens/match_summary_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:minddrift/providers/game_state_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/navigation_service.dart';
import '../theme/app_theme.dart';

class MatchSummaryScreen extends StatefulWidget {
  final String roomId;
  const MatchSummaryScreen({super.key, required this.roomId});

  @override
  State<MatchSummaryScreen> createState() => _MatchSummaryScreenState();
}

class _MatchSummaryScreenState extends State<MatchSummaryScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    // Play confetti as soon as the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _getGroupPerformance(int totalScore, AppLocalizations loc) {
    if (totalScore >= 28) return 'Mind Readers!';
    if (totalScore >= 24) return 'Incredible!';
    if (totalScore >= 20) return 'Great Job!';
    if (totalScore >= 15) return 'Good Effort!';
    return 'Try Again!';
  }

  @override
  Widget build(BuildContext context) {
    // --- Get state and services ---
    final gameState = context.watch<GameStateProvider>().state;
    final navService = context.read<NavigationService>();
    final loc = AppLocalizations.of(context)!;

    final players = gameState.players;
    final totalGroupScore = 0; // TODO: Add totalGroupScore to Round model or calculate from rounds
    final groupPerformance = _getGroupPerformance(totalGroupScore, loc);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.matchSummaryTitle),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(loc.finalScore, style: Theme.of(context).textTheme.displayMedium),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text('$totalGroupScore', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.accent)),
                        Text(groupPerformance, style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(player.displayName),
                          trailing: const Text('💎 0'), // TODO: Add tokens to PlayerStatus model
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () => navService.exitRoomAndNavigateToHome(context, widget.roomId),
              child: Text(loc.returnToHome),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
          ),
        ],
      ),
    );
  }
}