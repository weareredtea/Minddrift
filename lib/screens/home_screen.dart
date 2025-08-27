// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:wavelength_clone_fresh/screens/store_screen.dart';
import 'package:wavelength_clone_fresh/screens/tutorial_screen.dart';
import 'package:wavelength_clone_fresh/screens/settings_screen.dart';

import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../l10n/app_localizations.dart';


class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _roomCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 4, end: 16).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final fb = context.read<FirebaseService>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 140,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: TextButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, TutorialScreen.routeName),
                icon: const Icon(Icons.school, color: Colors.white),
                            label: Text(
              loc.howToPlay,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, kToolbarHeight),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.store_rounded, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, StoreScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxH = constraints.maxHeight;
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: maxH),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: maxH * 0.10),
                            SizedBox(
                              height: maxH * 0.25,
                              child: Lottie.asset(
                                'assets/animations/brain.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: maxH * 0.02),
                            Text(
                              loc.appTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
                            ),
                            SizedBox(height: maxH * 0.01),
                            Text(
                              loc.homeSubtitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                            ),
                            SizedBox(height: maxH * 0.12),

                            // Create Room button with glow
                            AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) => SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _loading
                                      ? null
                                      : () async {
                                          setState(() => _loading = true);
                                          try {
                                            final settings = await fb
                                                .fetchRoomCreationSettings();
                                            await fb.createRoom(
                                              settings['saboteurEnabled'] ??
                                                  false,
                                              settings['diceRollEnabled'] ??
                                                  false,
                                            );
                                          } catch (e) {
                                            setState(() {
                                              _error =
                                                  loc.errorCreatingRoom(e.toString());
                                              _loading = false;
                                            });
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    elevation: _glowAnimation.value,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Ink(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Color(0xFF4B0082),
                                        Color(0xFF800080),
                                      ]),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12)),
                                    ),
                                    child: Center(
                                      child: _loading && _roomCtrl.text.isEmpty
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : Text(
                                              loc.createRoom,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: maxH * 0.02),
                            Row(
                              children: [
                                const Expanded(
                                    child: Divider(color: Colors.white38)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    loc.or,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white38),
                                  ),
                                ),
                                const Expanded(
                                    child: Divider(color: Colors.white38)),
                              ],
                            ),
                            SizedBox(height: maxH * 0.02),
                            TextField(
                              controller: _roomCtrl,
                              textAlign: TextAlign.center,
                              textCapitalization: TextCapitalization.characters,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: loc.enterCodeHint,
                                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white12,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: maxH * 0.02),
                            AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) => SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _loading
                                      ? null
                                      : () async {
                                          final code = _roomCtrl.text
                                              .trim()
                                              .toUpperCase();
                                          if (code.isEmpty) {
                                            setState(() => _error =
                                                loc.pleaseEnterRoomCode);
                                            return;
                                          }
                                          setState(() => _loading = true);
                                          try {
                                            await fb.joinRoom(code);
                                          } catch (e) {
                                            setState(() {
                                              _error =
                                                  loc.errorJoiningRoom(e.toString());
                                              _loading = false;
                                            });
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    elevation: _glowAnimation.value,
                                    backgroundColor:
                                        const Color(0xFF005F73),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                    child: _loading &&
                                            _roomCtrl.text.isNotEmpty
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                             : Text(
                                            loc.joinRoom,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                  ),
                                ),
                              ),
                            ),),
                            if (_error != null) ...[
                            SizedBox(height: maxH * 0.02),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}