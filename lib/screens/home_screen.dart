// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:wavelength_clone_fresh/screens/store_screen.dart';
import 'package:wavelength_clone_fresh/screens/tutorial_screen.dart';
import 'package:wavelength_clone_fresh/screens/settings_screen.dart';

import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/bundle_indicator.dart';
import '../widgets/language_toggle.dart';
import '../services/category_service.dart';
import '../providers/purchase_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/keyboard_aware_scroll_view.dart';
// import '../providers/premium_provider.dart'; // Temporarily disabled
// import '../screens/premium_screen.dart'; // Temporarily disabled
import '../l10n/app_localizations.dart';


class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({super.key});

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

  Future<String?> _showBundleSelectionDialog() async {
    final loc = AppLocalizations.of(context)!;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<PurchaseProvider>(
          builder: (context, purchaseProvider, child) {
            final ownedBundles = purchaseProvider.ownedBundles;
            
            return AlertDialog(
              title: Text(
                loc.selectBundleForGame,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.grey[900],
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.selectBundleDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                    if (ownedBundles.length <= 1) ...[
                      Container(
                        padding: ResponsiveHelper.getResponsivePadding(context, mobile: 12, tablet: 16, desktop: 20),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.store, color: Colors.purple, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loc.getMoreBundlesMessage,
                                style: TextStyle(
                                  color: Colors.purple.shade200,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                    ],
                    ...ownedBundles.map((bundleId) {
                      final bundleInfo = _getBundleInfo(bundleId);
                      final categories = CategoryService.getCategoriesByBundle(bundleId);
                      
                      return ListTile(
                        leading: BundleIndicator(
                          categoryId: bundleId,
                          showIcon: true,
                          showLabel: false,
                          size: 20,
                        ),
                        title: Text(
                          bundleInfo.name,
                          style: TextStyle(
                            color: bundleInfo.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${categories.length} categories',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        onTap: () => Navigator.of(context).pop(bundleId),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(loc.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushNamed(context, StoreScreen.routeName); // Navigate to store
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(loc.getBundles),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
          // Language Toggle Button
          const LanguageToggle(),
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
          // Premium button temporarily hidden
          // Consumer<PremiumProvider>(
          //   builder: (context, premium, child) {
          //     return IconButton(
          //       icon: Icon(
          //         premium.isPremium ? Icons.star : Icons.star_border,
          //         color: premium.isPremium ? Colors.amber : Colors.white,
          //       ),
          //       onPressed: () => Navigator.pushNamed(context, PremiumScreen.routeName),
          //       tooltip: premium.isPremium ? 'Premium Active' : 'Upgrade to Premium',
          //     );
          //   },
          // ),
          // Test button - only show in debug mode
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.science, color: Colors.orange),
              onPressed: () =>
                  Navigator.pushNamed(context, '/wave-spectrum-test'),
              tooltip: 'Test Wave Spectrum (Debug Only)',
            ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            bottom: false, // Don't add bottom safe area, we'll handle it manually
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxH = constraints.maxHeight;
                return KeyboardAwareScrollView(
                  padding: ResponsiveHelper.getResponsivePadding(context, mobile: 24, tablet: 32, desktop: 48),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: maxH),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.zero,
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
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white, fontSize: 38,
                                // Use Oi font for Arabic title only
                                fontFamily: Localizations.localeOf(context).languageCode == 'ar' 
                                    ? 'Oi' 
                                    : null,
                              ),
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
                                          String? selectedBundle;
                                          try {
                                            selectedBundle = await _showBundleSelectionDialog();
                                            if (selectedBundle != null) {
                                              final settings = await fb
                                                  .fetchRoomCreationSettings();
                                              await fb.createRoom(
                                                settings['saboteurEnabled'] ??
                                                    false,
                                                settings['diceRollEnabled'] ??
                                                    false,
                                                selectedBundle,
                                              );
                                            } else {
                                              setState(() => _loading = false);
                                            }
                                          } catch (e) {
                                            setState(() {
                                              _error = ExceptionHandler.getUserFriendlyMessage(e);
                                              _loading = false;
                                            });
                                            
                                            // Log detailed error for developers
                                            ExceptionHandler.logError('home_screen_create_room', 'Room creation failed in UI', 
                                              extraData: {
                                                'error': ExceptionHandler.getDeveloperMessage(e),
                                                'bundle': selectedBundle ?? 'unknown',
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
                                              _error = ExceptionHandler.getUserFriendlyMessage(e);
                                              _loading = false;
                                            });
                                            
                                            // Log detailed error for developers
                                            ExceptionHandler.logError('home_screen_join_room', 'Room join failed in UI', 
                                              extraData: {
                                                'error': ExceptionHandler.getDeveloperMessage(e),
                                                'roomCode': code,
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