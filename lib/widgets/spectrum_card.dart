// lib/widgets/spectrum_card.dart

import 'dart:math';

import 'package:flutter/material.dart';

class SpectrumCard extends StatelessWidget {
  final Widget child;
  final String? clue;
  final String? startLabel;
  final String? endLabel;

  const SpectrumCard({
    super.key,
    required this.child,
    this.clue,
    this.startLabel,
    this.endLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
              color: const Color(0xFF2A2D3E).withValues(alpha: 0.8),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            if (clue != null) ...[
              Text(
                '"$clue"',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            
            child, // This is where the RadialSpectrumWidget goes
            
            if (startLabel != null && endLabel != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CategoryTag(label: startLabel!, color: const Color.fromARGB(255, 255, 255, 255)),
                  CategoryTag(label: endLabel!, color: const Color.fromARGB(255, 255, 255, 255)),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class CategoryTag extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;      // ← new!


  const CategoryTag({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 50,
          height: 6,
          child: CustomPaint(
            painter: UnderlinePainter(color: color),
          ),
        ),
      ],
    );
  }
}

class UnderlinePainter extends CustomPainter {
   final Color color;
  final int segments;      // how many points to sample along the width
  final double amplitude;  // max vertical jitter in each direction
  final int strokes;       // how many overlapping passes
  
  UnderlinePainter({
    required this.color,
    this.segments = 8,
    this.amplitude = 2.0,
    this.strokes = 2,
  }) : _rnd = Random();

  final Random _rnd;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
                ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw multiple strokes, each slightly offset
    for (var s = 0; s < strokes; s++) {
      final path = Path();
      // base y-position (you can adjust the 0.6 factor)
      final baseY = size.height * 0.6 + (s - (strokes - 1) / 2) * 1.5;

      path.moveTo(0, baseY);
      for (var i = 1; i <= segments; i++) {
        final x = size.width * i / segments;
        // jitter y by up to ±amplitude
        final y = baseY + (_rnd.nextDouble() * 2 - 1) * amplitude;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
