// lib/screens/daily_challenge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/daily_challenge_service.dart';
import '../models/daily_challenge_models.dart';
import '../models/avatar.dart';
import '../widgets/solo_spectrum_card.dart';
import '../widgets/radial_spectrum.dart';
import '../l10n/app_localizations.dart';

class DailyChallengeScreen extends StatefulWidget {
  static const routeName = '/daily-challenge';
  
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> with TickerProviderStateMixin {
  DailyChallenge? _todaysChallenge;
  DailyResult? _todaysResult;
  List<DailyLeaderboardEntry> _leaderboard = [];
  DailyStats _userStats = DailyStats.empty();
  
  bool _isLoading = true;
  bool _hasPlayedToday = false;
  double _userGuess = 0.5;
  bool _isSubmitting = false;
  DateTime? _challengeStartTime;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDailyChallenge();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyChallenge() async {
    setState(() => _isLoading = true);

    try {
      // Load today's challenge with current language
      final languageCode = Localizations.localeOf(context).languageCode;
      _todaysChallenge = await DailyChallengeService.getTodaysChallenge(languageCode);
      
      // Check if user has already played today
      _hasPlayedToday = await DailyChallengeService.hasPlayedToday();
      
      if (_hasPlayedToday) {
        // Load today's result
        _todaysResult = await DailyChallengeService.getTodaysResult();
      } else {
        // Start timer for new challenge
        _challengeStartTime = DateTime.now();
      }
      
      // Load leaderboard and stats
      await Future.wait([
        _loadLeaderboard(),
        _loadUserStats(),
      ]);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingChallenge}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      _leaderboard = await DailyChallengeService.getTodaysLeaderboard();
    } catch (e) {
      print('Error loading leaderboard: $e');
    }
  }

