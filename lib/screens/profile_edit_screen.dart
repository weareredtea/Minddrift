// lib/screens/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/avatar.dart';
import '../models/custom_username.dart';
import '../models/player_wallet.dart';
import '../models/user_profile.dart';
import '../services/wallet_service.dart';
import '../providers/user_profile_provider.dart';
import '../l10n/app_localizations.dart';

class ProfileEditScreen extends StatefulWidget {
  static const routeName = '/profile-edit';
  
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedAvatarId = 'bear';
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true;
  String? _usernameError;
  CustomUsername? _currentUsername;
  
  // Wallet-aware avatar system
  PlayerWallet? _wallet;
  List<Avatar> _availableAvatars = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Load the player wallet to get owned avatar packs
      final wallet = await WalletService.getWallet();
      
      // Build the list of available avatars based on owned packs
      final availableAvatars = Avatars.getAvailableAvatars(wallet.ownedAvatarPacks);

      // Get current profile from UserProfileProvider
      final userProfileProvider = context.read<UserProfileProvider>();
      final userProfile = userProfileProvider.userProfile;

      if (userProfile != null) {
        // Use profile data from the provider
        _usernameController.text = userProfile.displayName;
        _selectedAvatarId = userProfile.avatarId;
      } else {
        // Fallback to loading from Firestore if provider doesn't have data yet
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = userDoc.data();
        _selectedAvatarId = userData?['avatarId'] as String? ?? 'bear';
        _usernameController.text = userData?['displayName'] as String? ?? 'MindDrifter';
      }
      
      // Ensure selected avatar is available (fallback to first free avatar if not)
      if (!availableAvatars.any((avatar) => avatar.id == _selectedAvatarId)) {
        _selectedAvatarId = Avatars.freeAvatars.first.id;
      }

      // Update state
      if (mounted) {
        setState(() {
          _wallet = wallet;
          _availableAvatars = availableAvatars;
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingProfile}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.length < 3) return;
    
    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      // Check if username is valid format
      if (!CustomUsername.isValidUsername(username)) {
        setState(() {
          _isUsernameAvailable = false;
          _usernameError = CustomUsername.getValidationError(username);
        });
        return;
      }

      // Check if username is available (excluding current user's username)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final query = await FirebaseFirestore.instance
          .collection('custom_usernames')
          .where('username', isEqualTo: username.toLowerCase())
          .where('isActive', isEqualTo: true)
          .get();

      // Username is available if no docs found, or if the only doc is the current user's
      final isAvailable = query.docs.isEmpty || 
          (query.docs.length == 1 && query.docs.first.data()['userId'] == user.uid);

      setState(() {
        _isUsernameAvailable = isAvailable;
        _usernameError = isAvailable ? null : 'Username is already taken'; // Will be localized in UI
      });
    } catch (e) {
      setState(() {
        _isUsernameAvailable = false;
        _usernameError = 'Error checking username availability'; // Will be localized in UI
      });
    } finally {
      setState(() => _isCheckingUsername = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isUsernameAvailable) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();

      // Create updated profile
      final updatedProfile = UserProfile(
        uid: user.uid,
        displayName: username,
        avatarId: _selectedAvatarId,
      );

      // Update profile using ProfileService (this will update Firestore)
      final userProfileProvider = context.read<UserProfileProvider>();
      await userProfileProvider.updateProfile(updatedProfile);

      // Handle custom username if needed (for backward compatibility)
      if (_currentUsername?.username != username.toLowerCase()) {
        // Deactivate current username if exists
        if (_currentUsername != null) {
          await FirebaseFirestore.instance
              .collection('custom_usernames')
              .doc(_currentUsername!.id)
              .update({'isActive': false});
        }

        // Create new username
        final customUsername = CustomUsername(
          id: '', // Will be set by Firestore
          userId: user.uid,
          username: username.toLowerCase(),
          createdAt: DateTime.now(),
          isActive: true,
          isVerified: true,
        );

        await FirebaseFirestore.instance
            .collection('custom_usernames')
            .add(customUsername.toFirestore());

        // Update Firebase Auth display name
        await user.updateDisplayName(username);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorUpdatingProfile}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _getLocalizedError(String? error) {
    if (error == null) return null;
    if (error == 'Username is already taken') {
      return AppLocalizations.of(context)!.usernameIsAlreadyTaken;
    }
    if (error == 'Error checking username availability') {
      return AppLocalizations.of(context)!.errorCheckingUsernameAvailability;
    }
    return error;
  }

  Widget _buildAvatarSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.chooseAvatar,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'LuckiestGuy',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableAvatars.length,
            itemBuilder: (context, index) {
              final avatar = _availableAvatars[index];
              final isSelected = avatar.id == _selectedAvatarId;
              final isLocked = avatar.isLocked;
              
              return GestureDetector(
                onTap: () {
                  if (!isLocked) {
                    setState(() {
                      _selectedAvatarId = avatar.id;
                    });
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[600] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                            ? Border.all(color: Colors.blue[300]!, width: 3)
                            : Border.all(color: Colors.grey[600]!, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Opacity(
                          opacity: isLocked ? 0.5 : 1.0,
                          child: SvgPicture.asset(
                            avatar.svgPath,
                            fit: BoxFit.contain,
                          ),
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
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameInput() {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.username,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'LuckiestGuy',
          ),
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterYourUsername,
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _isCheckingUsername
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _usernameController.text.isNotEmpty
                      ? Icon(
                          _isUsernameAvailable ? Icons.check_circle : Icons.error,
                          color: _isUsernameAvailable ? Colors.green : Colors.red,
                        )
                      : null,
              errorText: _getLocalizedError(_usernameError),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              if (value.length >= 3) {
                _checkUsernameAvailability(value);
              } else {
                setState(() {
                  _isUsernameAvailable = true;
                  _usernameError = null;
                });
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.usernameIsRequired;
              }
              if (value.trim().length < 3) {
                return AppLocalizations.of(context)!.usernameMustBeAtLeast3Characters;
              }
              if (!CustomUsername.isValidUsername(value.trim())) {
                return AppLocalizations.of(context)!.usernameCanOnlyContainLettersNumbersUnderscores;
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.usernameRules,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontFamily: 'Chewy',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editProfile,
          style: const TextStyle(
            fontFamily: 'LuckiestGuy',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current profile preview
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.blue[300]!, width: 3),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              Avatars.getPathFromId(_selectedAvatarId),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _usernameController.text.isNotEmpty 
                              ? _usernameController.text 
                              : AppLocalizations.of(context)!.yourUsername,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontFamily: 'LuckiestGuy',
                          ),
                        ),
                        if (_wallet != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amber.withAlpha(150)),
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
                                    fontSize: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Avatar selection
                  _buildAvatarSelector(),
                  
                  const SizedBox(height: 32),
                  
                  // Username input
                  _buildUsernameInput(),
                  
                  const SizedBox(height: 40),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isLoading || !_isUsernameAvailable) ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        disabledBackgroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.saveProfile,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'LuckiestGuy',
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Reset to random button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () {
                        setState(() {
                          _selectedAvatarId = Avatars.getRandomAvatarId();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.shuffle),
                      label: Text(
                        AppLocalizations.of(context)!.randomAvatar,
                        style: const TextStyle(
                          fontFamily: 'Chewy',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
