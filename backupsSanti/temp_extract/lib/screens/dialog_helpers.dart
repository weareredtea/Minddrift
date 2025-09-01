import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../screens/home_screen.dart';
import '../screens/scoreboard_screen.dart';

/// Shows a confirmation dialog for exiting the current room.
Future<void> showExitConfirmationDialog(BuildContext context, String roomId) async {
  final fb = context.read<FirebaseService>();
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text('Are you sure you want to exit this room? Other players will be notified.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Exit'),
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
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      final fb = context.read<FirebaseService>();
      return AlertDialog(
        title: const Text('You are the Last Player!'),
        content: Text('All other players have exited the room. You can invite other players, view the total score, or exit.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Invite Friends'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share room ID: $roomId')),
              );
            },
          ),
          TextButton(
            child: const Text('View Scoreboard'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.pushNamed(context, ScoreboardScreen.routeName, arguments: roomId);
            },
          ),
          TextButton(
            child: const Text('Exit to Home'),
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