  Future<void> _loadUserStats() async {
    try {
      _userStats = await DailyChallengeService.getUserDailyStats();
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  Future<void> _submitGuess() async {
    if (_todaysChallenge == null || _hasPlayedToday || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.lightImpact();

    try {
      final timeSpent = DateTime.now().difference(_challengeStartTime!);
      
      final result = await DailyChallengeService.submitDailyResult(
        challenge: _todaysChallenge!,
        userGuess: _userGuess,
        timeSpent: timeSpent,
        context: context,
      );

      setState(() {
        _todaysResult = result;
        _hasPlayedToday = true;
      });

      // Reload leaderboard and stats
      await Future.wait([
        _loadLeaderboard(),
        _loadUserStats(),
      ]);

      // Show success feedback
      HapticFeedback.heavyImpact();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorSubmittingResult}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildChallengeTab() {
    if (_todaysChallenge == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Daily challenge header
          Card(
            elevation: 8,
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.amber[600], size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.dailyChallenge,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'LuckiestGuy',
                              ),
                            ),
                            Text(
                              _formatDateForDisplay(DateTime.now()),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                                fontFamily: 'Chewy',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(_todaysChallenge!.difficulty),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _todaysChallenge!.difficulty.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'LuckiestGuy',
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Category display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_todaysChallenge!.leftLabel} ↔ ${_todaysChallenge!.rightLabel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'LuckiestGuy',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Clue display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[300]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.todaysClue,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontFamily: 'Chewy',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${_todaysChallenge!.clue}"',
                          style: TextStyle(
                            color: Colors.amber[300],
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'LuckiestGuy',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Game interface or result
          if (_hasPlayedToday && _todaysResult != null)
            _buildResultCard()
          else
            _buildGameInterface(),
        ],
      ),
    );
  }

  Widget _buildGameInterface() {
    if (_todaysChallenge == null) return const SizedBox();

    return Card(
      elevation: 4,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Radial Spectrum Widget
            SizedBox(
              height: 300, // Standard height from original
              child: SoloSpectrumCard(
                startLabel: _todaysChallenge!.leftLabel,
                endLabel: _todaysChallenge!.rightLabel,
                child: RadialSpectrumWidget(
                  value: _userGuess * 100, // Convert 0-1 to 0-100
                  onChanged: _isSubmitting ? (value) {} : (value) {
                    setState(() {
                      _userGuess = value / 100; // Convert 0-100 back to 0-1
                    });
                  },
                  isReadOnly: _isSubmitting,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitGuess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  disabledBackgroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.submitAnswer,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'LuckiestGuy',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_todaysResult == null) return const SizedBox();

    return Card(
      elevation: 8,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.todaysResult,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'LuckiestGuy',
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Score display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreStat(AppLocalizations.of(context)!.score, '${_todaysResult!.score}/5', _getScoreColor(_todaysResult!.score)),
                _buildScoreStat(AppLocalizations.of(context)!.accuracy, '${(_todaysResult!.accuracy * 100).toStringAsFixed(1)}%', Colors.green),
                _buildScoreStat(AppLocalizations.of(context)!.gameTime, '${_todaysResult!.timeSpent.inSeconds}s', Colors.orange),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Position comparison
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.yourGuess,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontFamily: 'Chewy',
                        ),
                      ),
                      Text(
                        '${(_todaysResult!.userGuess * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.correctAnswer,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontFamily: 'Chewy',
                        ),
                      ),
                      Text(
                        '${(_todaysChallenge!.secretPosition * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Come back tomorrow message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[600]?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[600]!, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.challengeComplete,
                    style: TextStyle(
                      color: Colors.amber[600],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LuckiestGuy',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.comeBackTomorrow,
                    style: TextStyle(
                      color: Colors.amber[300],
                      fontSize: 14,
                      fontFamily: 'Chewy',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return Column(
      children: [
        // Leaderboard header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.leaderboard, color: Colors.amber[600], size: 28),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.todaysLeaderboard,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'LuckiestGuy',
                ),
              ),
            ],
          ),
        ),
        
        // Leaderboard list
        Expanded(
          child: _leaderboard.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noPlayersYetToday,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontFamily: 'Chewy',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.beTheFirstToComplete,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontFamily: 'Chewy',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = _leaderboard[index];
                    final isCurrentUser = entry.userId == FirebaseAuth.instance.currentUser?.uid;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: isCurrentUser ? Colors.blue[900] : Colors.grey[850],
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Rank
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getRankColor(entry.rank),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.rank}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Avatar
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[700],
                              child: SvgPicture.asset(
                                Avatars.getPathFromId(entry.avatarId),
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          entry.displayName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'LuckiestGuy',
                          ),
                        ),
                        subtitle: Text(
                          '${(entry.accuracy * 100).toStringAsFixed(1)}% • ${entry.timeSpent.inSeconds}s',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'Chewy',
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(entry.score),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${entry.score}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats header
          Card(
            elevation: 8,
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.green[600], size: 28),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.yourStatistics,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'LuckiestGuy',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Streak display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[600]?.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[600]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🔥 ${_userStats.currentStreak}',
                          style: TextStyle(
                            color: Colors.orange[600],
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'LuckiestGuy',
                          ),
                        ),
                        Text(
                          _userStats.streakMessage,
                          style: TextStyle(
                            color: Colors.orange[300],
                            fontSize: 14,
                            fontFamily: 'Chewy',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Detailed stats
          Card(
            elevation: 4,
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreStat(AppLocalizations.of(context)!.daysPlayed, '${_userStats.totalDaysPlayed}', Colors.blue),
                      _buildScoreStat(AppLocalizations.of(context)!.perfectDays, '${_userStats.perfectDays}', Colors.green),
                      _buildScoreStat(AppLocalizations.of(context)!.bestStreak, '${_userStats.bestStreak}', Colors.orange),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreStat(AppLocalizations.of(context)!.avgScore, _userStats.averageScore.toStringAsFixed(1), Colors.purple),
                      _buildScoreStat(AppLocalizations.of(context)!.avgAccuracy, '${(_userStats.averageAccuracy * 100).toStringAsFixed(1)}%', Colors.teal),
                      _buildScoreStat(AppLocalizations.of(context)!.bestScore, '${_userStats.bestScore}/5', Colors.amber),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'LuckiestGuy',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontFamily: 'Chewy',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return Colors.green[600]!;
      case 'medium': return Colors.orange[600]!;
      case 'hard': return Colors.red[600]!;
      default: return Colors.grey[600]!;
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber[600]!; // Gold
    if (rank == 2) return Colors.grey[400]!;   // Silver
    if (rank == 3) return Colors.orange[600]!; // Bronze
    return Colors.blue[600]!;                  // Regular
  }

  Color _getScoreColor(int score) {
    if (score >= 4) return Colors.green;
    if (score >= 3) return Colors.blue;
    if (score >= 2) return Colors.orange;
    return Colors.red;
  }

  String _formatDateForDisplay(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.dailyChallenge,
          style: const TextStyle(fontFamily: 'LuckiestGuy'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDailyChallenge,
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.play_arrow), text: AppLocalizations.of(context)!.challenge),
            Tab(icon: const Icon(Icons.leaderboard), text: AppLocalizations.of(context)!.leaderboard),
            Tab(icon: const Icon(Icons.analytics), text: AppLocalizations.of(context)!.stats),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          indicatorColor: Colors.amber[600],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures
              children: [
                _buildChallengeTab(),
                _buildLeaderboardTab(),
                _buildStatsTab(),
              ],
            ),
    );
  }
}
