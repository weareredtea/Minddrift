// lib/utils/data_export_helper.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';

/// Helper class for exporting analytics data in different formats
class DataExportHelper {
  
  /// Export analytics data as JSON string
  static Future<String> exportAsJson() async {
    final data = await AnalyticsService.exportAllData();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Export analytics data as CSV string
  static Future<String> exportAsCSV() async {
    final data = await AnalyticsService.exportAllData();
    
    final csvLines = <String>[];
    
    // Header
    csvLines.add('Metric,Value,Category');
    
    // User Overview
    final userOverview = data['userOverview'] as Map<String, dynamic>;
    csvLines.add('Total Users,${userOverview['totalUsers']},User Overview');
    csvLines.add('Active Today,${userOverview['activeToday']},User Overview');
    csvLines.add('Active This Week,${userOverview['activeThisWeek']},User Overview');
    csvLines.add('New Users (7 days),${userOverview['newUsers']},User Overview');
    csvLines.add('Retention Rate,${(userOverview['retentionRate'] * 100).toStringAsFixed(1)}%,User Overview');
    
    // Gameplay Stats
    final gameplayStats = data['gameplayStats'] as Map<String, dynamic>;
    csvLines.add('Total Games,${gameplayStats['totalGames']},Gameplay');
    csvLines.add('Average Score,${gameplayStats['averageScore']},Gameplay');
    csvLines.add('Perfect Score Rate,${(gameplayStats['perfectScoreRate'] * 100).toStringAsFixed(1)}%,Gameplay');
    csvLines.add('Practice Games,${gameplayStats['practiceGames']},Gameplay');
    csvLines.add('Daily Challenge Games,${gameplayStats['dailyChallengeGames']},Gameplay');
    
    // Economic Data
    final economicData = data['economicData'] as Map<String, dynamic>;
    csvLines.add('Total Gems Earned,${economicData['totalGemsEarned']},Economy');
    csvLines.add('Total Gems Spent,${economicData['totalGemsSpent']},Economy');
    csvLines.add('Average Wallet,${economicData['averageWallet']},Economy');
    csvLines.add('Conversion Rate,${(economicData['conversionRate'] * 100).toStringAsFixed(1)}%,Economy');
    csvLines.add('Active Spenders,${economicData['activeSpenders']},Economy');
    
    // Engagement Data
    final engagementData = data['engagementData'] as Map<String, dynamic>;
    csvLines.add('Total Quests Completed,${engagementData['totalQuestsCompleted']},Engagement');
    csvLines.add('Total Campaign Stars,${engagementData['totalCampaignStars']},Engagement');
    csvLines.add('Average Campaign Progress,${engagementData['averageCampaignProgress']},Engagement');
    csvLines.add('Average Daily Streak,${engagementData['averageDailyStreak']},Engagement');
    csvLines.add('Max Daily Streak,${engagementData['maxDailyStreak']},Engagement');
    
    return csvLines.join('\n');
  }

  /// Copy data to clipboard in specified format
  static Future<void> copyToClipboard(String format) async {
    String data;
    
    switch (format.toLowerCase()) {
      case 'csv':
        data = await exportAsCSV();
        break;
      case 'json':
      default:
        data = await exportAsJson();
        break;
    }
    
    await Clipboard.setData(ClipboardData(text: data));
  }

  /// Generate analytics summary report
  static Future<String> generateSummaryReport() async {
    final data = await AnalyticsService.exportAllData();
    final userOverview = data['userOverview'] as Map<String, dynamic>;
    final gameplayStats = data['gameplayStats'] as Map<String, dynamic>;
    final economicData = data['economicData'] as Map<String, dynamic>;
    final engagementData = data['engagementData'] as Map<String, dynamic>;
    
    return '''
=== MINDDRIFT ANALYTICS SUMMARY ===
Generated: ${DateTime.now().toString().substring(0, 19)}

📊 USER METRICS
• Total Users: ${userOverview['totalUsers']}
• Active Today: ${userOverview['activeToday']}
• Active This Week: ${userOverview['activeThisWeek']}
• New Users (7 days): ${userOverview['newUsers']}
• Retention Rate: ${(userOverview['retentionRate'] * 100).toStringAsFixed(1)}%

🎮 GAMEPLAY METRICS
• Total Games Played: ${gameplayStats['totalGames']}
• Average Score: ${gameplayStats['averageScore']}/5
• Perfect Score Rate: ${(gameplayStats['perfectScoreRate'] * 100).toStringAsFixed(1)}%
• Practice Games: ${gameplayStats['practiceGames']}
• Daily Challenges: ${gameplayStats['dailyChallengeGames']}

💎 ECONOMIC METRICS
• Total Gems Earned: ${economicData['totalGemsEarned']}
• Total Gems Spent: ${economicData['totalGemsSpent']}
• Average Wallet: ${economicData['averageWallet']} gems
• Conversion Rate: ${(economicData['conversionRate'] * 100).toStringAsFixed(1)}%
• Active Spenders: ${economicData['activeSpenders']}

🎯 ENGAGEMENT METRICS
• Quests Completed: ${engagementData['totalQuestsCompleted']}
• Campaign Stars: ${engagementData['totalCampaignStars']}
• Avg Campaign Level: ${engagementData['averageCampaignProgress']}
• Avg Daily Streak: ${engagementData['averageDailyStreak']}
• Max Daily Streak: ${engagementData['maxDailyStreak']} days

=== END REPORT ===
    ''';
  }
}
