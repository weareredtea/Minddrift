// lib/widgets/radial_spectrum.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RadialSpectrumWidget extends StatefulWidget {
  final double value;
  final double? secretValue;
  final Function(double) onChanged;
  final bool isReadOnly;
  final double size;
  final Color? arcColor;
  final Color? needleColor;
  final Color? backgroundColor;
  final Color? trackColor;

  const RadialSpectrumWidget({
    super.key,
    required this.value,
    this.secretValue,
    required this.onChanged,
    this.isReadOnly = false,
    this.size = 280,
    this.arcColor,
    this.needleColor,
    this.backgroundColor,
    this.trackColor,
  });

  @override
  State<RadialSpectrumWidget> createState() => _RadialSpectrumWidgetState();
}

class _RadialSpectrumWidgetState extends State<RadialSpectrumWidget> {
  // Performance optimization: Ultra-responsive thresholds for zero lag
  double _lastReportedValue = 0.0;
  static const double _valueChangeThreshold = 0.1; // Ultra-low threshold for immediate response
  
  // Performance optimization: Pre-calculate center and radius for faster touch handling
  Offset? _cachedCenter;
  double? _cachedRadius;
  Size? _cachedSize;

  @override
  void initState() {
    super.initState();
    _lastReportedValue = widget.value;
  }

  // Performance optimization: Cache center and radius calculations
  void _updateCache(Size size) {
    if (_cachedSize != size) {
      _cachedSize = size;
      _cachedCenter = Offset(size.width / 2, size.height * 0.9);
      _cachedRadius = size.height * 0.8;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.isReadOnly) return;
    
    // Ultra-fast response: immediately calculate and report value
    final box = context.findRenderObject() as RenderBox;
    _updateCache(box.size);
    
    final position = box.globalToLocal(details.globalPosition);
    final newValue = _calculateValueFromPosition(position, _cachedCenter!, _cachedRadius!);
    
    // Immediate response without threshold check
    _lastReportedValue = newValue;
    widget.onChanged(newValue);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isReadOnly) return;
    
    final box = context.findRenderObject() as RenderBox;
    _updateCache(box.size);
    
    final position = box.globalToLocal(details.globalPosition);
    final newValue = _calculateValueFromPosition(position, _cachedCenter!, _cachedRadius!);
    
