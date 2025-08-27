// lib/screens/ready_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wavelength_clone_fresh/services/audio_service.dart';
import 'package:wavelength_clone_fresh/services/test_bot_service.dart';
import 'package:wavelength_clone_fresh/widgets/skeleton_loader.dart';
import '../models/avatar.dart';
import '../models/player_status.dart';
import '../screens/dialog_helpers.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';

// *** CONVERTED TO STATEFULWIDGET to track player count for sounds ***
class ReadyScreen extends StatefulWidget {
  static const routeName = '/ready';
  final String roomId;
  const ReadyScreen({super.key, required this.roomId});

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}
  // In lib/screens/ready_screen.dart

class _ReadyScreenState extends State<ReadyScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final AudioService _audioService = AudioService();
  
  // This list will now be correctly managed to drive the AnimatedList
  final List<PlayerStatus> _players = [];

  @override
  void initState() {
    super.initState();
    _audioService.startMusic();
  }

  @override
  void dispose() {
    _audioService.stopMusic();
    // We no longer manage the bot service here, so its dispose call is removed.
    super.dispose();
  }

  // --- NEW: Helper function to build the exit animation ---
  Widget _buildRemovedItem(PlayerStatus player, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: PlayerLobbyCard(player: player),
      ),
    );
  }
  
  // --- NEW: Helper function to calculate changes and update the list ---
  void _updateList(List<PlayerStatus> newList) {
    // This function runs after the widget tree has been built for the frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // --- Handle Removals ---
      // Loop backwards to safely remove items from the list
      for (int i = _players.length - 1; i >= 0; i--) {
        final oldPlayer = _players[i];
        // If an old player is NOT in the new list, remove them
        if (!newList.any((p) => p.uid == oldPlayer.uid)) {
          _players.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => _buildRemovedItem(oldPlayer, animation),
            duration: const Duration(milliseconds: 400),
          );
        }
      }

      // --- Handle Additions ---
      for (int i = 0; i < newList.length; i++) {
        final newPlayer = newList[i];
        // If a new player is NOT in the old list, add them
        if (!_players.any((p) => p.uid == newPlayer.uid)) {
          _players.insert(i, newPlayer);
          _listKey.currentState?.insertItem(
            i,
            duration: const Duration(milliseconds: 400),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.gameLobby),
        automaticallyImplyLeading: false,
        actions: [
          // Language Toggle Button
          const LanguageToggle(),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.smart_toy_outlined),
            label: Text(loc.addBot),
            onPressed: () {
              fb.addBotToRoom(widget.roomId);
              TestBotService.start(widget.roomId, fb);
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              _audioService.playTapSound();
              showExitConfirmationDialog(context, widget.roomId);
            },
          ),
        ],
      ),
      body: StreamBuilder<ReadyScreenViewModel>(
        stream: fb.listenToReadyScreenViewModel(widget.roomId),
        builder: (ctx, vmSnap) {
          if (!vmSnap.hasData) {
            return const _ReadySkeleton();
          }
          final viewModel = vmSnap.data!;
          final newPlayerList = viewModel.players;
          final me = viewModel.me;

          // Play sounds based on count change
          if (newPlayerList.length > _players.length) {
            _audioService.playPlayerJoinSound();
          } else if (newPlayerList.length < _players.length) {
            _audioService.playPlayerLeaveSound();
          }

          // --- MODIFIED: Call the new update function ---
          _updateList(newPlayerList);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(loc.roomCode, style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                SelectableText(widget.roomId, style: textTheme.displayMedium),
                const SizedBox(height: 24),
                
                // --- MODIFIED: The AnimatedList now works correctly ---
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: _players.length,
                    itemBuilder: (context, index, animation) {
                      final player = _players[index];
                      // Build the entrance animation
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                        child: PlayerLobbyCard(player: player),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (me != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _audioService.playTapSound();
                        HapticFeedback.lightImpact();
                        fb.setReady(widget.roomId, !me.ready);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: me.ready ? AppColors.surface : AppColors.accent,
                      ),
                      child: Text(me.ready ? loc.cancelReady : loc.imReady),
                    ),
                  ),
                const SizedBox(height: 16),
                if (viewModel.isHost)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.allPlayersReady
                          ? () {
                              _audioService.playTapSound();
                              HapticFeedback.heavyImpact();
                              fb.startRound(widget.roomId);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentVariant,
                        disabledBackgroundColor: AppColors.surface.withOpacity(0.5),
                        disabledForegroundColor: Colors.grey,
                      ),
                      child: Text(viewModel.allPlayersReady ? loc.allReadyStartRound : loc.waitingForPlayers),
                    ),
                  ),
                if (!viewModel.isHost && !viewModel.allPlayersReady)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(loc.waitingForPlayersToGetReady, style: textTheme.labelMedium),
                  ),
                if (!viewModel.isHost && viewModel.allPlayersReady)
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(loc.allReadyWaitingForHost, style: textTheme.labelMedium?.copyWith(color: AppColors.accent)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}



class PlayerLobbyCard extends StatelessWidget {
  final PlayerStatus player;
  const PlayerLobbyCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final String svgPath = Avatars.getPathFromId(player.avatarId);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primaryVariant,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgPicture.asset(
                    svgPath,
                    // *** FIX: Removed the colorFilter to allow original SVG colors ***
                    // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: player.ready
                    ? Container(
                        key: const ValueKey('ready'),
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.8), shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, color: Colors.white),
                      )
                    : const SizedBox(key: ValueKey('not_ready')),
              ),
            ],
          ),
        ),
        title: Text(player.displayName, style: Theme.of(context).textTheme.titleLarge),
        trailing: Icon(Icons.circle, size: 12, color: player.online ? AppColors.success : AppColors.error),
      ),
    );
  }
}

class _ReadySkeleton extends StatelessWidget {
  const _ReadySkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SkeletonLoader(width: 200, height: 28),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: SkeletonLoader(width: double.infinity, height: 68),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonLoader(width: double.infinity, height: 50),
          const SizedBox(height: 16),
          const SkeletonLoader(width: double.infinity, height: 50),
        ],
      ),
    );
  }
}
