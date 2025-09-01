// lib/screens/lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase_service.dart';
import '../pigeon/pigeon.dart';
import 'ready_screen.dart';

class LobbyScreen extends StatelessWidget {
  static const routeName = '/lobby';
  final String roomId;
  const LobbyScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Lobby')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Room Code:',
                style:
                    TextStyle(fontSize: 18, color: Theme.of(context).hintColor)),
            const SizedBox(height: 4),
            Text(roomId,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // --- Player List ---
            FutureBuilder<List<PigeonUserDetails>>(
              future: fb.fetchPlayers(roomId),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Text('Error: ${snap.error}');
                }
                final players = snap.data!;
                if (players.isEmpty) {
                  return const Text('Waiting for players to join…');
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (_, i) {
                      final u = players[i];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(u.displayName),
                        subtitle: Text('UID: ${u.uid}'),
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
                child: const Text('I\'m Here—Let’s Get Ready'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
