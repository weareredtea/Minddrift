// lib/screens/wave_spectrum_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/wave_spectrum.dart';
import '../widgets/radial_spectrum.dart';

class WaveSpectrumTestScreen extends StatefulWidget {
  static const routeName = '/wave-spectrum-test';
  
  const WaveSpectrumTestScreen({super.key});

  @override
  State<WaveSpectrumTestScreen> createState() => _WaveSpectrumTestScreenState();
}

class _WaveSpectrumTestScreenState extends State<WaveSpectrumTestScreen> {
  double _currentValue = 50.0;
  double? _secretValue = 75.0;
  bool _showSecret = true;
  bool _isReadOnly = false;
  bool _showRadialSpectrum = true;

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Not Available'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'This screen is only available in debug mode.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Wave Spectrum Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Spectrum Design Comparison',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Compare the new wave-style vs current radial spectrum',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Wave Spectrum
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Wave Spectrum (New)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  WaveSpectrum(
                    value: _currentValue,
                    secretValue: _showSecret ? _secretValue : null,
                    isReadOnly: _isReadOnly,
                    leftCategory: 'Ice Cold',
                    rightCategory: 'Burning Hot',
                    onChanged: (value) {
                      setState(() {
                        _currentValue = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Radial Spectrum
            if (_showRadialSpectrum) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Radial Spectrum (Current)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: RadialSpectrumWidget(
                        value: _currentValue,
                        secretValue: _showSecret ? _secretValue : null,
                        isReadOnly: _isReadOnly,
                        onChanged: (value) {
                          setState(() {
                            _currentValue = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ice Cold',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Burning Hot',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            const SizedBox(height: 32),
            
            // Controls
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Controls',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Current Value Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Value:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '${_currentValue.round()}',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Secret Value Display
                  if (_showSecret) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Secret Value:',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '${_secretValue!.round()}',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Toggle switches
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: Text(
                            'Show Secret',
                            style: TextStyle(color: Colors.white70),
                          ),
                          value: _showSecret,
                          onChanged: (value) {
                            setState(() {
                              _showSecret = value;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: Text(
                            'Read Only',
                            style: TextStyle(color: Colors.white70),
                          ),
                          value: _isReadOnly,
                          onChanged: (value) {
                            setState(() {
                              _isReadOnly = value;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Show Radial Spectrum toggle
                  SwitchListTile(
                    title: Text(
                      'Show Radial Spectrum for Comparison',
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: _showRadialSpectrum,
                    onChanged: (value) {
                      setState(() {
                        _showRadialSpectrum = value;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reset button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentValue = 50.0;
                          _secretValue = 75.0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reset to Default'),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Test Instructions',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Tap or drag on either spectrum to change the value\n'
                    '• Toggle "Show Secret" to see/hide the secret marker\n'
                    '• Toggle "Read Only" to test non-interactive mode\n'
                    '• Toggle "Show Radial Spectrum" to compare designs\n'
                    '• Use "Reset" to return to default values\n'
                    '• Both spectrums are synchronized - change one, both update',
                    style: TextStyle(color: Colors.blue.shade200, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
