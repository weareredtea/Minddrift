// lib/screens/ready_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wavelength_clone_fresh/widgets/skeleton_loader.dart';
import '../models/avatar.dart';
import '../models/player_status.dart';
import '../screens/dialog_helpers.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class ReadyScreen extends StatelessWidget {
  static const routeName = '/ready';
  final String roomId;
  const ReadyScreen({super.key, required this.roomId});
  
  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Lobby'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              showExitConfirmationDialog(context, roomId);
            },
          ),
        ],
      ),
      body: StreamBuilder<ReadyScreenViewModel>(
        stream: fb.listenToReadyScreenViewModel(roomId),
        builder: (ctx, vmSnap) {
          if (!vmSnap.hasData) {
            return const _ReadySkeleton();
          }
          final viewModel = vmSnap.data!;
          final players = viewModel.players;
          final me = viewModel.me;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Room Code:', style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                SelectableText(
                  roomId, 
                  style: textTheme.displayMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      return PlayerLobbyCard(player: players[index]);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (me != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        fb.setReady(roomId, !me.ready);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: me.ready ? AppColors.surface : AppColors.accent,
                      ),
                      child: Text(me.ready ? 'Cancel Ready' : 'I\'m Ready'),
                    ),
                  ),
                const SizedBox(height: 16),
                if (viewModel.isHost)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.allPlayersReady
                          ? () {
                              HapticFeedback.heavyImpact();
                              fb.startRound(roomId);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryVariant,
                        disabledBackgroundColor: AppColors.surface.withOpacity(0.5),
                        disabledForegroundColor: Colors.grey,
                      ),
                      child: Text(viewModel.allPlayersReady ? 'All Ready — Start Round' : 'Waiting For Players...'),
                    ),
                  ),
                if (!viewModel.isHost && !viewModel.allPlayersReady)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Waiting for players to get ready...', style: textTheme.labelMedium),
                  ),
                if (!viewModel.isHost && viewModel.allPlayersReady)
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('All ready! Waiting for host to start...', style: textTheme.labelMedium?.copyWith(color: AppColors.accent)),
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
