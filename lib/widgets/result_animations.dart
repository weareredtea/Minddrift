// lib/widgets/result_animations.dart

import 'dart:math';
import 'package:flutter/material.dart';

import 'package:simple_animations/simple_animations.dart';
import '../l10n/app_localizations.dart';

// 1. "Bullseye!" Text Animation (Unchanged)
class BullseyeAnimation extends StatelessWidget {
  const BullseyeAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (0.4 * sin(value * pi * 3)),
          child: Opacity(opacity: 1.0 - value, child: child),
        );
      },
      child: Text(AppLocalizations.of(context)?.bullseye ?? 'Bullseye!', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.amber.shade700, shadows: const [Shadow(blurRadius: 10, color: Colors.black54)])));
  }
}

// 2. Thumbs-Up Animation (REVERTED to old style)
class ThumbsUpAnimation extends StatelessWidget {
  const ThumbsUpAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return LoopAnimationBuilder<int>(
      tween: ConstantTween(1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        // This helper creates single particles in a sequence
        return const _FloatingParticle(
          icon: Icons.recommend, // Kept the improved icon
          color: Colors.lightBlueAccent,
        );
      },
    );
  }
}

// 3. Gentle Poof Animation (Unchanged)
class GentlePoofAnimation extends StatelessWidget {
  const GentlePoofAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(opacity: 1.0 - value, child: Transform.scale(scale: 1.0 + value * 2, child: child));
      },
      child: Icon(Icons.cloud_circle_outlined, color: Colors.grey.withOpacity(0.5), size: 150),
    );
  }
}

// 4. Tumbleweed Animation (REVERTED to old style)
class TumbleweedAnimation extends StatefulWidget {
  const TumbleweedAnimation({super.key});
  @override
  State<TumbleweedAnimation> createState() => _TumbleweedAnimationState();
}
class _TumbleweedAnimationState extends State<TumbleweedAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    // This animation slides the widget from 1.5x its width off-screen left to 1.5x off-screen right
    _animation = Tween<Offset>(begin: const Offset(-1.5, 0.8), end: const Offset(1.5, 0.8)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: RotationTransition(
        turns: _controller,
        // Kept the cluster of leaves to look more like a tumbleweed
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🍂', style: TextStyle(fontSize: 40)),
            Text('🍂', style: TextStyle(fontSize: 60)),
            Text('🍂', style: TextStyle(fontSize: 40)),
          ],
        ),
      ),
    );
  }
}


// --- RESTORED Helper Widget for the old Thumbs Up effect ---
class _FloatingParticle extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _FloatingParticle({required this.icon, required this.color});

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle> {
  late double _x;
  late double _y;

  @override
  void initState() {
    super.initState();
    _x = Random().nextDouble() * 2 - 1;
    _y = 1.1; // Start below the screen
  }

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: Random().nextInt(2000) + 2000),
      onCompleted: () => setState(() {
        _x = Random().nextDouble() * 2 - 1;
        _y = 1.1;
      }),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(_x * 100, (_y - value * 2.2) * MediaQuery.of(context).size.height / 2),
          child: Opacity(opacity: (1.0 - value).clamp(0.0, 1.0), child: child),
        );
      },
      child: Icon(widget.icon, color: widget.color, size: 40),
    );
  }
}