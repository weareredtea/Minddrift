// lib/screens/spectrum_ui_showcase_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minddrift/widgets/spectrum_card.dart';
import 'package:minddrift/widgets/radial_spectrum.dart';
import 'package:minddrift/widgets/unified_spectrum.dart';
import 'package:minddrift/theme/app_theme.dart';

class SpectrumUIShowcaseScreen extends StatefulWidget {
  const SpectrumUIShowcaseScreen({super.key});

  @override
  State<SpectrumUIShowcaseScreen> createState() => _SpectrumUIShowcaseScreenState();
}

class _SpectrumUIShowcaseScreenState extends State<SpectrumUIShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _currentValue = 50.0;
  String _clue = "Sample clue text for testing the spectrum card UI";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spectrum UI Showcase'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'NEW Unified'),
            Tab(text: 'OLD Default'),
            Tab(text: 'OLD Training'),
            Tab(text: 'OLD Campaign'),
            Tab(text: 'OLD Daily'),
            Tab(text: 'OLD Multi'),
            Tab(text: 'OLD Results'),
            Tab(text: 'Comparison'),
            Tab(text: 'Tab 9'),
            Tab(text: 'Tab 10'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewUnifiedTab(),
          _buildOldDefaultTab(),
          _buildOldTrainingTab(),
          _buildOldCampaignTab(),
          _buildOldDailyTab(),
          _buildOldMultiTab(),
          _buildOldResultsTab(),
          _buildComparisonTab(),
          _buildPlaceholderTab('Tab 9'),
          _buildPlaceholderTab('Tab 10'),
        ],
      ),
    );
  }

  // Tab 1: NEW Unified Spectrum Design
  Widget _buildNewUnifiedTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'NEW: Unified Spectrum Design',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gold arc, unified spacing, single card structure',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Single Card with new unified design
          Card(
            color: const Color(0xFF1A1A2E), // New dark background
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: UnifiedSpectrum(
                clue: _clue,
                startLabel: 'Cold',
                endLabel: 'Hot',
                value: _currentValue,
                onChanged: (value) {
                  setState(() {
                    _currentValue = value;
                  });
                },
                showClue: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: OLD Default Radial Spectrum Card
  Widget _buildOldDefaultTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'OLD: Default Radial Spectrum Card',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Teal arc, nested cards, inconsistent spacing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SpectrumCard(
            clue: _clue,
            startLabel: 'Cold',
            endLabel: 'Hot',
            child: RadialSpectrumWidget(
              value: _currentValue,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: OLD Training Mode Default
  Widget _buildOldTrainingTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'OLD: Training Mode - Default State',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          // Copy the exact UI from practice_mode_screen.dart
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Text(
                  _clue,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RadialSpectrumWidget(
                  value: _currentValue,
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cold',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Hot',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 16,
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

  // Tab 4: OLD Campaign Mode Default
  Widget _buildOldCampaignTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'OLD: Campaign Mode - Default State',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          // Copy the exact UI from practice_mode_screen.dart after submit
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Text(
                  _clue,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RadialSpectrumWidget(
                  value: _currentValue,
                  onChanged: (value) {}, // Disabled after submit
                  isReadOnly: true,
                  secretValue: 75.0, // Sample correct value
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cold',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Hot',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'Your guess: ${_currentValue.round()}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 5: OLD Daily Challenge Mode Default
  Widget _buildOldDailyTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'OLD: Daily Challenge - Default State',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          // Copy the exact UI from campaign_level_screen.dart
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Text(
                  'Your Clue:',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _clue,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RadialSpectrumWidget(
                  value: _currentValue,
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cold',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Hot',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 16,
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

  // Tab 6: OLD Multiplayer Navigator Writing Clue
  Widget _buildOldMultiTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'OLD: Multiplayer - Navigator Writing Clue',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          // Copy the exact UI from daily_challenge_screen.dart
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
                  'Today\'s guide:',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$_clue"',
                  style: TextStyle(
                    color: Colors.amber[300],
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RadialSpectrumWidget(
                  value: _currentValue,
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cold',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Hot',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 16,
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

  // Tab 7: OLD Multiplayer Round Results
  Widget _buildOldResultsTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'OLD: Multiplayer - Round Results',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          // Copy the exact UI from waiting_clue_screen.dart for navigator
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Text(
                  'Write your clue:',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your clue...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),
                RadialSpectrumWidget(
                  value: _currentValue,
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cold',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Hot',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 16,
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

  // Tab 8: Side-by-Side Comparison
  Widget _buildComparisonTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Side-by-Side Comparison',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'OLD vs NEW Design',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                // OLD Design
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'OLD Design',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SpectrumCard(
                          clue: _clue,
                          startLabel: 'Cold',
                          endLabel: 'Hot',
                          child: RadialSpectrumWidget(
                            value: _currentValue,
                            onChanged: (value) {
                              setState(() {
                                _currentValue = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // NEW Design
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'NEW Design',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Card(
                          color: const Color(0xFF1A1A2E),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: UnifiedSpectrum(
                              clue: _clue,
                              startLabel: 'Cold',
                              endLabel: 'Hot',
                              value: _currentValue,
                              onChanged: (value) {
                                setState(() {
                                  _currentValue = value;
                                });
                              },
                              showClue: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Placeholder tabs
  Widget _buildPlaceholderTab(String title) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title - Coming Soon',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