    // Ultra-responsive: report every significant change
    if ((newValue - _lastReportedValue).abs() >= _valueChangeThreshold) {
      _lastReportedValue = newValue;
      widget.onChanged(newValue);
    }
  }

  // Performance optimization: Optimized value calculation
  double _calculateValueFromPosition(Offset position, Offset center, double radius) {
    final angle = atan2(position.dy - center.dy, position.dx - center.dx);

    const startAngle = -pi;
    const sweepAngle = pi;

    final normalizedAngle = angle - startAngle;
    final correctedAngle = (normalizedAngle + (2 * pi)) % (2 * pi);

    if (position.dy > center.dy) {
      if (position.dx < center.dx) {
        return 0.0;
      } else {
        return 100.0;
      }
    }

    final clampedAngle = correctedAngle.clamp(0.0, sweepAngle);
    return (clampedAngle / sweepAngle) * 100.0;
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.isReadOnly) return;
    HapticFeedback.lightImpact();
    
    // Ensure final value is reported
    if ((widget.value - _lastReportedValue).abs() > 0.01) {
      widget.onChanged(widget.value);
      _lastReportedValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        ignoring: widget.isReadOnly,
        child: GestureDetector(
          // This is the definitive fix - set callbacks to null when in read-only mode
          onPanStart: widget.isReadOnly ? null : _onPanStart,
          onPanUpdate: widget.isReadOnly ? null : _onPanUpdate,
          onPanEnd: widget.isReadOnly ? null : _onPanEnd,
          // Performance optimization: Expand touch area for better responsiveness
          behavior: HitTestBehavior.opaque,
          child: CustomPaint(
            size: Size(widget.size, widget.size * 0.64), // Maintain aspect ratio
            painter: _GaugePainter(
              value: widget.value,
              secretValue: widget.secretValue,
              isReadOnly: widget.isReadOnly,
              arcColor: widget.arcColor,
              needleColor: widget.needleColor,
              backgroundColor: widget.backgroundColor,
              trackColor: widget.trackColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double? secretValue;
  final bool isReadOnly;
  final Color? arcColor;
  final Color? needleColor;
  final Color? backgroundColor;
  final Color? trackColor;

  static const double startAngle = -pi;
  static const double sweepAngle = pi;

  // Default colors (performance optimized)
  static const Color _defaultArcColor = Color(0xFF00A896); // Teal
  static const Color _defaultNeedleColor = Colors.white;
  static const Color _defaultBackgroundColor = Colors.transparent;
  static const Color _defaultTrackColor = Colors.grey;

  const _GaugePainter({
    required this.value,
    this.secretValue,
    required this.isReadOnly,
    this.arcColor,
    this.needleColor,
    this.backgroundColor,
    this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = size.height * 0.8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Restore original thickness: radius * 0.25 for proper visual weight
    final zoneStrokeWidth = radius * 0.25;
    
    // Performance optimization: Create paint objects with themed colors
    final currentArcColor = arcColor ?? _defaultArcColor;
    final currentNeedleColor = needleColor ?? _defaultNeedleColor;
    
    final fillPaint = Paint()..color = currentArcColor.withOpacity(0.1);
    final arcPaint = Paint()
      ..color = currentArcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = zoneStrokeWidth;

    // Draw background fill
    canvas.drawArc(rect, startAngle, sweepAngle, true, fillPaint);

    // Performance optimization: Draw solid color arc with themed color
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - zoneStrokeWidth / 2),
        startAngle, sweepAngle, false, arcPaint);

    // Draw secret marker if available
    if (secretValue != null) {
      final secretAngle = startAngle + (secretValue! / 100.0) * sweepAngle;
      final markerPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10;
      
      final innerArcPoint = Offset(
        center.dx + (radius - zoneStrokeWidth) * cos(secretAngle),
        center.dy + (radius - zoneStrokeWidth) * sin(secretAngle),
      );
      final outerArcPoint = Offset(
        center.dx + radius * cos(secretAngle),
        center.dy + radius * sin(secretAngle),
      );
      canvas.drawLine(innerArcPoint, outerArcPoint, markerPaint);
    }
    
    final guessAngle = startAngle + (value / 100.0) * sweepAngle;
    _drawNeedle(canvas, size, center, radius, zoneStrokeWidth, guessAngle);
  }

  void _drawNeedle(Canvas canvas, Size size, Offset center, double radius, double zoneStrokeWidth, double angle) {
    if (isReadOnly) {
      final markerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      
      final innerArcPoint = Offset(
        center.dx + (radius - zoneStrokeWidth) * cos(angle),
        center.dy + (radius - zoneStrokeWidth) * sin(angle),
      );
      final outerArcPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(innerArcPoint, outerArcPoint, markerPaint);
    } else {
      // Performance optimization: Themed needle colors
      final currentNeedleColor = needleColor ?? _defaultNeedleColor;
      final needleBodyPaint = Paint()..color = currentNeedleColor.withOpacity(0.6);
      final needleTipPaint = Paint()..color = currentNeedleColor.withOpacity(0.9);
      const needleWidth = 10.0;
      const gap = 1.5;

      final innerNeedleLength = radius - zoneStrokeWidth - gap;
      final outerNeedleLength = zoneStrokeWidth;
      
      final needleBodyRect = Rect.fromLTWH(-needleWidth / 2, -innerNeedleLength, needleWidth, innerNeedleLength);
      final needleTipRRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          -needleWidth / 2, 
          -(innerNeedleLength + outerNeedleLength + gap), 
          needleWidth, 
          outerNeedleLength
        ),
        topLeft: const Radius.circular(needleWidth / 2),
        topRight: const Radius.circular(needleWidth / 2),
      );
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + pi / 2);
      canvas.drawRect(needleBodyRect, needleBodyPaint);
      canvas.drawRRect(needleTipRRect, needleTipPaint);
      canvas.restore();
      
      // Draw center circles with themed colors
      final centerCirclePaint = Paint()..color = (trackColor ?? _defaultTrackColor).withOpacity(0.8);
      final innerCirclePaint = Paint()..color = currentNeedleColor.withOpacity(0.7);
      canvas.drawCircle(center, 12, centerCirclePaint);
      canvas.drawCircle(center, 5, innerCirclePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    // Performance optimization: Ultra-responsive repainting for zero lag
    return (oldDelegate.value - value).abs() > 0.1 || // Ultra-low threshold for immediate visual feedback
           (oldDelegate.secretValue ?? 0) != (secretValue ?? 0) ||
           oldDelegate.isReadOnly != isReadOnly;
  }
}
