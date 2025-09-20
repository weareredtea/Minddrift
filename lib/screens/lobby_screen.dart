// lib/screens/lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_service.dart';
import '../services/navigation_service.dart';
import '../providers/game_state_provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/game_state.dart';
import '../widgets/bundle_indicator.dart';
import '../widgets/language_toggle.dart';
import '../services/category_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/global_chat_overlay.dart';
import '../models/match_settings.dart';
import '../models/spectrum_skin.dart';
import '../models/player_status.dart';
import '../services/skin_manager.dart';
import '../services/audio_service.dart';

class LobbyScreen extends StatefulWidget {
  static const routeName = '/lobby';
  final String roomId;
  const LobbyScreen({super.key, required this.roomId});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  MatchSettings _currentSettings = MatchSettings.defaultSettings;
  List<String> _ownedSkins = ['default'];
  bool _isLoadingSettings = true;
  bool _isLoadingSkins = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
    _loadUserSkins();
  }

  Future<void> _loadUserSettings() async {
    final userService = context.read<UserService>();
    try {
      final settings = await userService.loadMatchSettings();
      setState(() {
        _currentSettings = settings;
        _isLoadingSettings = false;
      });
      
      // Apply music setting
      final audioService = AudioService();
      if (settings.musicEnabled) {
        await audioService.startMusic();
      } else {
        await audioService.stopMusic();
      }
    } catch (e) {
      setState(() {
        _isLoadingSettings = false;
      });
    }
  }

  Future<void> _loadUserSkins() async {
    try {
      final ownedSkins = await SkinManager.getOwnedSkins();
      setState(() {
        _ownedSkins = ownedSkins;
        _isLoadingSkins = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSkins = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final userService = context.read<UserService>();
    try {
      await userService.saveMatchSettings(_currentSettings);
      
      // Apply music setting immediately
      final audioService = AudioService();
      if (_currentSettings.musicEnabled) {
        await audioService.startMusic();
      } else {
        await audioService.stopMusic();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settingsSaved),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateSettings(MatchSettings newSettings) {
    setState(() {
      _currentSettings = newSettings;
    });
    _saveSettings();
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
          name: AppLocalizations.of(context)!.unknownBundle,
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- GET EVERYTHING FROM THE PROVIDER ---
    final gameState = context.watch<GameStateProvider>().state;
    final gameProvider = context.read<GameStateProvider>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.lobby),
        actions: [
          const LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              final navService = context.read<NavigationService>();
              navService.exitRoomAndNavigateToHome(context, widget.roomId);
            },
            tooltip: loc.exitGame,
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Room Code Section
                  _buildRoomCodeSection(loc),
                  const SizedBox(height: 24),
                  
                  // Bundle Info Section
                  _buildBundleSection(gameState.roomId),
                  const SizedBox(height: 24),
                  
                  // Match Settings Section
                  _buildMatchSettingsSection(loc),
                  const SizedBox(height: 24),
                  
                  // Players Section
                  Expanded(child: _buildPlayersSection(loc, gameState.players)),
                  
                  const SizedBox(height: 16),
                  
                  // Ready Button
                  _buildReadyButton(loc, gameProvider, gameState),
                ],
              ),
            ),
          ),
          GlobalChatOverlay(
            roomId: widget.roomId,
            roomName: 'Room ${widget.roomId}',
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeSection(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(loc.roomCode, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.roomId,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.roomId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.roomCodeCopied),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, color: Colors.white70),
                tooltip: loc.copyRoomCode,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white12,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBundleSection(String roomId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('rooms').doc(roomId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          final selectedBundle = snapshot.data!.data()!['selectedBundle'] as String?;
          if (selectedBundle != null) {
            final bundleInfo = _getBundleInfo(selectedBundle);
            final categories = CategoryService.getCategoriesByBundle(selectedBundle);
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bundleInfo.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: bundleInfo.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BundleIndicator(
                    categoryId: selectedBundle,
                    showIcon: true,
                    showLabel: false,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${bundleInfo.name} • ${categories.length} categories',
                    style: TextStyle(
                      color: bundleInfo.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMatchSettingsSection(AppLocalizations loc) {
    if (_isLoadingSettings || _isLoadingSkins) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Number of Rounds
          _buildRoundsSelector(loc),
          const SizedBox(height: 16),
          
          // Music Toggle
          _buildMusicToggle(loc),
          const SizedBox(height: 16),
          
          // Spectrum Skin Selector
          _buildSpectrumSkinSelector(loc),
        ],
      ),
    );
  }

  Widget _buildRoundsSelector(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Number of Rounds'),
        Row(
          children: [
            IconButton(
              onPressed: _currentSettings.numberOfRounds > 3 ? () {
                _updateSettings(_currentSettings.copyWith(
                  numberOfRounds: _currentSettings.numberOfRounds - 1,
                ));
              } : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_currentSettings.numberOfRounds}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: _currentSettings.numberOfRounds < 10 ? () {
                _updateSettings(_currentSettings.copyWith(
                  numberOfRounds: _currentSettings.numberOfRounds + 1,
                ));
              } : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMusicToggle(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Background Music'),
        Switch(
          value: _currentSettings.musicEnabled,
          onChanged: (value) {
            _updateSettings(_currentSettings.copyWith(musicEnabled: value));
          },
        ),
      ],
    );
  }

  Widget _buildSpectrumSkinSelector(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spectrum Theme'),
        const SizedBox(height: 8),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _ownedSkins.length,
            itemBuilder: (context, index) {
              final skinId = _ownedSkins[index];
              final skin = SpectrumSkinCatalog.getSkinById(skinId);
              final isSelected = _currentSettings.spectrumSkinId == skinId;
              
              return GestureDetector(
                onTap: () {
                  _updateSettings(_currentSettings.copyWith(spectrumSkinId: skinId));
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: skin.primaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: skin.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        skin.name,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersSection(AppLocalizations loc, List<PlayerStatus> players) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Players',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: players.isEmpty 
                ? Center(child: Text(loc.waitingForPlayersToJoin))
                : ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (_, i) {
                      final player = players[i];
                      // Get the current user's profile to highlight them
                      final userProfile = context.watch<UserProfileProvider>().userProfile;
                      final isMe = player.uid == userProfile?.uid;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: isMe 
                            ? BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blueAccent, width: 1),
                              )
                            : null,
                        child: ListTile(
                          leading: Icon(
                            Icons.person,
                            color: isMe ? Colors.blueAccent : null,
                          ),
                          title: Text(
                            player.displayName,
                            style: TextStyle(
                              fontWeight: isMe ? FontWeight.bold : null,
                              color: isMe ? Colors.blueAccent : null,
                            ),
                          ),
                          subtitle: Text('${loc.uid(player.uid.substring(0, 8))}...'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              player.ready 
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                              if (isMe) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ],
                            ],
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

  Widget _buildReadyButton(
    AppLocalizations loc,
    GameStateProvider gameProvider,
    GameState gameState,
  ) {
    final me = gameState.myPlayerStatus;
    if (me == null) return const SizedBox.shrink(); // Not in the game yet

    final isHost = gameState.isHost;
    final allReady = gameState.allPlayersReady;

    return Column(
      children: [
        // "I'm Ready" button for all players
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => gameProvider.setReady(!me.ready), // <-- ACTION
            style: ElevatedButton.styleFrom(
              backgroundColor: me.ready ? Colors.green : null,
            ),
            child: Text(
              me.ready ? loc.ready : loc.imHereLetsGetReady,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        // "All Ready Start Round" button for host only
        if (isHost) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: allReady ? () => gameProvider.startRound() : null, // <-- ACTION
              style: ElevatedButton.styleFrom(
                backgroundColor: allReady ? Colors.blue : Colors.grey,
              ),
              child: Text(
                allReady ? loc.allReadyStartRound : loc.waitingForPlayers,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
