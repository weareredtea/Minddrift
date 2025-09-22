// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../services/wallet_service.dart';
import '../models/player_wallet.dart';
import '../models/user_profile.dart';
import '../models/avatar.dart';
import '../data/cosmetic_catalog.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final TextEditingController _usernameController = TextEditingController();
  bool _isChangingUsername = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.pleaseLogInToViewProfile)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'LuckiestGuy',
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<UserProfile>(
        stream: _profileService.getProfileStream(user.uid),
        builder: (context, profileSnapshot) {
          return StreamBuilder<PlayerWallet>(
            stream: WalletService.getWalletStream(),
            builder: (context, walletSnapshot) {
              if (!profileSnapshot.hasData || !walletSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userProfile = profileSnapshot.data!;
              final playerWallet = walletSnapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileHeader(context, userProfile, playerWallet),
                    const SizedBox(height: 24),
                    _buildProgressCard(
                      context,
                      title: AppLocalizations.of(context)!.campaignProgress,
                      progress: 0.75, // TODO: Replace with real data
                      progressText: 'Chapter 4 / 5',
                      icon: Icons.campaign,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCard(
                      context,
                      title: AppLocalizations.of(context)!.achievements,
                      progress: 0.4, // TODO: Replace with real data
                      progressText: '20 / 50 Unlocked',
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 24),
                    _buildAvatarGallery(context, playerWallet, userProfile),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile, PlayerWallet wallet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade800,
            Colors.purple.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large Avatar with Change button
          Stack(
            children: [
              GestureDetector(
                onTap: () => _showAvatarSelectionSheet(context, wallet, profile),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      Avatars.getPathFromId(profile.avatarId),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: () => _showAvatarSelectionSheet(context, wallet, profile),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Username with Edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontFamily: 'LuckiestGuy',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                onPressed: () => _showUsernameChangeDialog(context, profile.displayName),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Gem Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${wallet.mindGems}',
                  style: const TextStyle(
                    fontFamily: 'LuckiestGuy',
                    fontSize: 20,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required String title,
    required double progress,
    required String progressText,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontFamily: 'LuckiestGuy',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            progressText,
            style: TextStyle(
              color: Colors.grey[400],
              fontFamily: 'Chewy',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarGallery(BuildContext context, PlayerWallet wallet, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avatar Collection',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontFamily: 'LuckiestGuy',
            ),
          ),
          const SizedBox(height: 16),
          
          // Available avatars
          StreamBuilder<List<String>>(
            stream: WalletService.getOwnedAvatarPacksStream(),
            builder: (context, ownedPacksSnapshot) {
              final ownedPacks = ownedPacksSnapshot.data ?? [];
              final availableAvatars = Avatars.getAvailableAvatars(ownedPacks);
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: availableAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = availableAvatars[index];
                  final isSelected = avatar.id == profile.avatarId;
                  final isLocked = avatar.isLocked;
                  
                  return GestureDetector(
                    onTap: () {
                      if (!isLocked) {
                        _changeAvatar(avatar.id);
                      } else {
                        _showPackPurchaseDialog(context, avatar.packId);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[600] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                            ? Border.all(color: Colors.blue[300]!, width: 3)
                            : Border.all(color: Colors.grey[600]!, width: 1),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Opacity(
                              opacity: isLocked ? 0.5 : 1.0,
                              child: SvgPicture.asset(
                                avatar.svgPath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          if (isLocked)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAvatarSelectionSheet(BuildContext context, PlayerWallet wallet, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.chooseAvatar,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontFamily: 'LuckiestGuy',
              ),
            ),
            const SizedBox(height: 20),
            // Avatar selection grid would go here
            // For now, just show a simple message
            Text(
              AppLocalizations.of(context)!.avatarSelectionComingSoon,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsernameChangeDialog(BuildContext context, String currentUsername) {
    _usernameController.text = currentUsername;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          AppLocalizations.of(context)!.changeUsername,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'LuckiestGuy',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppLocalizations.of(context)!.cost}: 100 💎',
              style: TextStyle(
                color: Colors.amber,
                fontFamily: 'LuckiestGuy',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterNewUsername,
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: _isChangingUsername ? null : () => _changeUsername(),
            child: _isChangingUsername
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppLocalizations.of(context)!.change),
          ),
        ],
      ),
    );
  }

  void _showPackPurchaseDialog(BuildContext context, String packId) {
    final pack = CosmeticCatalog.getAvatarPackById(packId);
    if (pack == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          pack.name,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'LuckiestGuy',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pack.description,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              'Cost: ${pack.gemPrice} 💎',
              style: TextStyle(
                color: Colors.amber,
                fontFamily: 'LuckiestGuy',
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => _purchaseAvatarPack(packId),
            child: Text(AppLocalizations.of(context)!.purchase),
          ),
        ],
      ),
    );
  }

  Future<void> _changeAvatar(String avatarId) async {
    try {
      await _profileService.updateUserAvatar(avatarId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.avatarChangedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorChangingAvatar}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeUsername() async {
    setState(() => _isChangingUsername = true);
    
    try {
      await _profileService.changeUsername(_usernameController.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.usernameChangedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorChangingUsername}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingUsername = false);
      }
    }
  }

  Future<void> _purchaseAvatarPack(String packId) async {
    try {
      final success = await WalletService.purchaseAvatarPack(packId);
      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.avatarPackPurchasedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToPurchaseAvatarPack),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorPurchasingPack}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
