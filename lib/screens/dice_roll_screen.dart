// lib/screens/dice_roll_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/providers/game_state_provider.dart';
import 'package:minddrift/widgets/effect_card.dart';
import '../l10n/app_localizations.dart';
import '../services/navigation_service.dart';

class DiceRollScreen extends StatelessWidget {
  final String roomId;
  const DiceRollScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    // --- Get state and provider ---
    final gameProvider = context.watch<GameStateProvider>();
    final gameState = gameProvider.state;
    final loc = AppLocalizations.of(context)!;

    final rolledEffect = gameState.currentRound.effect;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => context.read<NavigationService>().exitRoomAndNavigateToHome(context, roomId),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (rolledEffect == null)
              Column(
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  Text(loc.rollingTheDice, style: Theme.of(context).textTheme.headlineSmall),
                ],
              )
            else
              EffectCard(effect: rolledEffect),

            const SizedBox(height: 40),

            // Host sees a button to continue to the next phase.
            // This is more reliable than a client-side timer.
            if (gameState.isHost)
              ElevatedButton(
                onPressed: () => gameProvider.transitionAfterDiceRoll(),
                child: Text(loc.continueButton),
              )
            else
              Text(loc.waitingForHostToContinue, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}