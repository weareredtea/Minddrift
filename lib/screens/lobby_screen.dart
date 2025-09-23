// lib/screens/lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import '../models/player_status.dart';
import '../services/audio_service.dart';
import '../services/player_service.dart';
import '../services/room_service.dart';
import '../services/game_service.dart';
import '../services/test_bot_service.dart';

class LobbyScreen extends StatefulWidget {
  static const routeName = '/lobby';
  final String roomId;
  const LobbyScreen({super.key, required this.roomId});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  MatchSettings _currentSettings = MatchSettings.defaultSettings;
  bool _isLoadingSettings = true;
  bool _isBotInGame = false;
  bool _isManagingBot = false;
  bool _isSettingsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
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
          content: Text('${AppLocalizations.of(context)!.error}: $e'),
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

  /// Checks if the bot is currently in the game
  bool _checkIfBotInGame(List<PlayerStatus> players) {
    return players.any((player) => player.uid == 'test-bot-001');
  }

  /// Manages the test bot (add or remove)
  Future<void> _manageTestBot() async {
    if (_isManagingBot) return;

    setState(() {
      _isManagingBot = true;
    });

    try {
      final playerService = context.read<PlayerService>();
      final roomService = context.read<RoomService>();
      final gameService = context.read<GameService>();

      if (_isBotInGame) {
        // Remove bot
        await playerService.manageTestBot(widget.roomId, addBot: false);
        TestBotService.stop();
        setState(() {
          _isBotInGame = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.testBotRemoved),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Add bot
        await playerService.manageTestBot(widget.roomId, addBot: true);
        TestBotService.start(
          roomId: widget.roomId,
          roomService: roomService,
          playerService: playerService,
          gameService: gameService,
        );
        setState(() {
          _isBotInGame = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.testBotAdded),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.failedToManageBot}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isManagingBot = false;
      });
    }
  }

