// lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wavelength_clone_fresh/screens/dialog_helpers.dart';
import 'package:wavelength_clone_fresh/services/audio_service.dart';
import 'package:wavelength_clone_fresh/widgets/result_animations.dart';
import 'package:wavelength_clone_fresh/widgets/radial_spectrum.dart';
import 'package:wavelength_clone_fresh/widgets/spectrum_card.dart';
import 'package:wavelength_clone_fresh/widgets/bundle_indicator.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../models/player_status.dart';
import '../models/round.dart';
import '../l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.roundResultTitle),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(loc.howScoringWorks),
                  content: Text(loc.scoringExplanation),
                  actions: [
                    TextButton(
                        child: Text(loc.gotIt),
                        onPressed: () => Navigator.of(ctx).pop()),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () => showExitConfirmationDialog(context, widget.roomId),
          ),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: Rx.combineLatest3(
          fb.listenCurrentRound(widget.roomId),
          fb.roomDocRef(widget.roomId).snapshots(),
          fb.listenNavigator(widget.roomId),
          (Round r, DocumentSnapshot<Map<String, dynamic>> rs, PlayerStatus? nav) => [r, rs.data() ?? {}, nav],
        ),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting || !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentRound = snap.data![0] as Round;
          final roomData = snap.data![1] as Map<String, dynamic>;
          final navigator = snap.data![2] as PlayerStatus?;

          if (currentRound.secretPosition == null || currentRound.groupGuessPosition == null || navigator == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final secret = currentRound.secretPosition!;
          final guess = currentRound.groupGuessPosition!;
          final score = currentRound.score ?? 0;
          final currentRoundNumber = roomData['currentRoundNumber'] as int? ?? 0;

          if (!_hasPlayedScoreSound) {
            if (score >= 4) { _audioService.playCheerSound(); } 
            else { _audioService.playScoreSound(score); }
            _hasPlayedScoreSound = true;
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      loc.roundResults(currentRoundNumber),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.navigatorWas(navigator.displayName),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    
                    // Bundle indicator
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: fb.roomDocRef(widget.roomId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.data() != null) {
                          final selectedBundle = snapshot.data!.data()!['selectedBundle'] as String?;
                          if (selectedBundle != null) {
                            return BundleIndicator(
                              categoryId: selectedBundle,
                              showIcon: true,
                              showLabel: true,
                              size: 14,
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    const Spacer(),

                    SpectrumCard(
                      startLabel: currentRound.categoryLeft ?? 'LEFT',
                      endLabel: currentRound.categoryRight ?? 'RIGHT',
                      child: RadialSpectrumWidget(
                        value: guess.toDouble(),
                        secretValue: secret.toDouble(), // Pass the secret as the second value
                        onChanged: (_) {},
                        isReadOnly: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    const Spacer(flex: 2),
                    
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                        );
                      },
                      child: Column(
                        children: [
                            Text(loc.score, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                            '$score',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.accent, fontSize: 64),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              
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
    final loc = AppLocalizations.of(context)!;

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
                    child: Text(me.ready ? loc.ready : (isMatchEnd ? loc.readyForSummary : loc.readyForNextRound)),
                  ),

                    if (me.ready && !allReady)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          loc.waitingForOtherPlayersToGetReady,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
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
                        backgroundColor: AppColors.primaryVariant,
                        disabledBackgroundColor: AppColors.surface.withOpacity(0.5),
                        disabledForegroundColor: Colors.grey,
                      ),
                      child: Text(allReady ? (isMatchEnd ? loc.showMatchSummary : loc.startNextRound) : loc.waitingForPlayers),
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