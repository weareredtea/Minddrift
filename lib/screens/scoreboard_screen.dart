// lib/screens/scoreboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/models/round_history_entry.dart';
import 'package:minddrift/screens/dialog_helpers.dart';
import '../services/user_service.dart';
import '../models/round.dart'; // Import for Effect enum
import '../widgets/effect_card.dart';
import '../l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    // Player departure listeners moved to GameStateProvider
    // Listen for player departures to show toast messages
    Stream.value(null).listen((playerName) {
      if (playerName != null && mounted) {
        final loc = AppLocalizations.of(context);
        if (loc != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.playerExited('Player')),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });

    // Last player status listeners moved to GameStateProvider
    // Listen for last player standing scenario
    Stream.value({'onlinePlayerCount': 0, 'isLastPlayer': false}).listen((status) {
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

 
  



  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.scoreboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => showExitConfirmationDialog(context, widget.roomId),
          ),
        ],
      ),
      body: FutureBuilder<List<RoundHistoryEntry>>(
        future: _fetchHistory(widget.roomId),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snap.data ?? [];
          if (history.isEmpty) {
            return Center(child: Text(loc.noRoundsPlayed));
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
                        loc.roundNumber(entry.roundNumber),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(loc.secret(entry.secret?.toString() ?? 'N/A')),
                      Text(loc.groupGuess(entry.guess?.toString() ?? 'N/A')),
                      if (entry.effect != null && entry.effect != Effect.none.toString().split('.').last)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: EffectCard(
                            effect: Round.effectFromString(entry.effect),
                            showIcon: false,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        loc.scorePoints(entry.score ?? 0),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: entry.score! > 0 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.time(entry.timestamp.toLocal().toString().split('.')[0]),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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

  Future<List<RoundHistoryEntry>> _fetchHistory(String roomId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('rounds')
          .doc('current')
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();
      return snap.docs.map((d) => RoundHistoryEntry.fromMap(d.data())).toList();
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }
}
