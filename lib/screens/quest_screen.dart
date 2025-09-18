// lib/screens/quest_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/quest_service.dart';
import '../models/quest_models.dart';
import '../l10n/app_localizations.dart';

class QuestScreen extends StatefulWidget {
  static const routeName = '/quests';
  
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> with SingleTickerProviderStateMixin {
  Map<QuestType, List<QuestWithProgress>> _questsByType = {};
  bool _isLoading = true;
  String? _error;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadQuests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Initialize quests for user
      await QuestService.refreshDailyQuests();
      await QuestService.refreshWeeklyQuests();
      await QuestService.initializeAchievementQuests();

      // Get organized quests
      final organized = await QuestService.getOrganizedQuests();

      setState(() {
        _questsByType = organized;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load quests: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.questsTitle,
          style: const TextStyle(
            fontFamily: 'LuckiestGuy',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: [
            Tab(
              icon: const Icon(Icons.today),
              text: AppLocalizations.of(context)!.daily,
            ),
            Tab(
              icon: const Icon(Icons.date_range),
              text: AppLocalizations.of(context)!.weekly,
            ),
            Tab(
              icon: const Icon(Icons.emoji_events),
              text: AppLocalizations.of(context)!.achievements,
            ),
            Tab(
              icon: const Icon(Icons.star),
              text: AppLocalizations.of(context)!.special,
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Loading Quests...',
              style: TextStyle(
                fontFamily: 'Chewy',
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Chewy',
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: const TextStyle(fontFamily: 'LuckiestGuy'),
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildQuestList(QuestType.daily),
        _buildQuestList(QuestType.weekly),
        _buildQuestList(QuestType.achievement),
        _buildQuestList(QuestType.special),
      ],
    );
  }

  Widget _buildQuestList(QuestType type) {
    final quests = _questsByType[type] ?? [];
    
    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTypeIcon(type),
              size: 64,
              color: Colors.white38,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(type),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Chewy',
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quests.length,
        itemBuilder: (context, index) {
          return _buildQuestCard(quests[index]);
        },
      ),
    );
  }

  Widget _buildQuestCard(QuestWithProgress questWithProgress) {
    final quest = questWithProgress.quest;
    final progress = questWithProgress.progress;
    final difficultyColor = Color(int.parse(quest.difficultyColor.substring(1), radix: 16) + 0xFF000000);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2A2A4A),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: progress.isCompleted 
              ? Colors.green 
              : difficultyColor.withAlpha(100),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and difficulty
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: const TextStyle(
                          fontFamily: 'LuckiestGuy',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: difficultyColor.withAlpha(100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          quest.difficultyDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: difficultyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Quest type icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(quest.type),
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              quest.description,
              style: const TextStyle(
                fontFamily: 'Chewy',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.progress,
                      style: TextStyle(
                        fontFamily: 'Chewy',
                        fontSize: 12,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                    Text(
                      progress.progressText,
                      style: const TextStyle(
                        fontFamily: 'LuckiestGuy',
                        fontSize: 12,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.progressPercentage,
                  backgroundColor: Colors.white.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress.isCompleted ? Colors.green : Colors.amber,
                  ),
                  minHeight: 6,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Rewards section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.rewards,
                  style: TextStyle(
                    fontFamily: 'Chewy',
                    fontSize: 12,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quest.rewards.map((reward) => _buildRewardChip(reward)).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _getButtonAction(progress),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(progress),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _getButtonText(progress),
                  style: const TextStyle(
                    fontFamily: 'LuckiestGuy',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardChip(QuestReward reward) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRewardIcon(reward.iconName),
            size: 16,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            reward.displayText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(QuestType type) {
    switch (type) {
      case QuestType.daily:
        return Icons.today;
      case QuestType.weekly:
        return Icons.date_range;
      case QuestType.achievement:
        return Icons.emoji_events;
      case QuestType.special:
        return Icons.star;
    }
  }

  IconData _getRewardIcon(String iconName) {
    switch (iconName) {
      case 'diamond':
        return Icons.diamond;
      case 'star':
        return Icons.star;
      case 'military_tech':
        return Icons.military_tech;
      case 'palette':
        return Icons.palette;
      default:
        return Icons.card_giftcard;
    }
  }

  String _getEmptyMessage(QuestType type) {
    final loc = AppLocalizations.of(context)!;
    switch (type) {
      case QuestType.daily:
        return loc.noDailyQuests;
      case QuestType.weekly:
        return loc.noWeeklyQuests;
      case QuestType.achievement:
        return loc.noAchievementQuests;
      case QuestType.special:
        return loc.noSpecialQuests;
    }
  }

  Color _getButtonColor(QuestProgress progress) {
    if (progress.canClaimReward) {
      return Colors.green;
    } else if (progress.isCompleted) {
      return Colors.grey;
    } else {
      return Colors.blue;
    }
  }

  String _getButtonText(QuestProgress progress) {
    final loc = AppLocalizations.of(context)!;
    if (progress.isRewardClaimed) {
      return loc.completed;
    } else if (progress.canClaimReward) {
      return loc.claimReward;
    } else if (progress.isCompleted) {
      return loc.readyToClaim;
    } else {
      return loc.inProgress;
    }
  }

  VoidCallback? _getButtonAction(QuestProgress progress) {
    if (progress.canClaimReward) {
      return () => _claimReward(progress.questId);
    }
    return null;
  }

  Future<void> _claimReward(String questId) async {
    HapticFeedback.mediumImpact();
    
    try {
      final success = await QuestService.claimQuestReward(questId, context: context);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.questRewardClaimed),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload quests to reflect changes
        await _loadQuests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.questClaimFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorGeneric}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
