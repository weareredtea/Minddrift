// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minddrift/screens/store_screen.dart';
import 'package:minddrift/screens/tutorial_screen.dart';
import 'package:minddrift/screens/settings_screen.dart';

import '../services/firebase_service.dart';
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
import '../models/avatar.dart';
import '../models/custom_username.dart';

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
  
  // User profile state
  String _userAvatarId = 'bear'; // Default avatar
  String _username = 'MindDrifter'; // Default username

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
    _loadUserProfile();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await WalletService.getWallet();
      if (mounted) {
        setState(() {
          _wallet = wallet;
        });
      }
      
      // Initialize quests in background (don't await to avoid blocking UI)
      _initializeQuests();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading wallet: $e');
      }
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
      if (kDebugMode) {
        print('Quests initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing quests: $e');
      }
    }
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Load username from custom_usernames collection
      final usernameQuery = await FirebaseFirestore.instance
          .collection('custom_usernames')
          .where('userId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      String username = 'MindDrifter'; // Default
      if (usernameQuery.docs.isNotEmpty) {
        final customUsername = CustomUsername.fromFirestore(usernameQuery.docs.first);
        username = customUsername.username;
      } else if (user.displayName != null && user.displayName!.isNotEmpty) {
        username = user.displayName!;
      }

      // Load avatar from user document
      final fb = context.read<FirebaseService>();
      final userDoc = await fb.userDocRef(user.uid).get();
      final userData = userDoc.data();
      final avatarId = userData?['avatarId'] as String? ?? 'bear';

      if (mounted) {
        setState(() {
          _username = username;
          _userAvatarId = avatarId;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user profile: $e');
      }
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
                                  } else {
                                    _selectedBundles.remove(bundleId);
                                  }
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
                    child: Text(
                      AppLocalizations.of(context)!.startGame,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                                _error = e.toString();
                                _loading = false;
                              });
                              print('Room creation failed: $e');
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
                                    _error = e.toString();
                                    _loading = false;
                                  });
                                  print('Room join failed: $e');
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
                AppLocalizations.of(context)!.playByYourself,
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
          name: AppLocalizations.of(context)!.unknownBundle,
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }

  // NEW: Widget for the new profile header
  Widget _buildProfileHeader(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
        );
        // Reload profile after returning from edit screen
        _loadUserProfile();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Fit content
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF4A00E0), // Using a theme color
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SvgPicture.asset(
                  Avatars.getPathFromId(_userAvatarId),
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_wallet != null)
                  Row(
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Widget for the bottom navigation bar items
  Widget _buildNavBarItem(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Widget for the whole bottom navigation bar
  Widget _buildBottomNavBar(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 10,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1A).withOpacity(0.85),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(
              context,
              icon: Icons.diamond_outlined,
              label: AppLocalizations.of(context)!.gems,
              color: Colors.amber,
              onTap: () async {
                await Navigator.pushNamed(context, GemStoreScreen.routeName);
                _loadWallet();
              },
            ),
            _buildNavBarItem(
              context,
              icon: Icons.assignment_turned_in_outlined,
              label: AppLocalizations.of(context)!.quests,
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, QuestScreen.routeName),
            ),
            _buildNavBarItem(
              context,
              icon: Icons.store_outlined,
              label: AppLocalizations.of(context)!.store,
              color: Colors.cyan,
              onTap: () => Navigator.pushNamed(context, StoreScreen.routeName),
            ),
            _buildNavBarItem(
              context,
              icon: Icons.settings_outlined,
              label: AppLocalizations.of(context)!.settings,
              color: Colors.grey.shade400,
              onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      // MODIFIED: AppBar removed to use a custom header layout
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // MODIFIED: New custom top bar layout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildProfileHeader(context),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.pushNamed(context, TutorialScreen.routeName),
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
                          const LanguageToggle(),
                        ],
                      ),
                    ],
                  ),
                ),
                // MODIFIED: Expanded to fill remaining space
                Expanded(
                  child: SingleChildScrollView(
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      mobile: 24,
                      tablet: 32,
                      desktop: 48,
                    ).copyWith(bottom: 100), // Added bottom padding to avoid overlap with new nav bar
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // MODIFIED: Reduced top spacing as header provides padding
                        const SizedBox(height: 10),
                        
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
                                        AppLocalizations.of(context)!.playWithFriends,
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
                                      AppLocalizations.of(context)!.playSolo,
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // NEW: The custom bottom navigation bar is placed in the stack
          _buildBottomNavBar(context),
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
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
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