  BundleInfo _getBundleInfo(String bundleId) {
    switch (bundleId) {
      case 'bundle.free':
        return BundleInfo(
          name: AppLocalizations.of(context)!.freeBundle,
          color: Colors.green,
          icon: Icons.free_breakfast,
        );
      case 'bundle.horror':
        return BundleInfo(
          name: AppLocalizations.of(context)!.horrorBundle,
          color: Colors.red,
          icon: Icons.psychology,
        );
      case 'bundle.kids':
        return BundleInfo(
          name: AppLocalizations.of(context)!.kidsBundle,
          color: Colors.orange,
          icon: Icons.child_care,
        );
      case 'bundle.food':
        return BundleInfo(
          name: AppLocalizations.of(context)!.foodBundle,
          color: Colors.brown,
          icon: Icons.restaurant,
        );
      case 'bundle.nature':
        return BundleInfo(
          name: AppLocalizations.of(context)!.natureBundle,
          color: Colors.green,
          icon: Icons.eco,
        );
      case 'bundle.fantasy':
        return BundleInfo(
          name: AppLocalizations.of(context)!.fantasyBundle,
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

    // Update bot status based on current players
    final botInGame = _checkIfBotInGame(gameState.players);
    if (botInGame != _isBotInGame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isBotInGame = botInGame;
        });
      });
    }

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
                  // 1. New Room Code & Invite Section
                  _buildRoomCodeAndInvite(context, loc),
                  const SizedBox(height: 16),

                  // 2. Main Player List (takes up most of the space)
                  Expanded(
                    child: _buildPlayerList(context, gameState.players, gameState),
                  ),
                  const SizedBox(height: 16),

                  // 3. Collapsible Settings Section
                  _buildCollapsibleSettings(context, loc, gameState.roomId),
                  const SizedBox(height: 24),

                  // 4. Smart, Context-Aware Action Buttons
                  _buildActionButtons(context, loc, gameProvider, gameState),
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

  // 1. New Room Code & Invite Section
  Widget _buildRoomCodeAndInvite(BuildContext context, AppLocalizations loc) {
    return Card(
      elevation: 8,
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              loc.roomCode,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    widget.roomId,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.roomId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.roomCodeCopied),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, color: Colors.white70),
                  tooltip: loc.copyRoomCode,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white12,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement invite functionality with share_plus
                  _showInviteDialog(context, loc);
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(
                  loc.inviteFriends,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.inviteFriends),
        content: Text('Room Code: ${widget.roomId}\n\nShare this code with your friends to join the game!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.close),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.roomId));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.roomCodeCopied),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(loc.copyRoomCode),
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

  // 3. Collapsible Settings Section
  Widget _buildCollapsibleSettings(BuildContext context, AppLocalizations loc, String roomId) {
    if (_isLoadingSettings) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      elevation: 8,
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header with expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _isSettingsExpanded = !_isSettingsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Match Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _isSettingsExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          
          // Collapsible content
          if (_isSettingsExpanded) ...[
            const Divider(color: Colors.white24, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Bundle Info Section
                  _buildBundleSection(roomId),
                  const SizedBox(height: 16),
                  
                  // Number of Rounds
                  _buildRoundsSelector(loc),
                  const SizedBox(height: 16),
                  
                  // Music Toggle
                  _buildMusicToggle(loc),
                  // Note: Removed spectrum skin selector as requested
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoundsSelector(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.numberOfRounds),
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
        Text(AppLocalizations.of(context)!.backgroundMusic),
        Switch(
          value: _currentSettings.musicEnabled,
          onChanged: (value) {
            _updateSettings(_currentSettings.copyWith(musicEnabled: value));
          },
        ),
      ],
    );
  }


  // 2. Main Player List (takes up most of the space)
  Widget _buildPlayerList(BuildContext context, List<PlayerStatus> players, GameState gameState) {
    return Card(
      elevation: 8,
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Players (${players.length}/6)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (gameState.isHost && kDebugMode)
                  ElevatedButton.icon(
                    onPressed: _isManagingBot ? null : _manageTestBot,
                    icon: _isManagingBot 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_isBotInGame ? Icons.remove : Icons.add),
                    label: Text(_isBotInGame ? AppLocalizations.of(context)!.removeBot : AppLocalizations.of(context)!.addBot),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBotInGame ? Colors.red.shade600 : Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: players.isEmpty 
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.waitingForPlayers,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        return _buildPlayerCard(context, player, gameState);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, PlayerStatus player, GameState gameState) {
    final userProfile = context.watch<UserProfileProvider>().userProfile;
    final isCurrentPlayer = player.uid == userProfile?.uid;
    final isHost = gameState.isHost && player.uid == gameState.myPlayerStatus?.uid;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.blue.withOpacity(0.15) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? Colors.blue : Colors.white24,
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: Text(
              player.displayName.isNotEmpty ? player.displayName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (isHost) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                    ],
                    if (isCurrentPlayer) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      player.ready ? Icons.check_circle : Icons.schedule,
                      color: player.ready ? Colors.green : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      player.ready ? 'Ready' : 'Waiting',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: player.ready ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Smart, Context-Aware Action Buttons
  Widget _buildActionButtons(BuildContext context, AppLocalizations loc, GameStateProvider gameProvider, GameState gameState) {
    final me = gameState.myPlayerStatus;
    if (me == null) return const SizedBox.shrink(); // Not in the game yet

    final isHost = gameState.isHost;
    final allReady = gameState.allPlayersReady;
    // final notReadyCount = gameState.players.where((p) => !p.ready).length;

    return Column(
      children: [
        // Player Ready Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => gameProvider.setReady(!me.ready),
            style: ElevatedButton.styleFrom(
              backgroundColor: me.ready ? Colors.green[600] : Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  me.ready ? Icons.check_circle : Icons.schedule,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  me.ready ? AppLocalizations.of(context)!.ready : AppLocalizations.of(context)!.notReady,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Host Start Game Button
        if (isHost) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: allReady ? () => gameProvider.startRound() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: allReady ? Colors.amber[600] : Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allReady ? Icons.play_arrow : Icons.hourglass_empty,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    allReady 
                        ? AppLocalizations.of(context)!.startGame 
                        : AppLocalizations.of(context)!.waitingForPlayersToGetReady,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
