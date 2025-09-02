// lib/screens/ready_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/services/audio_service.dart';
import 'package:minddrift/services/test_bot_service.dart';
import 'package:minddrift/widgets/skeleton_loader.dart';
import '../models/avatar.dart';
import '../models/player_status.dart';
import '../screens/dialog_helpers.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';

import '../l10n/app_localizations.dart';

class ReadyScreen extends StatefulWidget {
  static const routeName = '/ready';
  final String roomId;
  const ReadyScreen({super.key, required this.roomId});

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen> {
  final AudioService _audioService = AudioService();
  bool _isAddingBot = false;

  /// Check if the add bot button should be shown
  /// Only show for emulator and debug versions
  bool get _shouldShowAddBotButton {
    // Always show in debug mode
    if (kDebugMode) {
      print('🔧 Debug mode detected - showing add bot button');
      return true;
    }
    
    // Check if running on emulator
    final isEmulator = _isEmulator();
    print('🤖 Emulator detection: $isEmulator - Add bot button ${isEmulator ? 'visible' : 'hidden'}');
    return isEmulator;
  }

  /// Detect if running on emulator
  bool _isEmulator() {
    try {
      // Check for common emulator indicators
      final androidInfo = Platform.operatingSystemVersion;
      final deviceInfo = Platform.operatingSystem;
      
      print('🔍 Platform detection - OS: $deviceInfo, Version: $androidInfo');
      
      // Common emulator indicators
      if (deviceInfo == 'android') {
        final isEmulator = androidInfo.contains('sdk') || 
                           androidInfo.contains('google_sdk') ||
                           androidInfo.contains('emulator') ||
                           androidInfo.contains('test-keys') ||
                           androidInfo.contains('generic');
        print('🤖 Android emulator detection: $isEmulator');
        return isEmulator;
      }
      
      // For iOS simulator
      if (deviceInfo == 'ios') {
        final isSimulator = androidInfo.contains('simulator') || 
                           androidInfo.contains('x86_64') ||
                           androidInfo.contains('Darwin');
        print('🍎 iOS simulator detection: $isSimulator');
        return isSimulator;
      }
      
      print('❓ Unknown platform: $deviceInfo');
      return false;
    } catch (e) {
      // If Platform detection fails, assume it's a real device
      print('⚠️ Platform detection failed: $e - assuming real device');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Only start music if it's enabled in settings
    if (_audioService.isMusicEnabled()) {
      _audioService.startMusic();
    }
  }

  @override
  void dispose() {
    // Only stop music if it's actually playing
    if (_audioService.isMusicPlaying()) {
      _audioService.stopMusic();
    }
    super.dispose();
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
          // Add Bot Button - Only show for emulator and debug versions
          if (_shouldShowAddBotButton)
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: _isAddingBot 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.smart_toy_outlined),
              label: Text(_isAddingBot ? 'Adding...' : loc.addBot),
              onPressed: _isAddingBot ? null : () async {
                setState(() {
                  _isAddingBot = true;
                });
                
                try {
                  await fb.addBotToRoom(widget.roomId);
                  TestBotService.start(widget.roomId, fb);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🤖 Bot added successfully!'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Failed to add bot: $e'),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() {
                    _isAddingBot = false;
                  });
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () {
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
          final players = viewModel.players;
          final me = viewModel.me;

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height - 
                                MediaQuery.of(context).padding.top - 
                                kToolbarHeight - 120, // Account for app bar, bottom controls, and safe areas
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(loc.roomCode, style: textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SelectableText(widget.roomId, style: textTheme.displayMedium),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: widget.roomId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(loc.roomCodeCopied),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, color: Colors.white70),
                              tooltip: loc.copyRoomCode,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white12,
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
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
                        const Spacer(), // Push content to top
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom controls - always accessible
              ReadyScreenControls(
                roomId: widget.roomId,
                viewModel: viewModel,
                fb: fb,
              ),
            ],
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
                        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.8), shape: BoxShape.circle),
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

class ReadyScreenControls extends StatefulWidget {
  final String roomId;
  final ReadyScreenViewModel viewModel;
  final FirebaseService fb;
  
  const ReadyScreenControls({
    super.key,
    required this.roomId,
    required this.viewModel,
    required this.fb,
  });

  @override
  State<ReadyScreenControls> createState() => _ReadyScreenControlsState();
}

class _ReadyScreenControlsState extends State<ReadyScreenControls> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final me = widget.viewModel.me;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (me != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.fb.setReady(widget.roomId, !me.ready);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: me.ready ? AppColors.surface : AppColors.accent,
                ),
                child: Text(me.ready ? loc.cancelReady : loc.imReady),
              ),
            ),
          const SizedBox(height: 16),
          if (widget.viewModel.isHost)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.viewModel.allPlayersReady
                    ? () {
                        HapticFeedback.heavyImpact();
                        widget.fb.startRound(widget.roomId);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.surface.withOpacity(0.5),
                  disabledForegroundColor: Colors.grey,
                ),
                child: Text(widget.viewModel.allPlayersReady ? loc.allReadyStartRound : loc.waitingForPlayers),
              ),
            ),
          if (!widget.viewModel.isHost && !widget.viewModel.allPlayersReady)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(loc.waitingForPlayersToGetReady, style: textTheme.labelMedium),
            ),
          if (!widget.viewModel.isHost && widget.viewModel.allPlayersReady)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(loc.allReadyWaitingForHost, style: textTheme.labelMedium?.copyWith(color: AppColors.accent)),
            ),
        ],
      ),
    );
  }
}
