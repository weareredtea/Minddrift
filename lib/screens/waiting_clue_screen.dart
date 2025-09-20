// lib/screens/waiting_clue_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/navigation_service.dart';

class WaitingClueScreen extends StatelessWidget {
  final String roomId;
  const WaitingClueScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.read<NavigationService>().exitRoomAndNavigateToHome(context, roomId),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(loc.waitingForNavigator, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}