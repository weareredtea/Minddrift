// lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wavelength_clone_fresh/screens/dialog_helpers.dart';
import 'package:wavelength_clone_fresh/services/audio_service.dart';
import 'package:wavelength_clone_fresh/widgets/result_animations.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../models/player_status.dart';
import '../models/round.dart';

// This is the corrected slider widget from our previous conversations.
class ResultVisualizer extends StatelessWidget {
  final int secretPosition;
  final int guessPosition;

  const ResultVisualizer({
    super.key,
    required this.secretPosition,
    required this.guessPosition,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: CustomPaint(
        painter: ResultVisualizerPainter(
          secretValue: secretPosition.toDouble(),
          guessValue: guessPosition.toDouble(),
        ),
        child: Container(),
      ),
    );
  }
}

class ResultVisualizerPainter extends CustomPainter {
  final double secretValue;
  final double guessValue;

  ResultVisualizerPainter({required this.secretValue, required this.guessValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double trackY = size.height / 2;
    const double trackHeight = 12.0;

    final trackPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, trackY - (trackHeight / 2), size.width, trackHeight),
      const Radius.circular(6),
    );
    canvas.drawRRect(trackRect, trackPaint);

    final secretX = (secretValue / 100).clamp(0.0, 1.0) * size.width;
    final secretPaint = Paint()..color = AppColors.accent;
    canvas.drawCircle(Offset(secretX, trackY), 10, secretPaint);

    final guessX = (guessValue / 100).clamp(0.0, 1.0) * size.width;
    final guessPaint = Paint()
      ..color = AppColors.accentVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(guessX, trackY), 10, guessPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class ResultScreen extends StatefulWidget {
  static const routeName = '/result';
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
    final fb = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Round Results'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () => showExitConfirmationDialog(context, widget.roomId),
          ),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: Rx.combineLatest2(
          fb.listenCurrentRound(widget.roomId),
          fb.roomDocRef(widget.roomId).snapshots(),
          (Round currentRound, DocumentSnapshot<Map<String, dynamic>> roomSnap) {
            final roomData = roomSnap.data() ?? {};
            return [currentRound, roomData];
          },
        ),
        builder: (ctx, snap) {
          // --- MODIFIED: More robust data checks to prevent flicker ---
          if (snap.connectionState == ConnectionState.waiting || !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentRound = snap.data![0] as Round;
          final roomData = snap.data![1] as Map<String, dynamic>;

          // Check for the specific data needed to build this screen.
          // If it's not ready yet, keep showing the loader.
          if (currentRound.secretPosition == null || currentRound.groupGuessPosition == null) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- END OF MODIFICATION ---

          // It is now safe to access the data.
          final secret = currentRound.secretPosition!;
          final guess = currentRound.groupGuessPosition!;
          final score = currentRound.score ?? 0;
          final effect = currentRound.effect;
          final currentRoundNumber = roomData['currentRoundNumber'] as int? ?? 0;
          
          // --- MODIFIED: Sound logic ---
          if (!_hasPlayedScoreSound) {
            if (score == 6) {
              _audioService.playCheerSound(); // Play cheer for bullseye
            } else {
              _audioService.playScoreSound(score); // Play normal score sound
            }
            _hasPlayedScoreSound = true;
          }
          // --- END OF MODIFICATION ---

          String effectDescription = _getEffectDescription(effect);

          // --- MODIFIED: Wrap body in a Stack to show animations ---
          return Stack(
            alignment: Alignment.center,
            children: [
              // Your existing content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      'Round $currentRoundNumber Results',
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    if (effect != Effect.none)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                        child: Text(
                          'Effect: $effectDescription',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.accentVariant),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    const SizedBox(height: 32),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text('Secret was: $secret', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text('Group Guess: $guess', style: Theme.of(context).textTheme.headlineSmall),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    ResultVisualizer(secretPosition: secret, guessPosition: guess),
                    const SizedBox(height: 32),

                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                           Text('SCORE', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                           const SizedBox(height: 4),
                           Text(
                            '$score',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.accent, fontSize: 64),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),

              // --- MODIFIED: Conditionally render animations based on new score tiers ---
              if (score == 6)
                const BullseyeAnimation(),
              if (score == 3 || score == 4)
                const ThumbsUpAnimation(),
              if (score == 1 || score == 2)
                const GentlePoofAnimation(),
              if (score == 0)
                const TumbleweedAnimation(),
            ],
          );
        },
      ),
      bottomNavigationBar: NextRoundControls(roomId: widget.roomId),
    );
  }

  String _getEffectDescription(Effect? effect) {
    switch (effect) {
      case Effect.doubleScore: return 'Double Score!';
      case Effect.halfScore: return 'Half Score!';
      case Effect.token: return 'Navigator gets a Token!';
      case Effect.reverseSlider: return 'Reverse Slider!';
      case Effect.noClue: return 'No Clue!';
      case Effect.blindGuess: return 'Blind Guess!';
      default: return '';
    }
  }
}

class NextRoundControls extends StatefulWidget {
  final String roomId;
  const NextRoundControls({super.key, required this.roomId});

  @override
  State<NextRoundControls> createState() => _NextRoundControlsState();
}

class _NextRoundControlsState extends State<NextRoundControls> {
  bool _hostActionInProgress = false;
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final myUid = fb.currentUserUid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: fb.roomDocRef(widget.roomId).snapshots(),
      builder: (ctx, roomSnap) {
        if (!roomSnap.hasData || roomSnap.data?.data() == null) {
          return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
        }
        final roomData = roomSnap.requireData.data()!;
        final hostUid = roomData['creator'] as String? ?? '';
        final isMatchEnd = (roomData['currentRoundNumber'] as int? ?? 0) >= 5;

        return StreamBuilder<List<PlayerStatus>>(
          stream: fb.listenToReady(widget.roomId),
          builder: (ctx, playersSnap) {
            if (!playersSnap.hasData) {
              return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
            }
            final players = playersSnap.requireData;
            final allReady = players.every((p) => p.ready);
            final me = players.firstWhere(
              (p) => p.uid == myUid,
              orElse: () => PlayerStatus(
                uid: myUid,
                displayName: 'You',
                ready: false,
                online: true,
                avatarId: 'bear'
              ),);

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: me.ready ? null : () {
                      _audioService.playTapSound();
                      fb.setReady(widget.roomId, true);
                    },
                    style: me.ready 
                        ? ElevatedButton.styleFrom(backgroundColor: AppColors.surface) 
                        : null,
                    child: Text(me.ready ? 'Ready!' : (isMatchEnd ? 'Ready for Summary' : 'Ready for Next Round')),
                  ),

                  if (myUid == hostUid) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: allReady && !_hostActionInProgress
                          ? () async {
                            _audioService.playTapSound();
                              setState(() => _hostActionInProgress = true);
                              await fb.incrementRoundAndReset(widget.roomId);
                              if (mounted) {
                                setState(() => _hostActionInProgress = false);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentVariant,
                        disabledBackgroundColor: AppColors.surface.withOpacity(0.5),
                        disabledForegroundColor: Colors.grey,
                      ),
                      child: Text(allReady ? (isMatchEnd ? 'Show Match Summary' : 'Start Next Round') : 'Waiting for players...'),
                    ),
                  ],

                  if (myUid != hostUid && allReady)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Waiting for host to continue...',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}