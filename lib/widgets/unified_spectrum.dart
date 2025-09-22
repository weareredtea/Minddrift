// lib/widgets/unified_spectrum.dart

import 'package:flutter/material.dart';
import 'package:minddrift/widgets/radial_spectrum.dart';

/// Unified spectrum widget that provides consistent UI across all game modes
/// This widget is NOT a Card itself - it's a transparent layout container
/// The parent screen should place it inside a single Card to avoid nesting
class UnifiedSpectrum extends StatelessWidget {
  final String? clue;
  final String startLabel;
  final String endLabel;
  final double value;
  final double? secretValue;
  final bool isReadOnly;
  final Function(double) onChanged;
  final bool showClue;

  const UnifiedSpectrum({
    super.key,
    this.clue,
    required this.startLabel,
    required this.endLabel,
    required this.value,
    this.secretValue,
    this.isReadOnly = false,
    required this.onChanged,
    this.showClue = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. Clue Text (optional)
        if (showClue && clue != null) ...[
          Text(
            '"$clue"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontFamily: 'Chewy',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],

        // 2. The Spectrum Arc with NEW GOLD COLOR
        RadialSpectrumWidget(
          value: value,
          secretValue: secretValue,
          isReadOnly: isReadOnly,
          onChanged: onChanged,
          arcColor: const Color.fromARGB(255, 255, 157, 0), // NEW GOLD COLOR
          needleColor: Colors.white,
          backgroundColor: const Color(0xFF1A1A2E),
          trackColor: const Color(0xFF2A2A4A),
          size: 280,
        ),

        const SizedBox(height: 16),

        // 3. Category Labels with animated CategoryTag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CategoryTag(
                label: startLabel,
                color: const Color(0xFF4FC3F7), // Blue for start
              ),
            ),
            const SizedBox(width: 150), // Space for the spectrum
            Expanded(
              child: CategoryTag(
                label: endLabel,
                color: const Color(0xFFEF5350), // Red for end
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated category tag with underline effect
class CategoryTag extends StatefulWidget {
  final String label;
  final Color color;
  final double fontSize;

  const CategoryTag({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 20,
  });

  @override
  State<CategoryTag> createState() => _CategoryTagState();
}

class _CategoryTagState extends State<CategoryTag> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8), // Optimal duration for smooth flow
      vsync: this,
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.color,
                fontWeight: FontWeight.bold,
                fontFamily: 'Chewy',
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: widget.label.length * 12.0, // Dynamic width based on text
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color.withOpacity(0.0),
                    widget.color,
                    widget.color.withOpacity(0.0),
                  ],
                  stops: [
                    (_animationController.value - 0.1).clamp(0.0, 1.0),
                    _animationController.value,
                    (_animationController.value + 0.1).clamp(0.0, 1.0),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        );
      },
    );
  }
}
