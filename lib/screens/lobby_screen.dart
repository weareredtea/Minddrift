// lib/screens/lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase_service.dart';
import '../pigeon/pigeon.dart';
import 'ready_screen.dart';
import '../l10n/app_localizations.dart';

class LobbyScreen extends StatelessWidget {
  static const routeName = '/lobby';
  final String roomId;
  const LobbyScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.lobby)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(loc.roomCode,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).hintColor)),
            const SizedBox(height: 4),
            Text(roomId,
                style:
                    Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),

            // --- Player List ---
            FutureBuilder<List<PigeonUserDetails>>(
              future: fb.fetchPlayers(roomId),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Text(loc.error(snap.error.toString()));
                }
                final players = snap.data!;
                if (players.isEmpty) {
                  return Text(loc.waitingForPlayersToJoin);
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (_, i) {
                      final u = players[i];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(u.displayName),
                        subtitle: Text(loc.uid(u.uid)),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // --- Proceed to Ready phase ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadyScreen(roomId: roomId),
                    ),
                  );
                },
                child: Text(loc.imHereLetsGetReady),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
