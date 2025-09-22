// lib/screens/campaign_level_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/campaign_service.dart';
import '../models/campaign_models.dart';
import '../data/category_data.dart';
import '../widgets/solo_spectrum_card.dart';
import '../widgets/radial_spectrum.dart';
import '../l10n/app_localizations.dart';
// Removed unused import

class CampaignLevelScreen extends StatefulWidget {
  static const routeName = '/campaign-level';
  
  const CampaignLevelScreen({super.key});

  @override
  State<CampaignLevelScreen> createState() => _CampaignLevelScreenState();
}

class _CampaignLevelScreenState extends State<CampaignLevelScreen>
    with TickerProviderStateMixin {
  CampaignLevel? _level;
  double _currentValue = 50.0;
  bool _hasSubmitted = false;
  bool _isSubmitting = false;
  CampaignResult? _result;
  DateTime? _startTime;
  
  late AnimationController _pulseController;
  late AnimationController _resultController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOutCubic,
    ));
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

  String _getLocalizedDifficulty(String difficulty) {
    final loc = AppLocalizations.of(context)!;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return loc.easy;
      case 'medium':
        return loc.medium;
      case 'hard':
        return loc.hard;
      case 'expert':
        return loc.expert;
      default:
        return difficulty.toUpperCase();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_level == null) {
      _level = ModalRoute.of(context)!.settings.arguments as CampaignLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_level == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          _level!.title,
          style: TextStyle(
            fontFamily: _getHeaderFont(),
            fontSize: 20,
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
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getDifficultyColor(_level!.difficulty),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getLocalizedDifficulty(_level!.difficulty),
              style: TextStyle(
                fontFamily: _getHeaderFont(),
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasSubmitted && _result != null) {
      return _buildResultScreen();
    }
    
    return _buildGameScreen();
  }

  Widget _buildGameScreen() {
    final category = allCategories.firstWhere(
      (cat) => cat.id == _level!.categoryId,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Level info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getSectionColor(_level!.sectionNumber),
                  _getSectionColor(_level!.sectionNumber).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '${AppLocalizations.of(context)!.level} ${_level!.levelNumber}',
                  style: TextStyle(
                    fontFamily: _getHeaderFont(),
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _level!.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _getBodyFont(),
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                if (_level!.bestScore > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: List.generate(3, (index) {
                            return Icon(
                              index < _level!.starsEarned ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${AppLocalizations.of(context)!.best}: ${_level!.bestScore}',
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
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Category display
          /*Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Text(
                  _getCategoryDisplayName(_level!.categoryId),
                  style: TextStyle(
                    fontFamily: _getHeaderFont(),
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.getLeftText('en'),
                      style: TextStyle(
                        fontFamily: _getBodyFont(),
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      category.getRightText('en'),
                      style: TextStyle(
                        fontFamily: _getBodyFont(),
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),*/
          
          const SizedBox(height: 32),
          
          // Clue display
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.yourClue,
                        style: TextStyle(
                          fontFamily: _getHeaderFont(),
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"${_level!.getClue(Localizations.localeOf(context).languageCode)}"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: _getBodyFont(),
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Radial Spectrum Widget
          SizedBox(
            height: 300, // Standard height from original
            child: SoloSpectrumCard(
              startLabel: category.getLeftText(Localizations.localeOf(context).languageCode),
              endLabel: category.getRightText(Localizations.localeOf(context).languageCode),
              child: RadialSpectrumWidget(
                value: _currentValue,
                onChanged: _isSubmitting ? (value) {} : (value) {
                  setState(() {
                    _currentValue = value;
                  });
                  HapticFeedback.selectionClick();
                },
                isReadOnly: _isSubmitting,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitGuess,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getSectionColor(_level!.sectionNumber),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.submitGuess,
                      style: TextStyle(
                        fontFamily: _getHeaderFont(),
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Result animation
          SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getResultColor(_result!.starsEarned),
                      _getResultColor(_result!.starsEarned).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getResultColor(_result!.starsEarned).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _getResultTitle(_result!.starsEarned),
                      style: TextStyle(
                        fontFamily: _getHeaderFont(),
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 200 + (index * 100)),
                          child: Icon(
                            index < _result!.starsEarned ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Score details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                //_buildScoreRow('Your Guess', '${_result!.userGuess}'),
               // _buildScoreRow('Correct Answer', '${_level!.secretPosition}'),
                _buildScoreRow('Accuracy', '${_result!.accuracy.toStringAsFixed(1)}%'),
                _buildScoreRow('Score', '${_result!.score}/${_level!.maxScore}'),
                _buildScoreRow('Time', '${_result!.timeSpent.inSeconds}s'),
                if (_result!.isNewBest) ...[
                  const Divider(color: Colors.white24),
                  Text(
                    '🎉 New Personal Best!',
                    style: TextStyle(
                      fontFamily: _getHeaderFont(),
                      fontSize: 16,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _tryAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getSectionColor(_level!.sectionNumber),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      fontFamily: _getHeaderFont(),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _backToCampaign,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Back to Campaign',
                    style: TextStyle(
                      fontFamily: _getHeaderFont(),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: _getBodyFont(),
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: _getHeaderFont(),
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return Colors.green;
      case 'medium': return Colors.orange;
      case 'hard': return Colors.red;
      case 'expert': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Color _getResultColor(int stars) {
    switch (stars) {
      case 3: return Colors.green;
      case 2: return Colors.orange;
      case 1: return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _getResultTitle(int stars) {
    switch (stars) {
      case 3: return 'PERFECT!';
      case 2: return 'GREAT JOB!';
      case 1: return 'GOOD TRY!';
      default: return 'TRY AGAIN!';
    }
  }

  Future<void> _submitGuess() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final timeSpent = DateTime.now().difference(_startTime!);
      final result = await CampaignService.submitLevelResult(
        _level!,
        _currentValue.round(),
        timeSpent,
        context: context,
      );

      setState(() {
        _result = result;
        _hasSubmitted = true;
        _isSubmitting = false;
      });

      // Start result animation
      _resultController.forward();

      // Haptic feedback based on performance
      if (result.starsEarned >= 3) {
        HapticFeedback.heavyImpact();
      } else if (result.starsEarned >= 2) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorSubmittingResult}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _tryAgain() {
    setState(() {
      _hasSubmitted = false;
      _result = null;
      _currentValue = 50.0;
      _startTime = DateTime.now();
    });
    
    _resultController.reset();
    HapticFeedback.lightImpact();
  }

  void _backToCampaign() {
    Navigator.of(context).pop(true); // Return true to indicate level was played
  }

}