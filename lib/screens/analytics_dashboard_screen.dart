// lib/screens/analytics_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/analytics_service.dart';
import '../models/analytics_data.dart';
import '../l10n/app_localizations.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  static const routeName = '/analytics-dashboard';
  
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  UserOverviewData _userOverview = UserOverviewData.empty();
  GameplayStatsData _gameplayStats = GameplayStatsData.empty();
  EconomicData _economicData = EconomicData.empty();
  EngagementData _engagementData = EngagementData.empty();
  List<TopUserData> _topUsers = [];
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all analytics data in parallel for better performance
      final results = await Future.wait([
        AnalyticsService.getUserOverview(),
        AnalyticsService.getGameplayStats(),
        AnalyticsService.getEconomicData(),
        AnalyticsService.getEngagementData(),
        AnalyticsService.getTopUsersByScore(),
      ]);

      if (mounted) {
        setState(() {
          _userOverview = results[0] as UserOverviewData;
          _gameplayStats = results[1] as GameplayStatsData;
          _economicData = results[2] as EconomicData;
          _engagementData = results[3] as EngagementData;
          _topUsers = results[4] as List<TopUserData>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportData() async {
    try {
      final data = await AnalyticsService.exportAllData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      await Clipboard.setData(ClipboardData(text: jsonString));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analytics data copied to clipboard!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      elevation: 4,
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Chewy',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'LuckiestGuy',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontFamily: 'Chewy',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontFamily: 'LuckiestGuy',
            ),
          ),
          const SizedBox(height: 20),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                'Total Users',
                '${_userOverview.totalUsers}',
                'All time registrations',
                Colors.blue,
                Icons.people,
              ),
              _buildStatCard(
                'Active Today',
                '${_userOverview.activeToday}',
                'Users online today',
                Colors.green,
                Icons.online_prediction,
              ),
              _buildStatCard(
                'Active This Week',
                '${_userOverview.activeThisWeek}',
                'Weekly active users',
                Colors.orange,
                Icons.calendar_today,
              ),
              _buildStatCard(
                'New Users',
                '${_userOverview.newUsers}',
                'Last 7 days',
                Colors.purple,
                Icons.person_add,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildStatCard(
            'Retention Rate',
            '${(_userOverview.retentionRate * 100).toStringAsFixed(1)}%',
            'Weekly retention percentage',
            Colors.teal,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildGameplayStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gameplay Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontFamily: 'LuckiestGuy',
            ),
          ),
          const SizedBox(height: 20),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                'Total Games',
                '${_gameplayStats.totalGames}',
                'All game modes combined',
                Colors.amber,
                Icons.sports_esports,
              ),
              _buildStatCard(
                'Average Score',
                '${_gameplayStats.averageScore.toStringAsFixed(1)}/5',
                'Across all players',
                Colors.green,
                Icons.star,
              ),
              _buildStatCard(
                'Perfect Scores',
                '${(_gameplayStats.perfectScoreRate * 100).toStringAsFixed(1)}%',
                'Rate of perfect games',
                Colors.amber,
                Icons.emoji_events,
              ),
              _buildStatCard(
                'Practice Games',
                '${_gameplayStats.practiceGames}',
                'Solo practice sessions',
                Colors.blue,
                Icons.fitness_center,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildStatCard(
            'Daily Challenges',
            '${_gameplayStats.dailyChallengeGames}',
            'Daily challenge completions',
            Colors.orange,
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildEconomicDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Economic Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontFamily: 'LuckiestGuy',
            ),
          ),
          const SizedBox(height: 20),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                'Gems Earned',
                '${(_economicData.totalGemsEarned / 1000).toStringAsFixed(1)}K',
                'Total gems earned by users',
                Colors.amber,
                Icons.diamond,
              ),
              _buildStatCard(
                'Gems Spent',
                '${(_economicData.totalGemsSpent / 1000).toStringAsFixed(1)}K',
                'Total gems spent in store',
                Colors.red,
                Icons.shopping_cart,
              ),
              _buildStatCard(
                'Average Wallet',
                '${_economicData.averageWallet}',
                'Average gems per user',
                Colors.green,
                Icons.account_balance_wallet,
              ),
              _buildStatCard(
                'Active Spenders',
                '${_economicData.activeSpenders}',
                'Users who made purchases',
                Colors.purple,
                Icons.paid,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildStatCard(
            'Conversion Rate',
            '${(_economicData.conversionRate * 100).toStringAsFixed(1)}%',
            'Users who spend gems',
            Colors.teal,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Metrics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontFamily: 'LuckiestGuy',
            ),
          ),
          const SizedBox(height: 20),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                'Quests Completed',
                '${_engagementData.totalQuestsCompleted}',
                'Total quest completions',
                Colors.blue,
                Icons.task_alt,
              ),
              _buildStatCard(
                'Campaign Stars',
                '${_engagementData.totalCampaignStars}',
                'Total stars earned',
                Colors.amber,
                Icons.star,
              ),
              _buildStatCard(
                'Avg Progress',
                'Level ${_engagementData.averageCampaignProgress}',
                'Average campaign level',
                Colors.green,
                Icons.trending_up,
              ),
              _buildStatCard(
                'Daily Streaks',
                '${_engagementData.averageDailyStreak.toStringAsFixed(1)}',
                'Average streak length',
                Colors.orange,
                Icons.local_fire_department,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildStatCard(
            'Max Streak',
            '${_engagementData.maxDailyStreak} days',
            'Longest daily challenge streak',
            Colors.red,
            Icons.emoji_events,
          ),
          
          const SizedBox(height: 24),
          
          // Top Users Section
          Card(
            elevation: 4,
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.leaderboard, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Top Performers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'LuckiestGuy',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_topUsers.isEmpty)
                    const Center(
                      child: Text(
                        'No user data available',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Chewy',
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _topUsers.length,
                      itemBuilder: (context, index) {
                        final user = _topUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'LuckiestGuy',
                            ),
                          ),
                          subtitle: Text(
                            user.metric,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Chewy',
                            ),
                          ),
                          trailing: Text(
                            user.value.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'LuckiestGuy',
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontFamily: 'LuckiestGuy'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
            tooltip: 'Export Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.sports_esports), text: 'Gameplay'),
            Tab(icon: Icon(Icons.diamond), text: 'Economy'),
            Tab(icon: Icon(Icons.trending_up), text: 'Engagement'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          indicatorColor: Colors.amber[600],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.amber),
                  SizedBox(height: 16),
                  Text(
                    'Loading analytics data...',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Chewy',
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontFamily: 'LuckiestGuy',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Chewy',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadAnalyticsData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserOverviewTab(),
                    _buildGameplayStatsTab(),
                    _buildEconomicDataTab(),
                    _buildEngagementTab(),
                  ],
                ),
    );
  }
}
