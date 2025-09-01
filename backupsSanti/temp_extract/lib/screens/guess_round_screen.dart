// lib/screens/guess_round_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wavelength_clone_fresh/widgets/custom_slider_dial.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../widgets/slider_dial.dart';
import '../models/player_status.dart';
import '../models/round.dart';
import 'dialog_helpers.dart';


class GuessRoundScreen extends StatefulWidget {
  static const routeName = '/guess';
  final String roomId;
  const GuessRoundScreen({super.key, required this.roomId});

  @override
  State<GuessRoundScreen> createState() => _GuessRoundScreenState();
}

class _GuessRoundScreenState extends State<GuessRoundScreen> {
  // Removed dialog-related state as it's handled by the helper

  @override
  void initState() {
    super.initState();
    // Player departure listeners can be added here if needed, but for now
    // the global dialog helper handles the most critical exit cases.
  }

  String _getEffectDescription(Effect? effect) {
    if (effect == null || effect == Effect.none) {
      return '';
    }
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

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final uid = fb.currentUserUid;
    final roomId = widget.roomId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seekers: Make the Guess'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () => showExitConfirmationDialog(context, roomId),
          ),
        ],
      ),
      body: StreamBuilder<Round>(
        stream: fb.listenCurrentRound(roomId),
        builder: (ctx, snap) {
          if (!snap.hasData || snap.data!.clue == null || snap.data!.categoryLeft == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final currentRound = snap.data!;
          final clue = currentRound.clue!;
          final categoryLeft = currentRound.categoryLeft!;
          final categoryRight = currentRound.categoryRight!;
          final effect = currentRound.effect;
          final effectDescription = _getEffectDescription(effect);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Clue and Category display
                Text(
                  'Clue: "$clue"',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                if (effect != Effect.none)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Effect: $effectDescription',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.accentVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(categoryLeft, style: Theme.of(context).textTheme.titleLarge),
                    Text(categoryRight, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 8),

                // Shared slider
                // *** REPLACE SliderDial WITH CustomSliderDial ***
                StreamBuilder<int>(
                  stream: fb.listenGroupGuess(roomId),
                  builder: (ctx, sliderSnap) {
                    final pos = (sliderSnap.data ?? 50).toDouble();
                    final myRole = currentRound.roles?[uid];
                    final isBlindGuessEffect = effect == Effect.blindGuess;
                    final isReverseSliderEffect = effect == Effect.reverseSlider;
                    final displayPos = isReverseSliderEffect ? (100 - pos) : pos;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: CustomSliderDial(
                        value: displayPos,
                        isReadOnly: myRole == Role.Navigator,
                        onChanged: (v) => fb.updateGroupGuess(
                              roomId,
                              isReverseSliderEffect ? (100 - v) : v,
                            ),
                        showValue: !isBlindGuessEffect,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Seekers ready list + toggle button
                Expanded(
                  child: StreamBuilder<List<PlayerStatus>>(
                    stream: fb.listenGuessReady(roomId),
                    builder: (ctx, playersSnap) {
                      if (!playersSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final players = playersSnap.data!;
                      players.sort((a, b) => a.displayName.compareTo(b.displayName));

                      final me = players.firstWhere(
                        (p) => p.uid == uid,
                        // *** FIX: Added avatarId to the orElse fallback ***
                        orElse: () => PlayerStatus(
                          uid: uid,
                          displayName: 'You',
                          ready: false,
                          online: true,
                          guessReady: false,
                          avatarId: 'bear' // Provide a default avatar
                        ),
                      );
                      
                      final myRole = currentRound.roles?[uid];

                      return Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: players.map((p) {
                                // Don't show the Navigator in the "ready" list
                                if (currentRound.roles?[p.uid] == Role.Navigator) {
                                  return const SizedBox.shrink();
                                }
                                return ListTile(
                                  leading: Icon(
                                    p.guessReady
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: p.guessReady ? AppColors.success : null,
                                  ),
                                  title: Text(
                                    p.displayName + (p.role != null ? ' (${p.role})' : ''),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  trailing: Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: p.online ? AppColors.success : AppColors.error,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (myRole != Role.Navigator)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => fb.setGuessReady(roomId, !me.guessReady),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: me.guessReady ? AppColors.surface : AppColors.accent,
                                ),
                                child: Text(me.guessReady ? 'Cancel Guess' : 'Confirm Group Guess'),
                              ),
                            ),
                          const SizedBox(height: 12),
                          // Auto-advance logic for Host
                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: fb.roomDocRef(roomId).snapshots(),
                            builder: (ctx, hostRoomSnap) {
                              if (!hostRoomSnap.hasData) return const SizedBox();
                              final hostUid = hostRoomSnap.requireData.data()?['creator'] as String? ?? '';
                              if (hostUid != uid) return const SizedBox();
                              return StreamBuilder<bool>(
                                stream: fb.listenAllSeekersReady(roomId),
                                builder: (ctx2, allReadySnap) {
                                  if (allReadySnap.data == true) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      final currentRoomStatus = hostRoomSnap.data?.data()?['status'] as String? ?? '';
                                      if (currentRoomStatus == 'guessing') {
                                        fb.finalizeRound(roomId);
                                      }
                                    });
                                  }
                                  return const SizedBox();
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
