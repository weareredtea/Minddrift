// lib/screens/match_summary_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:wavelength_clone_fresh/screens/dialog_helpers.dart';
import '../services/firebase_service.dart';
import '../pigeon/pigeon.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton_loader.dart'; // *** NEW: Import SkeletonLoader ***

class MatchSummaryScreen extends StatefulWidget {
  static const routeName = '/summary';
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
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _getGroupPerformance(int totalScore) {
    if (totalScore >= 25) return 'Incredible';
    if (totalScore >= 21) return 'Awesome';
    if (totalScore >= 10) return 'Okay';
    return 'Bad';
  }

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Summary'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () => showExitConfirmationDialog(context, widget.roomId),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          fb.fetchPlayersWithScores(widget.roomId),
          fb.fetchHistory(widget.roomId),
        ]),
        builder: (ctx, snap) {
          // *** NEW: Show Skeleton Loader while waiting for data ***
          if (snap.connectionState != ConnectionState.done || !snap.hasData) {
            return const _SummarySkeleton();
          }

          final List<PigeonUserDetails> players = snap.data![0];
          
          if (players.isEmpty) {
            return const Center(child: Text('No players found.'));
          }

          players.sort((a, b) => (b.totalScore ?? 0).compareTo(a.totalScore ?? 0));
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _confettiController.play();
          });

          // ... rest of the build method is the same ...
          final totalGroupScore = snap.data![1].fold(0, (sum, entry) => sum + (entry.score ?? 0));
          final groupPerformance = _getGroupPerformance(totalGroupScore);

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Final Scores!', style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('Group Total Score', style: Theme.of(context).textTheme.labelMedium),
                            Text('$totalGroupScore', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.accent)),
                            Text(groupPerformance, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.accentVariant)),
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
                          final isWinner = index == 0;
                          return Card(
                            color: isWinner ? AppColors.primaryVariant : AppColors.surface,
                            child: ListTile(
                              leading: Text(
                                '#${index + 1}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: isWinner ? AppColors.accent : AppColors.onSurface,
                                    ),
                              ),
                              title: Text(player.displayName, style: Theme.of(context).textTheme.titleLarge),
                              trailing: Text(
                                '${player.totalScore ?? 0} pts',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: isWinner ? AppColors.accent : AppColors.onSurface,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (Route<dynamic> route) => false,
                        ),
                        child: const Text('Return to Home'),
                      ),
                    ),
                  ],
                ),
              ),

              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.accent,
                  AppColors.accentVariant,
                  AppColors.primary,
                  Colors.white,
                ],
                gravity: 0.1,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
              ),
            ],
          );
        },
      ),
    );
  }
}

// *** NEW: The skeleton loader layout for this screen ***
class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SkeletonLoader(width: 250, height: 36),
          const SizedBox(height: 24),
          const SkeletonLoader(width: double.infinity, height: 120),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: SkeletonLoader(width: double.infinity, height: 60),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonLoader(width: double.infinity, height: 50),
        ],
      ),
    );
  }
}
