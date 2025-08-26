// lib/screens/scoreboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wavelength_clone_fresh/models/round_history_entry.dart';
import 'package:wavelength_clone_fresh/screens/dialog_helpers.dart';
import '../services/firebase_service.dart';
import '../models/round.dart'; // Import for Effect enum
// Import for PlayerStatus
// Import for navigating back to home

class ScoreboardScreen extends StatefulWidget { // Changed to StatefulWidget
  static const routeName = '/scoreboard';
  final String roomId;
  const ScoreboardScreen({super.key, required this.roomId});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  bool _showingLastPlayerDialog = false;

  @override
  void initState() {
    super.initState();
    // Listen for player departures to show toast messages
    context.read<FirebaseService>().listenForPlayerDepartures(widget.roomId).listen((playerName) {
      if (playerName != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$playerName has exited the room.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    // Listen for last player standing scenario
    context.read<FirebaseService>().listenToLastPlayerStatus(widget.roomId).listen((status) {
      final onlinePlayerCount = status['onlinePlayerCount'] as int;
      final isLastPlayer = status['isLastPlayer'] as bool;
      final currentUserDisplayName = status['currentUserDisplayName'] as String;

      if (isLastPlayer && onlinePlayerCount == 1 && !_showingLastPlayerDialog && mounted) {
        setState(() {
          _showingLastPlayerDialog = true;
        });
        showLastPlayerDialog(context, currentUserDisplayName, widget.roomId);
      } else if (!isLastPlayer && onlinePlayerCount > 1 && _showingLastPlayerDialog) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

 
  
  // Helper to get effect description
  String _getEffectDescription(String? effectString) {
    if (effectString == null || effectString == Effect.none.toString().split('.').last) {
      return 'No Effect';
    }
    switch (effectString) {
      case 'doubleScore': return 'Double Score!';
      case 'halfScore': return 'Half Score!';
      case 'token': return 'Navigator gets a Token!';
      case 'reverseSlider': return 'Reverse Slider!';
      case 'noClue': return 'No Clue!';
      case 'blindGuess': return 'Blind Guess!';
      default: return 'Unknown Effect';
    }
  }


  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => showExitConfirmationDialog(context, widget.roomId),
          ),
        ],
      ),
      body: FutureBuilder<List<RoundHistoryEntry>>(
        future: fb.fetchHistory(widget.roomId),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snap.data ?? [];
          if (history.isEmpty) {
            return const Center(child: Text('No rounds played yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Round ${entry.roundNumber}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Secret: ${entry.secret ?? 'N/A'}'),
                      Text('Group Guess: ${entry.guess ?? 'N/A'}'),
                      if (entry.effect != null && entry.effect != Effect.none.toString().split('.').last)
                        Text('Effect: ${_getEffectDescription(entry.effect)}', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.deepOrange)),
                      const SizedBox(height: 8),
                      Text(
                        'Score: ${entry.score ?? 0} points',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: entry.score! > 0 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${entry.timestamp.toLocal().toString().split('.')[0]}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
