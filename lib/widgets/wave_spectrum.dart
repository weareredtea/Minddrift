
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveSpectrum extends StatefulWidget {
  final double value;
  final double? secretValue;
  final bool isReadOnly;
  final String leftCategory;
  final String rightCategory;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onTap;

  const WaveSpectrum({
    super.key,
    required this.value,
    this.secretValue,
    this.isReadOnly = false,
    required this.leftCategory,
    required this.rightCategory,
    this.onChanged,
    this.onTap,
  });

  @override
  State<WaveSpectrum> createState() => _WaveSpectrumState();
}

class _WaveSpectrumState extends State<WaveSpectrum> with TickerProviderStateMixin {
  static const double _spectrumHeight = 120.0;
  
  late AnimationController _colorController;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Wave spectrum
        SizedBox(
          height: _spectrumHeight,
          child: GestureDetector(
            onTapDown: widget.isReadOnly ? null : _handleTap,
            onPanUpdate: widget.isReadOnly ? null : _handlePanUpdate,
            child: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _WaveSpectrumPainter(
                    value: widget.value,
                    secretValue: widget.secretValue,
                    isReadOnly: widget.isReadOnly,
                    colorAnimation: _colorAnimation.value,
                  ),
                  size: const Size(double.infinity, _spectrumHeight),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Category labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left category
            Expanded(
              child: Text(
                widget.leftCategory,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
            // Right category
            Expanded(
              child: Text(
                widget.rightCategory,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleTap(TapDownDetails details) {
    if (widget.isReadOnly) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final width = renderBox.size.width;
    
    // Convert tap position to value (0-100)
    final tapValue = (localPosition.dx / width * 100).clamp(0.0, 100.0);
    widget.onChanged?.call(tapValue);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.isReadOnly) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final width = renderBox.size.width;
    
    // Convert pan position to value (0-100)
    final panValue = (localPosition.dx / width * 100).clamp(0.0, 100.0);
    widget.onChanged?.call(panValue);
  }
}

class _WaveSpectrumPainter extends CustomPainter {
  final double value;
  final double? secretValue;
  final bool isReadOnly;
  final double colorAnimation;

  _WaveSpectrumPainter({
    required this.value,
    this.secretValue,
    required this.isReadOnly,
    required this.colorAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final width = size.width;
    
    // Wave path
    final wavePath = Path();
    wavePath.moveTo(0, centerY);
    
    // Create a gentle wave curve
    final controlPoint1 = Offset(width * 0.25, centerY - 20);
    final controlPoint2 = Offset(width * 0.75, centerY + 20);
    wavePath.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, width * 0.5, centerY);
    wavePath.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, width, centerY);
    
    // Create smooth shimmering gradient effect
    final shimmerOffset = colorAnimation * width * 2 - width; // Move from -width to +width
    
    final wavePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.purple.withValues(alpha: 0.3),
          Colors.blue.withValues(alpha: 0.8),
          Colors.purple.withValues(alpha: 0.3),
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        transform: GradientRotation(shimmerOffset / width * 2 * math.pi),
      ).createShader(Rect.fromLTWH(-width, 0, width * 3, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    
    // Draw wave glow effect with shimmering
    final waveGlowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.purple.withValues(alpha: 0.1),
          Colors.blue.withValues(alpha: 0.2),
          Colors.purple.withValues(alpha: 0.1),
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        transform: GradientRotation(shimmerOffset / width * 2 * math.pi),
      ).createShader(Rect.fromLTWH(-width, 0, width * 3, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    
    canvas.drawPath(wavePath, waveGlowPaint);
    
    // Create a single fill path that covers both triangular areas
    final fillPath = Path();
    
    // Start at left baseline
    fillPath.moveTo(0, centerY);
    
    // Go to the bottom of the wave curve (left side)
    fillPath.lineTo(0, centerY + 20);
    
    // Follow the bottom of the wave curve from left to right
    fillPath.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, width * 0.5, centerY);
    fillPath.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, width, centerY);
    
    // Go to the right baseline
    fillPath.lineTo(width, centerY);
    
    // Go to the top of the wave curve (right side)
    fillPath.lineTo(width, centerY - 20);
    
    // Follow the top of the wave curve from right to left
    fillPath.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, width * 0.5, centerY);
    fillPath.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, 0, centerY);
    
    // Close the path back to start
    fillPath.close();
    
    // Draw semi-transparent light purple fill for both triangular areas (static, no shimmering)
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.purple.withValues(alpha: 0.15),
          Colors.purple.withValues(alpha: 0.25),
          Colors.purple.withValues(alpha: 0.15),
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, size.height))
      ..style = PaintingStyle.fill;
    
    // Draw the combined triangular areas
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw main wave line
    canvas.drawPath(wavePath, wavePaint);
    
    // Draw endpoints with shimmering effect
    final endpointPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.purple.withValues(alpha: 0.4),
          Colors.blue.withValues(alpha: 0.6),
          Colors.purple.withValues(alpha: 0.4),
        ],
        stops: [0.0, 0.5, 1.0],
        transform: GradientRotation(colorAnimation * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 6))
      ..style = PaintingStyle.fill;
    
    // Left endpoint
    canvas.drawCircle(Offset(0, centerY), 6, endpointPaint);
    
    // Right endpoint
    canvas.drawCircle(Offset(width, centerY), 6, endpointPaint);
    
    // Draw secret marker if available
    if (secretValue != null) {
      final secretX = (secretValue! / 100.0) * width;
      final secretY = _getYPosition(secretX, centerY, width);
      
      // Calculate secret marker rotation
      final secretSlope = _getSlope(secretX, centerY, width);
      final secretAngle = math.atan(secretSlope);
      
      // Save canvas state for secret marker
      canvas.save();
      canvas.translate(secretX, secretY);
      canvas.rotate(secretAngle);
      
      // Secret marker shadow
      final secretShadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(1, 1), 8, secretShadowPaint);
      
      // Secret marker glow
      final secretGlowPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset.zero, 8, secretGlowPaint);
      
      // Secret marker (small diamond shape)
      final secretPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      
      final secretPath = Path();
      secretPath.moveTo(0, -10); // Top
      secretPath.lineTo(-6, 0);  // Left
      secretPath.lineTo(0, 10);  // Bottom
      secretPath.lineTo(6, 0);   // Right
      secretPath.close();
      
      canvas.drawPath(secretPath, secretPaint);
      
      // Secret marker highlight
      final secretHighlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      
      final secretHighlightPath = Path();
      secretHighlightPath.moveTo(0, -8);
      secretHighlightPath.lineTo(-4, 0);
      secretHighlightPath.lineTo(0, 8);
      secretHighlightPath.lineTo(4, 0);
      secretHighlightPath.close();
      
      canvas.drawPath(secretHighlightPath, secretHighlightPaint);
      
      // Restore canvas state
      canvas.restore();
    }
    
    // Draw current value marker
    final markerX = (value / 100.0) * width;
    final markerY = _getYPosition(markerX, centerY, width);
    
    // Calculate marker rotation based on wave slope
    final slope = _getSlope(markerX, centerY, width);
    final angle = math.atan(slope);
    
    // Save canvas state
    canvas.save();
    canvas.translate(markerX, markerY);
    canvas.rotate(angle);
    
    // Marker shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    // Draw circle with vertical lines marker
    final circleRadius = 8.0;
    final lineLength = 12.0;
    
    // Create marker path: circle + top line + bottom line
    final markerPath = Path();
    
    // Top vertical line
    markerPath.moveTo(0, -circleRadius - lineLength);
    markerPath.lineTo(0, -circleRadius);
    
    // Circle
    markerPath.addArc(
      Rect.fromCircle(center: Offset.zero, radius: circleRadius),
      0,
      2 * math.pi,
    );
    
    // Bottom vertical line
    markerPath.moveTo(0, circleRadius);
    markerPath.lineTo(0, circleRadius + lineLength);
    
    // Draw shadow
    canvas.save();
    canvas.translate(2, 2);
    canvas.drawPath(markerPath, shadowPaint);
    canvas.restore();
    
    // Marker outer glow
    final glowPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    canvas.drawPath(markerPath, glowPaint);
    
    // Main marker outline (for vertical lines)
    final markerPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    canvas.drawPath(markerPath, markerPaint);
    
    // Filled circle
    final circlePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, circleRadius, circlePaint);
    
    // Inner circle highlight (smaller, for depth)
    final innerCirclePath = Path();
    innerCirclePath.addArc(
      Rect.fromCircle(center: Offset.zero, radius: circleRadius - 2),
      0,
      2 * math.pi,
    );
    
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(innerCirclePath, innerPaint);
    
    // Restore canvas state
    canvas.restore();
  }
  
  double _getSlope(double x, double centerY, double width) {
    // Calculate the slope (derivative) of the wave curve at point x
    final normalizedX = x / width;
    final delta = 0.01; // Small increment for derivative calculation
    
    if (normalizedX <= 0.5) {
      // First half of the curve
      final t1 = normalizedX * 2;
      final t2 = (normalizedX + delta) * 2;
      
      final controlPoint1 = Offset(width * 0.25, centerY - 20);
      final midPoint = Offset(width * 0.5, centerY);
      
      final y1 = math.pow(1 - t1, 2) * centerY + 
                 2 * (1 - t1) * t1 * controlPoint1.dy + 
                 math.pow(t1, 2) * midPoint.dy;
      
      final y2 = math.pow(1 - t2, 2) * centerY + 
                 2 * (1 - t2) * t2 * controlPoint1.dy + 
                 math.pow(t2, 2) * midPoint.dy;
      
      return (y2 - y1) / (delta * width);
    } else {
      // Second half of the curve
      final t1 = (normalizedX - 0.5) * 2;
      final t2 = (normalizedX + delta - 0.5) * 2;
      
      final midPoint = Offset(width * 0.5, centerY);
      final controlPoint2 = Offset(width * 0.75, centerY + 20);
      final endPoint = Offset(width, centerY);
      
      final y1 = math.pow(1 - t1, 2) * midPoint.dy + 
                 2 * (1 - t1) * t1 * controlPoint2.dy + 
                 math.pow(t1, 2) * endPoint.dy;
      
      final y2 = math.pow(1 - t2, 2) * midPoint.dy + 
                 2 * (1 - t2) * t2 * controlPoint2.dy + 
                 math.pow(t2, 2) * endPoint.dy;
      
      return (y2 - y1) / (delta * width);
    }
  }
  
  double _getYPosition(double x, double centerY, double width) {
    // Calculate Y position based on the same wave curve used in the path
    final normalizedX = x / width;
    
    // Use the same curve as the wave path (quadratic Bezier)
    if (normalizedX <= 0.5) {
      // First half of the curve
      final t = normalizedX * 2; // 0 to 1
      final controlPoint1 = Offset(width * 0.25, centerY - 20);
      final midPoint = Offset(width * 0.5, centerY);
      
      // Quadratic Bezier formula: B(t) = (1-t)²P₀ + 2(1-t)tP₁ + t²P₂
      final y = math.pow(1 - t, 2) * centerY + 
                2 * (1 - t) * t * controlPoint1.dy + 
                math.pow(t, 2) * midPoint.dy;
      return y;
    } else {
      // Second half of the curve
      final t = (normalizedX - 0.5) * 2; // 0 to 1
      final midPoint = Offset(width * 0.5, centerY);
      final controlPoint2 = Offset(width * 0.75, centerY + 20);
      final endPoint = Offset(width, centerY);
      
      // Quadratic Bezier formula: B(t) = (1-t)²P₀ + 2(1-t)tP₁ + t²P₂
      final y = math.pow(1 - t, 2) * midPoint.dy + 
                2 * (1 - t) * t * controlPoint2.dy + 
                math.pow(t, 2) * endPoint.dy;
      return y;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _WaveSpectrumPainter) {
      return oldDelegate.value != value ||
             oldDelegate.secretValue != secretValue ||
             oldDelegate.isReadOnly != isReadOnly ||
             oldDelegate.colorAnimation != colorAnimation;
    }
    return true;
  }
}

