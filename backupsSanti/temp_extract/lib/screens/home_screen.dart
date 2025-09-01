// lib/screens/home_screen.dart (Polished & Complete)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _roomCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final fb = context.read<FirebaseService>();

    return Scaffold(
      // No AppBar for a cleaner, modern look
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Game Title Graphic
              Text(
                'Mind\nDrift',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 80,
                      height: 0.9,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const Spacer(flex: 3),

              // Create Room Button
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        try {
                          final settings = await fb.fetchRoomCreationSettings();
                          await fb.createRoom(
                              settings['saboteurEnabled'] ?? false,
                              settings['diceRollEnabled'] ?? false);
                        } catch (e) {
                          setState(() {
                            _error = "Error creating room: $e";
                            _loading = false;
                          });
                        }
                      },
                child: _loading && _roomCtrl.text.isEmpty
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create New Room'),
              ),
              const SizedBox(height: 24),

              // Join Room Section
              TextField(
                controller: _roomCtrl,
                decoration: const InputDecoration(labelText: 'Enter Room ID'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _loading
                    ? null
                    : () async {
                        if (_roomCtrl.text.trim().isEmpty) {
                          setState(() => _error = "Please enter a room code.");
                          return;
                        }
                        setState(() => _loading = true);
                        try {
                          final code = _roomCtrl.text.trim().toUpperCase();
                          await fb.joinRoom(code);
                        } catch (e) {
                          setState(() {
                            _error = "Error joining room: $e";
                            _loading = false;
                          });
                        }
                      },
                child: _loading && _roomCtrl.text.isNotEmpty
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Join Room'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
      // Settings button floating at the bottom right
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
        backgroundColor: AppColors.surface,
        child: const Icon(Icons.settings_rounded, color: AppColors.onSurface),
      ),
    );
  }
}