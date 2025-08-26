// lib/screens/waiting_clue_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wavelength_clone_fresh/widgets/pulsating_avatar.dart';
import '../models/avatar.dart';
import '../models/player_status.dart';
import '../services/audio_service.dart';
import '../services/firebase_service.dart';
import '../models/round.dart';
import 'dialog_helpers.dart';
import '../theme/app_theme.dart';
import 'guess_round_screen.dart';

class WaitingClueScreen extends StatefulWidget {
  static const routeName = '/waiting';
  final String roomId;
  const WaitingClueScreen({super.key, required this.roomId});

  @override
  State<WaitingClueScreen> createState() => _WaitingClueScreenState();
}

class _WaitingClueScreenState extends State<WaitingClueScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _audioService.startMusic();
  }

  @override
  void dispose() {
    _audioService.stopMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final roomId = widget.roomId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting for Clue'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              _audioService.playTapSound();
              showExitConfirmationDialog(context, roomId);
            },
          ),
        ],
      ),
      body: StreamBuilder<Round>(
        stream: fb.listenCurrentRound(roomId),
        builder: (ctx, roundSnap) { // *** FIX: Consistently using 'roundSnap' ***
          if (!roundSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clue = roundSnap.data?.clue ?? '';

          if (clue.isNotEmpty) {
            // Auto-navigate to the Guessing Screen once the clue is available.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) { // Check if the widget is still in the tree
                Navigator.pushReplacementNamed(
                  context,
                  GuessRoundScreen.routeName,
                  arguments: roomId,
                );
              }
            });
            // Show a loader while the transition happens.
            return const Center(child: CircularProgressIndicator());
          }

          // Rich presence waiting UI
          return StreamBuilder<PlayerStatus?>(
            stream: fb.listenNavigator(roomId),
            builder: (context, navigatorSnap) {
              final navigator = navigatorSnap.data;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (navigator != null)
                      PulsatingAvatar(avatarId: navigator.avatarId),
                    const SizedBox(height: 24),
                    Shimmer.fromColors(
                      baseColor: AppColors.onSurface.withOpacity(0.6),
                      highlightColor: AppColors.onSurface,
                      child: Text(
                        navigator != null
                            ? '${navigator.displayName} is thinking...'
                            : 'Waiting for Navigator...',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
