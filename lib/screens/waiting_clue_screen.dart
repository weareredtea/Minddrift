// lib/screens/waiting_clue_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/providers/game_state_provider.dart';
import 'package:minddrift/widgets/pulsating_avatar.dart';
import '../l10n/app_localizations.dart';
import '../services/navigation_service.dart';

class WaitingClueScreen extends StatelessWidget {
  final String roomId;
  const WaitingClueScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final gameState = context.watch<GameStateProvider>().state;
    final navigatorPlayer = gameState.players.where((p) => p.role == 'Navigator').toList();
    final nav = navigatorPlayer.isNotEmpty ? navigatorPlayer.first : (gameState.players.isNotEmpty ? gameState.players.first : null);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.read<NavigationService>().exitRoomAndNavigateToHome(context, roomId),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (nav != null) ...[
              PulsatingAvatar(avatarId: nav.avatarId),
              const SizedBox(height: 24),
              Text(
                loc.waitingForPlayer(nav.displayName),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.theyAreSubmittingClue,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(loc.waitingForNavigator, style: Theme.of(context).textTheme.headlineSmall),
            ]
          ],
        ),
      ),
    );
  }
}