// lib/screens/campaign_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/campaign_service.dart';
import '../models/campaign_models.dart';
import '../l10n/app_localizations.dart';
import 'campaign_level_screen.dart';
// Removed unused import

class CampaignScreen extends StatefulWidget {
  static const routeName = '/campaign';
  
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  List<CampaignSection> _sections = [];
  CampaignProgress? _progress;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaignData();
  }

  // Helper methods to get correct font family based on locale
  String _getHeaderFont() {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? 'Beiruti' : 'LuckiestGuy';
  }

  String _getBodyFont() {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? 'Harmattan' : 'Chewy';
  }

  Future<void> _loadCampaignData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final sections = await CampaignService.getCampaignWithProgress();
      final progress = await CampaignService.getUserProgress();

      setState(() {
        _sections = sections;
        _progress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load campaign: $e'; // Will be localized in UI
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
          AppLocalizations.of(context)!.campaignMode,
          style: TextStyle(
            fontFamily: _getHeaderFont(),
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
        actions: [
          if (_progress != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${_progress!.totalStars}',
                      style: TextStyle(
                        fontFamily: _getHeaderFont(),
                        fontSize: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.loadingCampaign,
              style: TextStyle(
                fontFamily: _getBodyFont(),
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
              _error!.startsWith('Failed to load campaign:') 
                  ? '${AppLocalizations.of(context)!.failedToLoadCampaign}: ${_error!.split(': ').skip(1).join(': ')}'
                  : _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _getBodyFont(),
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCampaignData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: TextStyle(fontFamily: _getHeaderFont()),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCampaignData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressHeader(),
            const SizedBox(height: 24),
            _buildSectionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    if (_progress == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5ACD), Color(0xFF483D8B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              AppLocalizations.of(context)!.progress,
              style: TextStyle(
                fontFamily: _getHeaderFont(),
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Section ${_progress!.currentSection}',
                      style: TextStyle(
                        fontFamily: _getBodyFont(),
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.level} ${_progress!.currentLevel}',
                      style: TextStyle(
                        fontFamily: _getHeaderFont(),
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${_progress!.totalStars}/${_progress!.maxStars}',
                        style: TextStyle(
                          fontFamily: _getHeaderFont(),
                          fontSize: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_progress!.levelsCompleted}/${_progress!.totalLevels} ${AppLocalizations.of(context)!.levels}',
                    style: TextStyle(
                      fontFamily: _getBodyFont(),
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progress!.overallProgress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progress!.overallProgress * 100).toInt()}% ${AppLocalizations.of(context)!.complete}',
            style: TextStyle(
              fontFamily: _getBodyFont(),
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.campaignSections,
          style: TextStyle(
            fontFamily: _getHeaderFont(),
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sections.length,
          itemBuilder: (context, index) {
            return _buildSectionCard(_sections[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSectionCard(CampaignSection section) {
    final isLocked = !section.isUnlocked;
    final needsStars = section.sectionNumber > 1 && 
                     _progress != null && 
                     section.sectionNumber > _progress!.currentSection;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: isLocked ? Colors.grey[800] : const Color(0xFF2A2A4A),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isLocked ? Colors.grey : _getSectionColor(section.sectionNumber),
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLocked ? null : () => _showSectionLevels(section),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getSectionColor(section.sectionNumber),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${AppLocalizations.of(context)!.section} ${section.sectionNumber}',
                        style: TextStyle(
                          fontFamily: _getHeaderFont(),
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isLocked)
                      const Icon(Icons.lock, color: Colors.grey)
                    else if (section.isCompleted)
                      const Icon(Icons.check_circle, color: Colors.green)
                    else
                      Text(
                        '${section.totalStars}/${section.maxStars}',
                        style: TextStyle(
                          fontFamily: _getHeaderFont(),
                          fontSize: 16,
                          color: Colors.amber,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  section.title,
                  style: TextStyle(
                    fontFamily: _getHeaderFont(),
                    fontSize: 20,
                    color: isLocked ? Colors.grey : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  section.description,
                  style: TextStyle(
                    fontFamily: _getBodyFont(),
                    fontSize: 14,
                    color: isLocked ? Colors.grey[600] : Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                if (!isLocked) ...[
                  LinearProgressIndicator(
                    value: section.completionPercentage,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(_getSectionColor(section.sectionNumber)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(section.completionPercentage * 100).toInt()}% ${AppLocalizations.of(context)!.complete}',
                    style: TextStyle(
                      fontFamily: _getBodyFont(),
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ] else if (needsStars) ...[
                  Text(
                    AppLocalizations.of(context)!.completePreviousSectionToUnlock,
                    style: TextStyle(
                      fontFamily: _getBodyFont(),
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSectionColor(int sectionNumber) {
    switch (sectionNumber) {
      case 1: return Colors.green;
      case 2: return Colors.blue;
      case 3: return Colors.orange;
      case 4: return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showSectionLevels(CampaignSection section) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLevelsBottomSheet(section),
    );
  }

  Widget _buildLevelsBottomSheet(CampaignSection section) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: TextStyle(
                          fontFamily: _getHeaderFont(),
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        section.description,
                        style: TextStyle(
                          fontFamily: _getBodyFont(),
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSectionColor(section.sectionNumber),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${section.totalStars}/${section.maxStars}',
                        style: TextStyle(
                          fontFamily: _getHeaderFont(),
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Levels grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: section.levels.length,
                itemBuilder: (context, index) {
                  return _buildLevelButton(section.levels[index]);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLevelButton(CampaignLevel level) {
    final isLocked = !level.isUnlocked;
    final isCompleted = level.starsEarned > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: isLocked ? null : () => _playLevel(level),
      child: Container(
        decoration: BoxDecoration(
          color: isLocked 
              ? Colors.grey[800]
              : isCompleted
                  ? _getSectionColor(level.sectionNumber).withOpacity(0.3)
                  : const Color(0xFF2A2A4A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked 
                ? Colors.grey
                : _getSectionColor(level.sectionNumber),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLocked)
              const Icon(Icons.lock, color: Colors.grey, size: 20)
            else
              Text(
                '${level.levelNumber}',
                style: TextStyle(
                  fontFamily: _getHeaderFont(),
                  fontSize: 16,
                  color: isCompleted ? Colors.white : Colors.white70,
                ),
              ),
            if (isCompleted) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (starIndex) {
                  return Icon(
                    starIndex < level.starsEarned ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 12,
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _playLevel(CampaignLevel level) async {
    HapticFeedback.lightImpact();
    
    // Close the bottom sheet first
    Navigator.of(context).pop();
    
    // Navigate to level screen
    final result = await Navigator.of(context).pushNamed(
      CampaignLevelScreen.routeName,
      arguments: level,
    );
    
    // Refresh data if level was completed
    if (result == true) {
      await _loadCampaignData();
    }
  }
}
