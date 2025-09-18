// lib/screens/practice_mode_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/practice_service.dart';
import '../models/practice_models.dart';
import '../widgets/solo_spectrum_card.dart';
import '../widgets/radial_spectrum.dart';
import '../l10n/app_localizations.dart';

class PracticeModeScreen extends StatefulWidget {
  static const routeName = '/practice';
  
  const PracticeModeScreen({super.key});

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  PracticeChallenge? _currentChallenge;
  double _userGuess = 0.5;
  bool _hasGuessed = false;
  bool _showingResult = false;
  PracticeResult? _lastResult;
  DateTime? _challengeStartTime;
  
  @override
  void initState() {
    super.initState();
    _generateNewChallenge();
  }

  void _generateNewChallenge() {
    setState(() {
      _currentChallenge = PracticeService.generateChallenge();
      _userGuess = 0.5;
      _hasGuessed = false;
      _showingResult = false;
      _lastResult = null;
      _challengeStartTime = DateTime.now();
    });
  }

  void _submitGuess() {
    if (_currentChallenge == null || _hasGuessed) return;

    HapticFeedback.lightImpact();
    
    final timeSpent = DateTime.now().difference(_challengeStartTime!);
    final score = PracticeService.calculateScore(_userGuess, _currentChallenge!.secretPosition);
    final accuracy = PracticeService.calculateAccuracy(_userGuess, _currentChallenge!.secretPosition);
    
    final result = PracticeResult(
      challenge: _currentChallenge!,
      userGuess: _userGuess,
      score: score,
      accuracy: accuracy,
      completedAt: DateTime.now(),
      timeSpent: timeSpent,
    );

    setState(() {
      _hasGuessed = true;
      _showingResult = true;
      _lastResult = result;
    });

    // Record result in background
    PracticeService.recordPracticeResult(result, context: context);
  }

  void _nextChallenge() {
    HapticFeedback.lightImpact();
    _generateNewChallenge();
  }

  Widget _buildChallengeCard() {
    if (_currentChallenge == null) return const SizedBox();

    return Card(
      elevation: 8,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Category display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentChallenge!.leftLabel} ↔ ${_currentChallenge!.rightLabel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'LuckiestGuy',
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Clue display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[300]!, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Clue:',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontFamily: 'Chewy',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${_currentChallenge!.clue}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
    );
  }

  Widget _buildSpectrum() {
    if (_currentChallenge == null) return const SizedBox();

    return Card(
      elevation: 4,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Where does this clue belong?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Chewy',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Spectrum slider
            SizedBox(
              height: 300, // Standard height from original
              child: SoloSpectrumCard(
                startLabel: _currentChallenge!.leftLabel,
                endLabel: _currentChallenge!.rightLabel,
                child: RadialSpectrumWidget(
                  value: _userGuess * 100, // Convert 0-1 to 0-100
                  onChanged: _hasGuessed ? (value) {} : (value) {
                    setState(() {
                      _userGuess = value / 100; // Convert 0-100 back to 0-1
                    });
                  },
                  isReadOnly: _hasGuessed,
                ),
              ),
            ),
            
            // Show secret position and user guess after guessing
            if (_hasGuessed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Your Guess',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontFamily: 'Chewy',
                          ),
                        ),
                        Text(
                          '${(_userGuess * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Correct Answer',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontFamily: 'Chewy',
                          ),
                        ),
                        Text(
                          '${(_currentChallenge!.secretPosition * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Submit button
            if (!_hasGuessed)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitGuess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Guess',
                    style: TextStyle(
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
    if (_lastResult == null || !_showingResult) return const SizedBox();

    final insights = PracticeService.getChallengeInsights(_lastResult!);

    return Card(
      elevation: 8,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreStat(AppLocalizations.of(context)!.score, '${_lastResult!.score}/5', Colors.blue),
                _buildScoreStat(AppLocalizations.of(context)!.accuracy, _lastResult!.accuracyPercentage, Colors.green),
                _buildScoreStat(AppLocalizations.of(context)!.gameTime, '${_lastResult!.timeSpent.inSeconds}s', Colors.orange),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Feedback message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getScoreColor(_lastResult!.score).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getScoreColor(_lastResult!.score), width: 2),
              ),
              child: Text(
                _lastResult!.feedbackMessage,
                style: TextStyle(
                  color: _getScoreColor(_lastResult!.score),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Chewy',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Improvement tip
            Text(
              insights['improvementTip'],
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontFamily: 'Chewy',
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Next challenge button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _nextChallenge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next Challenge',
                  style: TextStyle(
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

  Widget _buildScoreStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
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
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 4) return Colors.green;
    if (score >= 3) return Colors.blue;
    if (score >= 2) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.practiceMode,
          style: const TextStyle(fontFamily: 'LuckiestGuy'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateNewChallenge,
            tooltip: AppLocalizations.of(context)!.newChallenge,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Challenge card
            _buildChallengeCard(),
            
            const SizedBox(height: 16),
            
            // Spectrum slider
            _buildSpectrum(),
            
            const SizedBox(height: 16),
            
            // Result card (shown after guess)
            if (_showingResult) _buildResultCard(),
          ],
        ),
      ),
    );
  }
}
