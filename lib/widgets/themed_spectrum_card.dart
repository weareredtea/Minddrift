// lib/widgets/themed_spectrum_card.dart

import 'package:flutter/material.dart';
import '../models/spectrum_skin.dart';
import '../services/skin_manager.dart';
import 'radial_spectrum.dart';

/// Performance-optimized spectrum card with skinning support
class ThemedSpectrumCard extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final String? clueText;
  final double size;
  final bool showClue;

  const ThemedSpectrumCard({
    super.key,
    required this.value,
    required this.onChanged,
    this.clueText,
    this.size = 280,
    this.showClue = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get current skin (cached for performance)
    final skinId = SkinManager.getCurrentSkinId();
    final skin = SpectrumSkinCatalog.getSkinById(skinId);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: skin.backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: skin.trackColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: skin.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main spectrum widget with themed colors
          RadialSpectrumWidget(
            value: value,
            onChanged: onChanged,
            size: size - 20,
            // Apply skin colors
            arcColor: skin.primaryColor,
            needleColor: skin.needleColor,
            backgroundColor: Colors.transparent, // Already handled by container
            trackColor: skin.trackColor,
          ),
          
          // Clue text (if provided and enabled)
          if (showClue && clueText != null)
            Positioned(
              bottom: size * 0.15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: skin.backgroundColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: skin.primaryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  clueText!,
                  style: TextStyle(
                    color: skin.needleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Chewy',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Solo version without clue (for practice/campaign/daily)
class ThemedSoloSpectrumCard extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final double size;

  const ThemedSoloSpectrumCard({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedSpectrumCard(
      value: value,
      onChanged: onChanged,
      size: size,
      showClue: false, // No clue for solo modes
    );
  }
}
