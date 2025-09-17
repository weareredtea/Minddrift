// lib/widgets/solo_spectrum_card.dart

import 'package:flutter/material.dart';

/// Solo version of SpectrumCard without the built-in clue display
/// Uses the same UI as the original multiplayer version
class SoloSpectrumCard extends StatelessWidget {
  final Widget child;
  final String? startLabel;
  final String? endLabel;

  const SoloSpectrumCard({
    super.key,
    required this.child,
    this.startLabel,
    this.endLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2D3E).withValues(alpha: 0.8),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NO clue display - this is the key difference from the original SpectrumCard
            
            Flexible(
              child: child, // This is where the RadialSpectrumWidget goes
            ),
            
            if (startLabel != null && endLabel != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      startLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      endLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}