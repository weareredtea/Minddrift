import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/navigation_service.dart';
import '../screens/scoreboard_screen.dart';
import '../l10n/app_localizations.dart';

/// Shows a confirmation dialog for exiting the current room.
Future<void> showExitConfirmationDialog(BuildContext context, String roomId) async {
  final navService = context.read<NavigationService>();
  final loc = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(loc.exitGame),
        content: Text(loc.exitGameConfirmation),
        actions: <Widget>[
          TextButton(
            child: Text(loc.cancel),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: Text(loc.exit),
            onPressed: () {
              // Pop the dialog FIRST, then call the navigation service
              Navigator.of(dialogContext).pop();
              navService.exitRoomAndNavigateToHome(context, roomId);
            },
          ),
        ],
      );
    },
  );
}

/// Shows a dialog informing the user they are the last one left in the room.
Future<void> showLastPlayerDialog(BuildContext context, String displayName, String roomId) async {
  final navService = context.read<NavigationService>();
  final loc = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(loc.youAreLastPlayer),
        content: Text(loc.lastPlayerMessage),
        actions: <Widget>[
          TextButton(
            child: Text(loc.inviteFriends),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.shareRoomId(roomId))),
              );
            },
          ),
          TextButton(
            child: Text(loc.viewScoreboard),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.pushNamed(context, ScoreboardScreen.routeName, arguments: roomId);
            },
          ),
          TextButton(
            child: Text(loc.exitToHome),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              navService.exitRoomAndNavigateToHome(context, roomId);
            },
          ),
        ],
      );
    },
  );
}