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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (clue != null) ...[
              Flexible(
                child: Text(
                  '"$clue"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      //fontSize: 24,
                    ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              //const SizedBox(height: 16),
            ],
            
            Flexible(
              child: child, // This is where the RadialSpectrumWidget goes
            ),
            
            if (startLabel != null && endLabel != null) ...[
              //const SizedBox(height: 16),
              Flexible(
                child: Directionality(
                  textDirection: TextDirection.ltr, // Force LTR to prevent RTL reversal
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CategoryTag(
                          label: startLabel!, 
                          color: const Color.fromARGB(255, 255, 255, 255)
                        ),
                      ),
                      const SizedBox(width: 150),
                      Expanded(
                        child: CategoryTag(
                          label: endLabel!, 
                          color: const Color.fromARGB(255, 255, 255, 255)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            widget.label.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: widget.color,
              letterSpacing: 1.1,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SizedBox(
              width: 50,
              height: 12,
              child: CustomPaint(
                painter: UnderlinePainter(
                  color: widget.color,
                  time: _animationController.value * 6 * pi, // Extended range for smoother transition
                ),
              ),
            );
          },
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
  final double time;       // time-based animation
  
  UnderlinePainter({
    required this.color,
    this.segments = 8,
    this.amplitude = 2.0,
    this.strokes = 2,
    required this.time,
  });

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
        // Create smooth, continuous wave motion that flows seamlessly
        final waveOffset = sin((x / size.width) * 4 * pi + time) * amplitude;
        final y = baseY + waveOffset;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) {
    return old is! UnderlinePainter || old.time != time;
  }
}
