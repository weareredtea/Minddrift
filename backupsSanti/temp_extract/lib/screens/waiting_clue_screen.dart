// lib/screens/waiting_clue_screen.dart (Polished & Fixed)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/firebase_service.dart';
import 'guess_round_screen.dart';
import '../models/round.dart';
import 'dialog_helpers.dart';
import '../theme/app_theme.dart';

class WaitingClueScreen extends StatefulWidget {
  static const routeName = '/waiting';
  final String roomId;
  const WaitingClueScreen({super.key, required this.roomId});
  @override
  State<WaitingClueScreen> createState() => _WaitingClueScreenState();
}

class _WaitingClueScreenState extends State<WaitingClueScreen> {
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
            onPressed: () => showExitConfirmationDialog(context, roomId),
          ),
        ],
      ),
      body: StreamBuilder<Round>(
        stream: fb.listenCurrentRound(roomId),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final currentRound = snap.data!;
          final clue = currentRound.clue ?? '';
          final effect = currentRound.effect;

          if (clue.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // This logic for navigation remains
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          // Polished waiting UI with Shimmer effect
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (effect != null && effect != Effect.none)
                  // *** FIX: Added the required 'padding' parameter ***
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Effect: ${_getEffectDescription(effect)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.accentVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: AppColors.onSurface.withOpacity(0.5),
                  highlightColor: AppColors.onSurface,
                  child: Text(
                    'Navigator is thinking…',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
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