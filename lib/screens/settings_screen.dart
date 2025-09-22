// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:minddrift/screens/tutorial_screen.dart';
// Audio service moved to lobby screen
import '../services/user_service.dart';
import '../providers/locale_provider.dart';
import '../providers/purchase_provider_new.dart';
// import '../providers/premium_provider.dart'; // Temporarily disabled
import '../services/category_service.dart';
import '../widgets/bundle_indicator.dart';
import '../l10n/app_localizations.dart';
import 'analytics_dashboard_screen.dart';
import 'spectrum_ui_showcase_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _saboteurEnabled = false;
  bool _diceRollEnabled = false;
  Set<String> _selectedBundles = {'bundle.free'}; // <-- NEW: Selected bundles for gameplay
  bool _loadingBundles = true; // <-- NEW: Loading state for bundle selections

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userService = context.read<UserService>();

    final settings = await userService.fetchRoomCreationSettings();
    final bundleSelections = await userService.loadBundleSelections();

    setState(() {
      _saboteurEnabled = settings['saboteurEnabled'] ?? false;
      _diceRollEnabled = settings['diceRollEnabled'] ?? false;
      _selectedBundles = bundleSelections;
      _loadingBundles = false;
    });
  }

  Future<void> _saveGameSettings() async {
    final userService = context.read<UserService>();
    await userService.saveRoomCreationSettings(_saboteurEnabled, _diceRollEnabled, 5, _selectedBundles);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.settingsSaved)),
    );
  }

  Future<void> _saveBundleSettings() async {
    final userService = context.read<UserService>();
    final loc = AppLocalizations.of(context)!;
    
    try {
      await userService.saveBundleSelections(_selectedBundles);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.bundleSelectionSaved)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorSavingBundleSelections}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    final localeProvider = context.watch<LocaleProvider>();
    final currentCode = localeProvider.locale.languageCode;
    // Audio service moved to lobby screen

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: ListView( // Changed to ListView for better scrolling
        padding: const EdgeInsets.all(16),
        children: [
          // Saboteur Feature Switch
          ListTile(
            title: Text(loc.enableSaboteur),
            trailing: Switch(
              value: _saboteurEnabled,
              onChanged: (value) {
                setState(() => _saboteurEnabled = value);
                _saveGameSettings();
              },
            ),
          ),
          const Divider(),

          // Dice Roll Feature Switch
          ListTile(
            title: Text(loc.enableDiceRoll),
            trailing: Switch(
              value: _diceRollEnabled,
              onChanged: (value) {
                setState(() => _diceRollEnabled = value);
                _saveGameSettings();
              },
            ),
          ),
          const Divider(),

          // Match settings (rounds, music, spectrum skins) have been moved to lobby screen
          const Divider(),

          // --- NEW: Bundle Selection ---
          Consumer<PurchaseProviderNew>(
            builder: (context, purchaseProvider, child) {
              final ownedBundles = purchaseProvider.ownedBundles;
              
              // Show loading indicator while bundle selections are being loaded
              if (_loadingBundles) {
                return ListTile(
                  title: Text(AppLocalizations.of(context)!.loadingBundleSelections),
                  trailing: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              
              // Only show bundle selection if user owns more than just the free bundle
              if (ownedBundles.length <= 1) {
                return const SizedBox.shrink();
              }
              
              // Validate selected bundles against owned bundles
              final validSelectedBundles = _selectedBundles.where((bundle) => ownedBundles.contains(bundle)).toSet();
              if (validSelectedBundles.length != _selectedBundles.length) {
                // Update state if there are invalid selections
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _selectedBundles = validSelectedBundles.isEmpty ? {'bundle.free'} : validSelectedBundles;
                  });
                });
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      loc.selectBundlesForGameplay,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...ownedBundles.map((bundleId) {
                    final bundleInfo = _getBundleInfo(bundleId);
                    final isSelected = _selectedBundles.contains(bundleId);
                    
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
                          color: isSelected ? bundleInfo.color : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${CategoryService.getCategoriesByBundle(bundleId).length} categories',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedBundles.add(bundleId);
                            } else {
                              // Don't allow deselecting the free bundle if it's the only one selected
                              if (bundleId != 'bundle.free' || _selectedBundles.length > 1) {
                                _selectedBundles.remove(bundleId);
                              }
                            }
                          });
                          _saveBundleSettings();
                        },
                        activeColor: bundleInfo.color,
                      ),
                    );
                  }),
                  const Divider(),
                ],
              );
            },
          ),

          // Premium Features Section - Temporarily Hidden
          // Consumer<PremiumProvider>(
          //   builder: (context, premium, child) {
          //     if (!premium.isPremium) {
          //       return Column(
          //         children: [
          //           const Divider(),
          //           ListTile(
          //             leading: const Icon(Icons.star, color: Colors.amber),
          //             title: Text('Premium Features'),
          //             subtitle: Text('Upgrade to unlock premium features'),
          //             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //             onTap: () => Navigator.pushNamed(context, '/premium'),
          //           ),
          //           const Divider(),
          //         ],
          //       );
          //     }

          //     return Column(
          //       children: [
          //         const Divider(),
          //         Padding(
          //           padding: const EdgeInsets.all(16.0),
          //           child: Row(
          //             children: [
          //               const Icon(Icons.star, color: Colors.amber),
          //               const SizedBox(width: 8),
          //               Text(
          //                 'Premium Features',
          //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //                   color: Colors.white,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //         if (premium.hasAvatarCustomization)
          //           ListTile(
          //             leading: const Icon(Icons.face),
          //             title: const Text('Custom Avatars'),
          //             subtitle: const Text('Upload and manage custom avatars'),
          //             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //             onTap: () => Navigator.pushNamed(context, '/avatar-customization'),
          //           ),
          //         if (premium.hasGroupChat)
          //           ListTile(
          //             leading: const Icon(Icons.chat),
          //             title: const Text('Group Chat'),
          //             subtitle: const Text('Chat with players in your room'),
          //             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //             onTap: () {
          //               // TODO: Navigate to group chat with room context
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 const SnackBar(content: Text('Group chat coming soon!')),
          //               );
          //             },
          //           ),
          //         if (premium.hasBundleSuggestions)
          //           ListTile(
          //             leading: const Icon(Icons.lightbulb),
          //             title: const Text('Suggest Bundles'),
          //             subtitle: const Text('Suggest new bundles for the game'),
          //             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //             onTap: () => Navigator.pushNamed(context, '/bundle-suggestion'),
          //           ),
          //         if (premium.hasCustomUsername)
          //           ListTile(
          //             leading: const Icon(Icons.person),
          //             title: const Text('Custom Username'),
          //             subtitle: const Text('Set a custom username'),
          //             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //             onTap: () => Navigator.pushNamed(context, '/custom-username'),
          //           ),
          //         if (premium.hasOnlineMatchmaking)
          //           ListTile(
          //             leading: const Icon(Icons.people),
          //             title: const Text('Online Matchmaking'),
          //             subtitle: const Text('Play with random players online'),
          //             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //             onTap: () => Navigator.pushNamed(context, '/online-matchmaking'),
          //           ),
          //         const Divider(),
          //       ],
          //     );
          //   },
          // ),

          // How to Play
          ListTile(
            leading: const Icon(Icons.school),
            title: Text(loc.howToPlay),
            onTap: () => Navigator.of(context).pushNamed(TutorialScreen.routeName),
          ),
          const Divider(),

          // Language Selector
          ListTile(
            title: Text(loc.language),
            trailing: DropdownButton<String>(
              value: currentCode,
              dropdownColor: Colors.grey[900],
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 'en', child: Text(loc.english)),
                DropdownMenuItem(value: 'ar', child: Text(loc.arabic)),
              ],
              onChanged: (lang) {
                if (lang != null) {
                  localeProvider.setLocale(Locale(lang));
                }
              },
            ),
          ),
          const Divider(),
          
          // Analytics Dashboard Access (Debug Only)
          if (kDebugMode) ...[
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.amber),
              title: const Text(
                'Analytics Dashboard',
                style: TextStyle(color: Colors.white, fontFamily: 'LuckiestGuy'),
              ),
              subtitle: const Text(
                'View app analytics and user data',
                style: TextStyle(color: Colors.grey, fontFamily: 'Chewy'),
              ),
              onTap: () {
                Navigator.pushNamed(context, AnalyticsDashboardScreen.routeName);
              },
            ),
            const Divider(),
            
            // Debug Section
            if (kDebugMode) ...[
              ListTile(
                leading: const Icon(Icons.palette, color: Colors.orange),
                title: const Text(
                  'Spectrum UI Showcase',
                  style: TextStyle(fontFamily: 'Chewy'),
                ),
                subtitle: const Text(
                  'Debug: Test spectrum card UI variations',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Chewy'),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SpectrumUIShowcaseScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
            ],
          ],
          
          // Build timestamp for version verification
          if (kDebugMode) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Build Info (Debug Only)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${DateTime.now().toString().substring(0, 19)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Exception Handling: Active',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[400],
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Network Check: Enabled',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[400],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
