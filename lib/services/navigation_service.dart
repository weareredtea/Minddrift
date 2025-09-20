// lib/services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../screens/home_screen.dart';

class NavigationService {
  /// Navigates to the HomeScreen, completely clearing the navigation stack.
  /// This is the standard way to exit a game room.
  Future<void> exitRoomAndNavigateToHome(BuildContext context, String roomId) async {
    // It's crucial to read FirebaseService here, inside the method,
    // to ensure we have the correct context.
    final firebaseService = context.read<FirebaseService>();
    
    try {
      await firebaseService.leaveRoom(roomId);
    } catch (e) {
      // Log the error but proceed with navigation to avoid getting stuck.
      print('Error leaving room: $e');
    }

    // Check if the widget's context is still valid before navigating.
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
