// lib/services/campaign_service.dart

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/campaign_data.dart';
import '../models/campaign_models.dart';
import '../services/wallet_service.dart';
import '../services/quest_service.dart';

class CampaignService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get user's campaign progress
  static Future<CampaignProgress> getUserProgress() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final doc = await _db
          .collection('campaign_progress')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return CampaignProgress.fromFirestore(doc);
      } else {
        // Create initial progress for new user
        final initialProgress = CampaignProgress(
          userId: user.uid,
          lastPlayedAt: DateTime.now(),
        );
        
        await _db
            .collection('campaign_progress')
            .doc(user.uid)
            .set(initialProgress.toFirestore());
        
        return initialProgress;
      }
    } catch (e) {
      print('Error fetching campaign progress: $e');
      rethrow;
    }
  }

  /// Get campaign sections with user progress applied
  static Future<List<CampaignSection>> getCampaignWithProgress() async {
    final progress = await getUserProgress();
    final sections = CampaignDatabase.getSections();
    final userResults = await _getUserResults();

    final updatedSections = <CampaignSection>[];

    for (final section in sections) {
      final updatedLevels = <CampaignLevel>[];
      int sectionStars = 0;
      int completedLevels = 0;

      for (final level in section.levels) {
        // Check if level is unlocked
        bool isUnlocked = _isLevelUnlocked(level, progress);
        
        // Get user's best result for this level
        final result = userResults[level.id];
        int starsEarned = result?.starsEarned ?? 0;
        int bestScore = result?.score ?? 0;
        double bestAccuracy = result?.accuracy ?? 0.0;

        if (result != null) {
          completedLevels++;
          sectionStars += starsEarned;
        }

        final updatedLevel = level.copyWith(
          isUnlocked: isUnlocked,
          starsEarned: starsEarned,
          bestScore: bestScore,
          bestAccuracy: bestAccuracy,
        );

        updatedLevels.add(updatedLevel);
      }

      final isUnlocked = _isSectionUnlocked(section.sectionNumber, progress);
      final isCompleted = completedLevels == section.levels.length;
      final completionPercentage = completedLevels / section.levels.length;

      final updatedSection = section.copyWith(
        levels: updatedLevels,
        isUnlocked: isUnlocked,
        isCompleted: isCompleted,
        totalStars: sectionStars,
        completionPercentage: completionPercentage,
      );

      updatedSections.add(updatedSection);
    }

    return updatedSections;
  }

  /// Check if a level is unlocked for the user
  static bool _isLevelUnlocked(CampaignLevel level, CampaignProgress progress) {
    // Level 1 is always unlocked
    if (level.levelNumber == 1) return true;
    
    // Current level and previous levels are unlocked
    if (level.sectionNumber < progress.currentSection) return true;
    if (level.sectionNumber == progress.currentSection && 
        level.levelNumber <= progress.currentLevel) return true;
    
    return false;
  }

  /// Check if a section is unlocked for the user
  static bool _isSectionUnlocked(int sectionNumber, CampaignProgress progress) {
    // Section 1 is always unlocked
    if (sectionNumber == 1) return true;
    
    // Current section and previous sections are unlocked
    return sectionNumber <= progress.currentSection;
  }

  /// Get user's results for all levels
  static Future<Map<String, CampaignResult>> _getUserResults() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final querySnapshot = await _db
          .collection('campaign_results')
          .doc(user.uid)
          .collection('levels')
          .get();

      final results = <String, CampaignResult>{};
      for (final doc in querySnapshot.docs) {
        final result = CampaignResult.fromFirestore(doc);
        results[result.levelId] = result;
      }

      return results;
    } catch (e) {
      print('Error fetching user results: $e');
      return {};
    }
  }

  /// Submit a campaign level result
  static Future<CampaignResult> submitLevelResult(
    CampaignLevel level,
    int userGuess,
    Duration timeSpent, {
    BuildContext? context,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Calculate score and accuracy
    final score = _calculateScore(userGuess, level.secretPosition, level.maxScore);
    final accuracy = _calculateAccuracy(userGuess, level.secretPosition);
    final starsEarned = _calculateStars(accuracy);

    // Check if this is a new best result
    final existingResults = await _getUserResults();
    final existingResult = existingResults[level.id];
    final isNewBest = existingResult == null || score > existingResult.score;

    final result = CampaignResult(
      levelId: level.id,
      userId: user.uid,
      userGuess: userGuess,
      score: score,
      accuracy: accuracy,
      starsEarned: starsEarned,
      completedAt: DateTime.now(),
      timeSpent: timeSpent,
      isNewBest: isNewBest,
    );

    try {
      print('Submitting campaign result for ${level.id}, user: ${user.uid}, score: $score, stars: $starsEarned');
      
      // Add timeout to prevent hanging
      return await Future.any([
        _submitResultWithRewards(level, result, existingResult, context),
        Future.delayed(Duration(seconds: 30), () {
          throw Exception('Campaign submission timed out after 30 seconds');
        }),
      ]);
    } catch (e) {
      print('Error submitting campaign result: $e');
      rethrow;
    }
  }

  /// Internal method to submit result with rewards (separated for timeout handling)
  static Future<CampaignResult> _submitResultWithRewards(
    CampaignLevel level,
    CampaignResult result,
    CampaignResult? existingResult,
    BuildContext? context,
  ) async {
    final user = _auth.currentUser!;

    // Store result
    await _db
        .collection('campaign_results')
        .doc(user.uid)
        .collection('levels')
        .doc(level.id)
        .set(result.toFirestore());

    // Update user progress
    await _updateUserProgress(level, result);

    // Award Mind Gems for completion and stars (first time only)
    final isNewBest = existingResult == null || result.score > existingResult.score;
    if (isNewBest) {
      // Base completion reward for first-time level completion
      if (existingResult == null) {
        try {
          await WalletService.awardGems(50, 'campaign_completion', 
            context: context,
            metadata: {
              'levelId': level.id,
              'levelNumber': level.levelNumber,
              'sectionNumber': level.sectionNumber,
            });
        } catch (e) {
          print('Warning: Failed to award completion gems: $e');
        }
      }

      // Star-based Gem rewards (only for new/better star achievements)
      final previousStars = existingResult?.starsEarned ?? 0;
      if (result.starsEarned > previousStars) {
        try {
          await WalletService.awardCampaignStarGems(level.id, result.starsEarned, existingResult == null, context: context);
        } catch (e) {
          print('Warning: Failed to award star gems: $e');
        }
      }
    }

    // Track quest progress with error handling to prevent hanging
    try {
      await QuestService.trackProgress('complete_campaign_level', 
        amount: 1,
        context: context,
        metadata: {
          'levelId': level.id,
          'levelNumber': level.levelNumber,
          'sectionNumber': level.sectionNumber,
          'score': result.score,
          'accuracy': result.accuracy,
          'starsEarned': result.starsEarned,
          'isFirstTime': existingResult == null,
        });
    } catch (e) {
      print('Warning: Failed to track campaign level progress: $e');
    }

    // Track star earning progress
    if (result.starsEarned > 0) {
      try {
        await QuestService.trackProgress('earn_campaign_stars', 
          amount: result.starsEarned,
          context: context,
          metadata: {
            'levelId': level.id,
            'starsEarned': result.starsEarned,
          });
      } catch (e) {
        print('Warning: Failed to track star earning progress: $e');
      }
    }

    // Track perfect score achievement
    if (result.accuracy >= 1.0) {
      try {
        await QuestService.trackProgress('perfect_score', 
          amount: 1,
          context: context,
          metadata: {
            'levelId': level.id,
            'mode': 'campaign',
            'accuracy': result.accuracy,
          });
      } catch (e) {
        print('Warning: Failed to track perfect score progress: $e');
      }
    }

    // Track accuracy-based quests
    try {
      await QuestService.trackProgress('achieve_accuracy', 
        amount: 1,
        context: context,
        metadata: {
          'accuracy': result.accuracy,
          'mode': 'campaign',
        });
    } catch (e) {
      print('Warning: Failed to track accuracy progress: $e');
    }

    // Track section completion (if this completes a section)
    if (_isLevelLastInSection(level)) {
      try {
        await QuestService.trackProgress('complete_campaign_section', 
          amount: 1,
          context: context,
          metadata: {
            'sectionNumber': level.sectionNumber,
          });
      } catch (e) {
        print('Warning: Failed to track section completion progress: $e');
      }
    }

    print('Successfully saved campaign result: ${level.id}');
    return result;
  }

  /// Update user's campaign progress after completing a level
  static Future<void> _updateUserProgress(CampaignLevel level, CampaignResult result) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final progress = await getUserProgress();
      final allResults = await _getUserResults();
      
      // Calculate new progress stats
      int totalStars = 0;
      int levelsCompleted = 0;
      final sectionStars = [0, 0, 0, 0];

      // Add this result to the map for calculations
      allResults[level.id] = result;

      // Calculate stats from all results
      for (final levelResult in allResults.values) {
        levelsCompleted++;
        totalStars += levelResult.starsEarned;
        
        // Find which section this level belongs to
        final levelData = CampaignDatabase.getLevelById(levelResult.levelId);
        if (levelData != null && levelData.sectionNumber >= 1 && levelData.sectionNumber <= 4) {
          sectionStars[levelData.sectionNumber - 1] += levelResult.starsEarned;
        }
      }

      // Calculate next unlocked level
      int nextSection = progress.currentSection;
      int nextLevel = progress.currentLevel;

      // If this was the current level, unlock the next one
      if (level.sectionNumber == progress.currentSection && 
          level.levelNumber == progress.currentLevel) {
        
        if (level.levelNumber < 10) {
          // More levels in current section
          nextLevel = level.levelNumber + 1;
        } else if (level.sectionNumber < 4) {
          // Move to next section if current section is completed with enough stars
          final currentSectionStars = sectionStars[level.sectionNumber - 1];
          if (currentSectionStars >= 22) { // Need >22 points to unlock next section
            nextSection = level.sectionNumber + 1;
            nextLevel = 1;
          }
        }
      }

      final overallProgress = levelsCompleted / 40.0; // 40 total levels

      final updatedProgress = progress.copyWith(
        currentSection: nextSection,
        currentLevel: nextLevel,
        totalStars: totalStars,
        levelsCompleted: levelsCompleted,
        overallProgress: overallProgress,
        lastPlayedAt: DateTime.now(),
        sectionStars: sectionStars,
      );

      await _db
          .collection('campaign_progress')
          .doc(user.uid)
          .set(updatedProgress.toFirestore());

      print('Updated campaign progress: Section $nextSection, Level $nextLevel, Stars: $totalStars');
    } catch (e) {
      print('Error updating campaign progress: $e');
    }
  }

  /// Calculate score based on accuracy (0-100 points)
  static int _calculateScore(int userGuess, int correctPosition, int maxScore) {
    final accuracy = _calculateAccuracy(userGuess, correctPosition);
    return (accuracy * maxScore / 100).round();
  }

  /// Calculate accuracy percentage (0-100%)
  static double _calculateAccuracy(int userGuess, int correctPosition) {
    final difference = (userGuess - correctPosition).abs();
    final maxDifference = math.max(correctPosition, 100 - correctPosition);
    final accuracy = math.max(0, 100 - (difference * 100 / maxDifference));
    return accuracy.toDouble();
  }

  /// Calculate stars based on accuracy (1-3 stars)
  static int _calculateStars(double accuracy) {
    if (accuracy >= 90) return 3; // 3 stars for 90%+ accuracy
    if (accuracy >= 75) return 2; // 2 stars for 75%+ accuracy
    if (accuracy >= 50) return 1; // 1 star for 50%+ accuracy
    return 0; // No stars for less than 50%
  }

  /// Get a specific level with user progress
  static Future<CampaignLevel?> getLevelWithProgress(String levelId) async {
    final level = CampaignDatabase.getLevelById(levelId);
    if (level == null) return null;

    final progress = await getUserProgress();
    final results = await _getUserResults();
    
    final isUnlocked = _isLevelUnlocked(level, progress);
    final result = results[levelId];

    return level.copyWith(
      isUnlocked: isUnlocked,
      starsEarned: result?.starsEarned ?? 0,
      bestScore: result?.score ?? 0,
      bestAccuracy: result?.accuracy ?? 0.0,
    );
  }

  /// Check if user can access a specific level
  static Future<bool> canAccessLevel(String levelId) async {
    final level = await getLevelWithProgress(levelId);
    return level?.isUnlocked ?? false;
  }

  /// Get user's achievements
  static Future<List<CampaignAchievement>> getUserAchievements() async {
    final progress = await getUserProgress();
    final achievements = <CampaignAchievement>[];

    // First Steps - Complete first level
    if (progress.levelsCompleted >= 1) {
      achievements.add(CampaignAchievement.firstLevel);
    }

    // Section Master - Complete first section
    if (progress.currentSection > 1 || 
        (progress.currentSection == 1 && progress.currentLevel > 10)) {
      achievements.add(CampaignAchievement.firstSection);
    }

    // Perfect Level - Get 3 stars on any level
    final results = await _getUserResults();
    if (results.values.any((result) => result.starsEarned == 3)) {
      achievements.add(CampaignAchievement.perfectLevel);
    }

    // Speed Runner - Complete level in under 30 seconds
    if (results.values.any((result) => result.timeSpent.inSeconds < 30)) {
      achievements.add(CampaignAchievement.speedRunner);
    }

    // Star Collector - Earn 50 total stars
    if (progress.totalStars >= 50) {
      achievements.add(CampaignAchievement.starCollector);
    }

    // Campaign Master - Complete entire campaign
    if (progress.levelsCompleted >= 40) {
      achievements.add(CampaignAchievement.campaignMaster);
    }

    return achievements;
  }

  /// Check if this level is the last in its section
  static bool _isLevelLastInSection(CampaignLevel level) {
    // For now, assume each section has 10 levels (1-10, 11-20, 21-30, 31-40)
    // This is a simple check - can be enhanced later with actual section data
    final levelInSection = ((level.levelNumber - 1) % 10) + 1;
    return levelInSection == 10; // Last level in section
  }
}
