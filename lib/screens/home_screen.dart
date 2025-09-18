// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:minddrift/screens/store_screen.dart';
import 'package:minddrift/screens/tutorial_screen.dart';
import 'package:minddrift/screens/settings_screen.dart';

import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/bundle_indicator.dart';
import '../widgets/language_toggle.dart';
import '../services/category_service.dart';
import '../providers/purchase_provider_new.dart';
import '../utils/responsive_helper.dart';
// import '../providers/premium_provider.dart'; // Temporarily disabled
// import '../screens/premium_screen.dart'; // Temporarily disabled
import '../l10n/app_localizations.dart';
import 'profile_edit_screen.dart';
import 'practice_mode_screen.dart';
import 'daily_challenge_screen.dart';
import 'campaign_screen.dart';
import 'gem_store_screen.dart';
import 'quest_screen.dart';
import '../services/wallet_service.dart';
import '../services/quest_service.dart';
import '../models/player_wallet.dart';

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

  // Bundle selection state
  Set<String> _selectedBundles = {};
  bool _selectedBundlesInitialized = false;

  // Wallet state
  PlayerWallet? _wallet;

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
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await WalletService.getWallet();
      setState(() {
        _wallet = wallet;
      });
      
      // Initialize quests in background (don't await to avoid blocking UI)
      _initializeQuests();
    } catch (e) {
      print('Error loading wallet: $e');
    }
  }

  Future<void> _initializeQuests() async {
    try {
      // Initialize daily, weekly, and achievement quests
      await Future.wait([
        QuestService.refreshDailyQuests(),
        QuestService.refreshWeeklyQuests(),
        QuestService.initializeAchievementQuests(),
      ]);
      print('Quests initialized successfully');
    } catch (e) {
      print('Error initializing quests: $e');
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<List<String>?> _showBundleSelectionDialog() async {
    final loc = AppLocalizations.of(context)!;
    // Reset selected bundles when opening dialog
    _selectedBundles.clear();
    _selectedBundlesInitialized = false;
    return showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Consumer<PurchaseProviderNew>(
          builder: (context, purchaseProvider, child) {
            final availableBundles = purchaseProvider.availableBundles;

            return StatefulBuilder(
              builder: (context, setState) {
                // Initialize selectedBundles outside the builder to persist state
                if (!_selectedBundlesInitialized) {
                  _selectedBundles = <String>{};
                  _selectedBundlesInitialized = true;
                }

                return AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.selectBundleForGame,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(25),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: ResponsiveHelper.getResponsivePadding(context, mobile: 20, tablet: 24, desktop: 28),
              content: SizedBox(
                width: double.maxFinite,
                height: 400, // Fixed height for scrolling
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.selectBundleDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 1.5),
                    if (availableBundles.length <= 1) ...[
                      Container(
                        padding: ResponsiveHelper.getResponsivePadding(context, mobile: 16, tablet: 20, desktop: 24),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.withAlpha(75)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.store, color: Colors.purple, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.getMoreBundlesMessage,
                                style: TextStyle(
                                  color: Colors.purple.shade200,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 1.5),
                    ],
                    // Scrollable list of bundles
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableBundles.length,
                        itemBuilder: (context, index) {
                          final bundleId = availableBundles.elementAt(index);
                          final bundleInfo = _getBundleInfo(bundleId);
                          final categories = CategoryService.getCategoriesByBundle(bundleId);
                          final isSelected = _selectedBundles.contains(bundleId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                ? bundleInfo.color.withAlpha(50)
                                : Colors.white.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                  ? bundleInfo.color.withAlpha(150)
                                  : Colors.white.withAlpha(25),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: CheckboxListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedBundles.add(bundleId);
                                    print('✅ Selected bundle: $bundleId');
                                  } else {
                                    _selectedBundles.remove(bundleId);
                                    print('❌ Deselected bundle: $bundleId');
                                  }
                                  print('📦 Current selected bundles: $_selectedBundles');
                                });
                              },
                              title: Row(
                                children: [
                                  BundleIndicator(
                                    categoryId: bundleId,
                                    showIcon: true,
                                    showLabel: false,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      bundleInfo.name,
                                      style: TextStyle(
                                        color: bundleInfo.color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${categories.length} ${loc.categories}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              activeColor: bundleInfo.color,
                              checkColor: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Secondary button: Get Bundles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.pushNamed(context, StoreScreen.routeName); // Navigate to store
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      loc.getBundles,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                // Primary button: Start Game
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onPressed: _selectedBundles.isNotEmpty
                      ? () {
                          print('🎮 Starting game with bundles: $_selectedBundles');
                          Navigator.of(context).pop(_selectedBundles.toList()); // Pass all selected bundles
                        }
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedBundles.isNotEmpty
                        ? _getBundleInfo(_selectedBundles.first).color
                        : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showMultiplayerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Play with Friends',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Create Room Button (same UI as current)
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) => SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _loading ? null : () async {
                            Navigator.of(context).pop(); // Close bottom sheet
                            setState(() => _loading = true);
                            List<String>? selectedBundles;
                            try {
                              selectedBundles = await _showBundleSelectionDialog();
                              if (selectedBundles != null && selectedBundles.isNotEmpty) {
                                final settings = await context.read<FirebaseService>().fetchRoomCreationSettings();
                                await context.read<FirebaseService>().createRoom(
                                  settings['saboteurEnabled'] ?? false,
                                  settings['diceRollEnabled'] ?? false,
                                  selectedBundles.first,
                                );
                              } else {
                                setState(() => _loading = false);
                              }
                            } catch (e) {
                              setState(() {
                                _error = ExceptionHandler.getUserFriendlyMessage(e);
                                _loading = false;
                              });
                              ExceptionHandler.logError('home_screen_create_room', 'Room creation failed in UI',
                                  extraData: {'error': ExceptionHandler.getDeveloperMessage(e), 'bundles': selectedBundles?.join(',') ?? 'unknown'});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: _glowAnimation.value,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            child: Center(
                              child: _loading && _roomCtrl.text.isEmpty
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      AppLocalizations.of(context)!.createRoom,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Join Room section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(20))
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _roomCtrl,
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.characters,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, letterSpacing: 2),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.enterCodeHint,
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
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _loading ? null : () async {
                                final code = _roomCtrl.text.trim().toUpperCase();
                                if (code.isEmpty) {
                                  setState(() => _error = AppLocalizations.of(context)!.pleaseEnterRoomCode);
                                  return;
                                }
                                Navigator.of(context).pop(); // Close bottom sheet
                                setState(() => _loading = true);
                                try {
                                  await context.read<FirebaseService>().joinRoom(code);
                                } catch (e) {
                                  setState(() {
                                    _error = ExceptionHandler.getUserFriendlyMessage(e);
                                    _loading = false;
                                  });
                                  ExceptionHandler.logError('home_screen_join_room', 'Room join failed in UI', extraData: {'error': ExceptionHandler.getDeveloperMessage(e), 'roomCode': code});
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF144D52),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Center(
                                child: _loading && _roomCtrl.text.isNotEmpty
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        AppLocalizations.of(context)!.joinRoom,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSoloBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Play by Yourself',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Practice Mode Tile (same UI as current)
                    _buildModeTile(
                      context,
                      AppLocalizations.of(context)!.practiceMode,
                      Icons.fitness_center,
                      Colors.green[600]!,
                      () {
                        Navigator.of(context).pop(); // Close bottom sheet
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PracticeModeScreen()));
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campaign Mode Tile (same UI as current)
                    _buildModeTile(
                      context,
                      AppLocalizations.of(context)!.campaignMode,
                      Icons.military_tech,
                      Colors.deepPurple[700]!,
                      () {
                        Navigator.of(context).pop(); // Close bottom sheet
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CampaignScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BundleInfo _getBundleInfo(String bundleId) {
    final loc = AppLocalizations.of(context)!;

    switch (bundleId) {
      case 'bundle.free':
        return BundleInfo(
          name: loc.freeBundle,
          color: Colors.green,
          icon: Icons.free_breakfast,
        );
      case 'bundle.horror':
        return BundleInfo(
          name: loc.horrorBundle,
          color: Colors.red,
          icon: Icons.psychology,
        );
      case 'bundle.kids':
        return BundleInfo(
          name: loc.kidsBundle,
          color: Colors.orange,
          icon: Icons.child_care,
        );
      case 'bundle.food':
        return BundleInfo(
          name: loc.foodBundle,
          color: Colors.brown,
          icon: Icons.restaurant,
        );
      case 'bundle.nature':
        return BundleInfo(
          name: loc.natureBundle,
          color: Colors.green,
          icon: Icons.eco,
        );
      case 'bundle.fantasy':
        return BundleInfo(
          name: loc.fantasyBundle,
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
          // Gem Balance Display
          if (_wallet != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withAlpha(100)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.diamond, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_wallet!.mindGems}',
                    style: const TextStyle(
                      fontFamily: 'LuckiestGuy',
                      fontSize: 14,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          
          // Language Toggle Button
          const LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.person_rounded, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
            ),
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.diamond, color: Colors.amber),
            onPressed: () async {
              await Navigator.pushNamed(context, GemStoreScreen.routeName);
              _loadWallet(); // Refresh wallet after returning from store
            },
            tooltip: 'Gem Store',
          ),
          IconButton(
            icon: const Icon(Icons.assignment, color: Colors.green),
            onPressed: () => Navigator.pushNamed(context, QuestScreen.routeName),
            tooltip: 'Quests',
          ),
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
          // Test button hidden as requested
        ],
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getResponsivePadding(
                context,
                mobile: 24,
                tablet: 32,
                desktop: 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Main App Logo/Animation
                  SizedBox(
                    height: 150,
                    child: Lottie.asset(
                      'assets/animations/Speedometer.json',
                      fit: BoxFit.contain,
                      animate: true,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 38,
                      fontFamily: Localizations.localeOf(context).languageCode == 'ar'
                          ? 'Oi'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.homeSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 80),

                  // --- Main 3 Buttons ---
                  
                  // 1. Play with Friends Button
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) => SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _showMultiplayerBottomSheet,
                        style: ElevatedButton.styleFrom(
                          elevation: _glowAnimation.value,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Ink(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Play with Friends',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 2. Play Solo Button
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _showSoloBottomSheet,
                      style: ElevatedButton.styleFrom(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF00C851), Color(0xFF007E33)]),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Play Solo',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 3. Daily Challenge Button
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyChallengeScreen())),
                      style: ElevatedButton.styleFrom(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)]),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                loc.dailyChallenge,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  if (_error != null) ...[
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  const SizedBox(height: 40), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 80, // Fixed height for consistency in bottom sheet
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(150)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

class BundleInfo {
  final String name;
  final Color color;
  final IconData icon;

  BundleInfo({required this.name, required this.color, required this.icon});
}