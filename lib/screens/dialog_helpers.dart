import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../screens/home_screen.dart';
import '../screens/scoreboard_screen.dart';
import '../l10n/app_localizations.dart';

/// Shows a confirmation dialog for exiting the current room.
Future<void> showExitConfirmationDialog(BuildContext context, String roomId) async {
  final fb = context.read<FirebaseService>();
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
            onPressed: () async {
              await fb.leaveRoom(roomId);
              // Safely pop the dialog before navigating
              Navigator.of(dialogContext).pop();
              // Navigate all the way back to the home screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}

/// Shows a dialog informing the user they are the last one left in the room.
Future<void> showLastPlayerDialog(BuildContext context, String displayName, String roomId) async {
  final loc = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      final fb = context.read<FirebaseService>();
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
            onPressed: () async {
              await fb.leaveRoom(roomId);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}