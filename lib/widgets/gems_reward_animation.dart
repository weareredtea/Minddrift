// lib/widgets/gems_reward_animation.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GemsRewardAnimation extends StatefulWidget {
  final int gemsEarned;
  final String reason;
  final VoidCallback? onComplete;
  
  const GemsRewardAnimation({
    super.key,
    required this.gemsEarned,
    required this.reason,
    this.onComplete,
  });

  @override
  State<GemsRewardAnimation> createState() => _GemsRewardAnimationState();
}

class _GemsRewardAnimationState extends State<GemsRewardAnimation>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  // late Animation<double> _particleAnimation; // Removed unused animation
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Slide animation (entrance)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Scale animation (gem bounce)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Glow animation (pulsing effect)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Particle animation (sparkle effect)
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    // _particleAnimation removed - using controller directly

    // Fade out animation
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Start entrance animations
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();
    
    // Start glow effect
    _glowController.repeat(reverse: true);
    
    // Start particle effect
    await Future.delayed(const Duration(milliseconds: 200));
    _particleController.forward();
    
    // Auto-dismiss after showing for a while
    await Future.delayed(const Duration(milliseconds: 2500));
    _dismissAnimation();
  }

  void _dismissAnimation() async {
    _glowController.stop();
    await _slideController.reverse();
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideController,
        _scaleController,
        _glowController,
        // _particleController, // Removed unused controller from animation list
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withAlpha(240),
                      Colors.orange.withAlpha(240),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withAlpha(100),
                      blurRadius: 20 * _glowAnimation.value,
                      spreadRadius: 5 * _glowAnimation.value,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Gems earned section
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated gem icon
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withAlpha(100),
                                    blurRadius: 10 * _glowAnimation.value,
                                    spreadRadius: 2 * _glowAnimation.value,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.diamond,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Gems amount
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Text(
                                  '+${widget.gemsEarned}',
                                  style: const TextStyle(
                                    fontFamily: 'LuckiestGuy',
                                    fontSize: 28,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                'Mind Gems',
                                style: TextStyle(
                                  fontFamily: 'Chewy',
                                  fontSize: 14,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Reason text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getReasonText(widget.reason),
                          style: const TextStyle(
                            fontFamily: 'Chewy',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getReasonText(String reason) {
    switch (reason) {
      case 'practice_completion':
        return '🎯 Practice Complete!';
      case 'daily_completion':
        return '📅 Daily Challenge Complete!';
      case 'campaign_completion':
        return '🚀 Campaign Level Complete!';
      case 'campaign_stars':
        return '⭐ Star Achievement!';
      case 'daily_bonus':
        return '🎁 Daily Bonus!';
      case 'achievement':
        return '🏆 Achievement Unlocked!';
      default:
        return '💎 Gems Earned!';
    }
  }
}

/// Overlay manager for showing gems rewards
class GemsRewardOverlay {
  static OverlayEntry? _currentOverlay;

  /// Show gems reward animation
  static void show(
    BuildContext context, {
    required int gemsEarned,
    required String reason,
  }) {
    // Remove any existing overlay
    dismiss();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 0,
        right: 0,
        child: GemsRewardAnimation(
          gemsEarned: gemsEarned,
          reason: reason,
          onComplete: dismiss,
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  /// Dismiss current overlay
  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

/// Particle effect widget for extra sparkle (currently unused but kept for future enhancement)
// class _ParticleEffect extends StatelessWidget {
//   final Animation<double> animation;
//   
//   const _ParticleEffect({required this.animation});
// 
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: _ParticlePainter(animation.value),
//           size: const Size(200, 100),
//         );
//       },
//     );
//   }
// }

// Particle painter removed as it's currently unused
// Can be re-added later for enhanced sparkle effects
