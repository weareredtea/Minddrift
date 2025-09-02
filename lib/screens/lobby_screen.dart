// lib/screens/lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase_service.dart';
import '../pigeon/pigeon.dart';
import 'ready_screen.dart';
import '../widgets/bundle_indicator.dart';
import '../widgets/language_toggle.dart';
import '../services/category_service.dart';
import '../l10n/app_localizations.dart';

class LobbyScreen extends StatelessWidget {
  static const routeName = '/lobby';
  final String roomId;
  const LobbyScreen({super.key, required this.roomId});

  BundleInfo _getBundleInfo(String bundleId) {
    switch (bundleId) {
      case 'bundle.free':
        return BundleInfo(
          name: 'Free Bundle',
          color: Colors.green,
          icon: Icons.free_breakfast,
        );
      case 'bundle.horror':
        return BundleInfo(
          name: 'Horror Bundle',
          color: Colors.red,
          icon: Icons.psychology,
        );
      case 'bundle.kids':
        return BundleInfo(
          name: 'Kids Bundle',
          color: Colors.orange,
          icon: Icons.child_care,
        );
      case 'bundle.food':
        return BundleInfo(
          name: 'Food Bundle',
          color: Colors.brown,
          icon: Icons.restaurant,
        );
      case 'bundle.nature':
        return BundleInfo(
          name: 'Nature Bundle',
          color: Colors.green,
          icon: Icons.eco,
        );
      case 'bundle.fantasy':
        return BundleInfo(
          name: 'Fantasy Bundle',
          color: Colors.purple,
          icon: Icons.auto_awesome,
        );
      default:
        return BundleInfo(
          name: 'Unknown Bundle',
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.lobby),
        actions: [
          // Language Toggle Button
          const LanguageToggle(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(loc.roomCode,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).hintColor)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  roomId,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: roomId));
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
            const SizedBox(height: 16),
            
            // Bundle indicator
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: fb.roomDocRef(roomId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  final selectedBundle = snapshot.data!.data()!['selectedBundle'] as String?;
                  if (selectedBundle != null) {
                    final bundleInfo = _getBundleInfo(selectedBundle);
                    final categories = CategoryService.getCategoriesByBundle(selectedBundle);
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bundleInfo.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: bundleInfo.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BundleIndicator(
                            categoryId: selectedBundle,
                            showIcon: true,
                            showLabel: false,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${bundleInfo.name} • ${categories.length} categories',
                            style: TextStyle(
                              color: bundleInfo.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),

            // --- Player List ---
            FutureBuilder<List<PigeonUserDetails>>(
              future: fb.fetchPlayers(roomId),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Text(loc.error(snap.error.toString()));
                }
                final players = snap.data!;
                if (players.isEmpty) {
                  return Text(loc.waitingForPlayersToJoin);
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (_, i) {
                      final u = players[i];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(u.displayName),
                        subtitle: Text(loc.uid(u.uid)),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // --- Proceed to Ready phase ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadyScreen(roomId: roomId),
                    ),
                  );
                },
                child: Text(loc.imHereLetsGetReady),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
