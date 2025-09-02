// lib/screens/guess_round_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minddrift/widgets/radial_spectrum.dart';
import 'package:minddrift/widgets/spectrum_card.dart';
import 'package:minddrift/widgets/effect_card.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../services/category_service.dart'; // Import CategoryService for localization
import '../models/player_status.dart';
import '../models/round.dart';
import 'dialog_helpers.dart';
import 'package:rxdart/rxdart.dart';
import '../l10n/app_localizations.dart';


class GuessRoundScreen extends StatefulWidget {
  final String roomId;
  const GuessRoundScreen({super.key, required this.roomId});

  @override
  State<GuessRoundScreen> createState() => _GuessRoundScreenState();
}

class _GuessRoundScreenState extends State<GuessRoundScreen> {
  // Performance optimization: Cache data to avoid unnecessary rebuilds
  Round? _cachedRound;
  List<PlayerStatus>? _cachedPlayers;
  int? _cachedGroupGuess;

  String _getLocalizedRole(String role) {
    final loc = AppLocalizations.of(context);
    if (loc == null) return role;
    
    switch (role.toLowerCase()) {
      case 'navigator':
        return loc.youAreNavigator;
      case 'seeker':
        return loc.youAreGuesser;
      case 'saboteur':
        return loc.youAreSaboteur;
      default:
        return role;
    }
  }



  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final uid = fb.currentUserUid;
    final roomId = widget.roomId;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.seekersMakeGuess),
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
          
          // Performance optimization: Cache round data
          _cachedRound = snap.data!;
          final currentRound = _cachedRound!;
          final clue = currentRound.clue!;
          final categoryId = currentRound.categoryId ?? '';
          final categoryLeft = CategoryService.getLocalizedCategoryText(context, categoryId, true);
          final categoryRight = CategoryService.getLocalizedCategoryText(context, categoryId, false);
          final effect = currentRound.effect;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Role explanation card
                StreamBuilder<Role>(
                  stream: fb.listenMyRole(roomId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final role = snapshot.data!;
                    String titleText = loc.youAreGuesser;
                    String subtitleText = loc.seekerDescription;
                    IconData roleIcon = Icons.search_rounded;
                    if (role == Role.Saboteur) {
                      titleText = loc.youAreSaboteur;
                      subtitleText = loc.saboteurDescription;
                      roleIcon = Icons.remove_red_eye_rounded;
                    }
                    return Card(
                      child: ListTile(
                        leading: Icon(roleIcon, color: AppColors.accent, size: 32),
                        title: Text(titleText, 
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(subtitleText,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                
                // Effect display
                if (effect != null && effect != Effect.none)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: EffectCard(effect: effect),
                  ),

                // Performance optimization: Combined slider and player status in one StreamBuilder
                Expanded(
                  child: StreamBuilder<List<dynamic>>(
                    stream: Rx.combineLatest2(
                      fb.listenGroupGuess(roomId),
                      fb.listenGuessReady(roomId),
                      (int groupGuess, List<PlayerStatus> players) => [groupGuess, players],
                    ),
                    builder: (ctx, combinedSnap) {
                      if (!combinedSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      // Performance optimization: Cache combined data
                      _cachedGroupGuess = combinedSnap.data![0] as int;
                      _cachedPlayers = combinedSnap.data![1] as List<PlayerStatus>;
                      
                      final pos = _cachedGroupGuess!.toDouble();
                      final players = _cachedPlayers!;
                                             final myRole = currentRound.roles?[uid];
                       final isReverseSliderEffect = effect == Effect.reverseSlider;
                      final displayPos = isReverseSliderEffect ? (100 - pos) : pos;

                      // Sort players once
                      final sortedPlayers = List<PlayerStatus>.from(players)
                        ..sort((a, b) => a.displayName.compareTo(b.displayName));

                      final me = sortedPlayers.firstWhere(
                        (p) => p.uid == uid,
                        orElse: () => PlayerStatus(
                          uid: uid,
                          displayName: 'You',
                          ready: false,
                          online: true,
                          guessReady: false,
                          avatarId: 'bear'
                        ),
                      );

                      return Column(
                        children: [
                          // Shared radial spectrum
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: SpectrumCard(
                              clue: clue,
                              startLabel: categoryLeft,
                              endLabel: categoryRight,
                              child: RadialSpectrumWidget(
                                value: displayPos,
                                onChanged: (v) => fb.updateGroupGuess(
                                      roomId,
                                      isReverseSliderEffect ? (100 - v) : v,
                                    ),
                                isReadOnly: myRole == Role.Navigator,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Seekers ready list + toggle button
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView(
                                    children: sortedPlayers.map((p) {
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
                          p.displayName + (p.role != null ? ' (${_getLocalizedRole(p.role!)}' : ''),
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
                                      child: Text(me.guessReady ? loc.cancel : loc.confirmGroupGuess),
                                    ),
                                  ),
                                
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
                                // Add bottom padding to ensure buttons are above system navigation
                                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                              ],
                            ),
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
