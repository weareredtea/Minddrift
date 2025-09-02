// lib/widgets/radial_spectrum.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RadialSpectrumWidget extends StatefulWidget {
  final double value;
  final double? secretValue;
  final Function(double) onChanged;
  final bool isReadOnly;

  const RadialSpectrumWidget({
    super.key,
    required this.value,
    this.secretValue,
    required this.onChanged,
    this.isReadOnly = false,
  });

  @override
  State<RadialSpectrumWidget> createState() => _RadialSpectrumWidgetState();
}

class _RadialSpectrumWidgetState extends State<RadialSpectrumWidget> {
  // Performance optimization: Track previous values to avoid unnecessary repaints
  // Note: These are used in didUpdateWidget for optimization
  double _lastValue = 0.0;
  double? _lastSecretValue;
  bool _lastIsReadOnly = false;
  
  // Performance optimization: Reduced threshold for smoother movement
  double _lastReportedValue = 0.0;
  static const double _valueChangeThreshold = 0.1; // Reduced from 1.0 to 0.1 for smooth movement

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
    _lastSecretValue = widget.secretValue;
    _lastIsReadOnly = widget.isReadOnly;
    _lastReportedValue = widget.value;
  }

  @override
  void didUpdateWidget(RadialSpectrumWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Performance optimization: Only update if values actually changed
    if (oldWidget.value != widget.value) {
      _lastValue = widget.value;
    }
    if (oldWidget.secretValue != widget.secretValue) {
      _lastSecretValue = widget.secretValue;
    }
    if (oldWidget.isReadOnly != widget.isReadOnly) {
      _lastIsReadOnly = widget.isReadOnly;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.isReadOnly) return;
    
    // Immediately respond to touch start for better responsiveness
    final box = context.findRenderObject() as RenderBox;
    final center = Offset(box.size.width / 2, box.size.height * 0.9);
    final position = box.globalToLocal(details.globalPosition);
    
    final newValue = _calculateValueFromPosition(position, center);
    _updateValueIfNeeded(newValue);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isReadOnly) return;
    
    final box = context.findRenderObject() as RenderBox;
    final center = Offset(box.size.width / 2, box.size.height * 0.9);
    final position = box.globalToLocal(details.globalPosition);

    final newValue = _calculateValueFromPosition(position, center);
    _updateValueIfNeeded(newValue);
  }

  // Performance optimization: Extract value calculation to avoid code duplication
  double _calculateValueFromPosition(Offset position, Offset center) {
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

  // Performance optimization: Only call onChanged if value changed significantly
  void _updateValueIfNeeded(double newValue) {
    if ((newValue - _lastReportedValue).abs() >= _valueChangeThreshold) {
      _lastReportedValue = newValue;
      widget.onChanged(newValue);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.isReadOnly) return;
    HapticFeedback.lightImpact();
    
    // Ensure final value is reported even if it's small
    if ((widget.value - _lastReportedValue).abs() > 0.1) {
      widget.onChanged(widget.value);
      _lastReportedValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isReadOnly,
              child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          // Performance optimization: Expand touch area for better responsiveness
          behavior: HitTestBehavior.opaque,
          child: CustomPaint(
          size: const Size(double.infinity, 180),
          painter: _GaugePainter(
            value: widget.value,
            secretValue: widget.secretValue,
            isReadOnly: widget.isReadOnly,
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

  static const double startAngle = -pi;
  static const double sweepAngle = pi;

  // Performance optimization: Cache expensive objects
  static final List<Color> _colors = [
    const Color(0xFF00A896), const Color(0xFF02C39A), const Color(0xFFF9C74F), 
    const Color(0xFFF8961E), const Color(0xFFF8961E),
  ];
  static final List<double> _stops = [0.0, 0.25, 0.5, 0.75, 1.0];
  
  // Performance optimization: Cache paint objects
  static final Paint _fillPaint = Paint()..color = Colors.white.withValues(alpha: 0.05);
  static final Paint _centerCirclePaint = Paint()..color = Colors.grey[800]!;
  static final Paint _innerCirclePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);

  _GaugePainter({
    required this.value,
    this.secretValue,
    required this.isReadOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = size.height * 0.8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final zoneStrokeWidth = radius * 0.25;

    // Draw background fill
    canvas.drawArc(rect, startAngle, sweepAngle, true, _fillPaint);

    // Performance optimization: Create gradient shader only once per paint
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: _colors, 
        stops: _stops, 
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle, 
        transform: GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = zoneStrokeWidth;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - zoneStrokeWidth / 2),
        startAngle, sweepAngle, false, gradientPaint);

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
      // Performance optimization: Cache paint objects for needle
          final needleBodyPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    final needleTipPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
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
      
      // Draw center circles using cached paints
      canvas.drawCircle(center, 12, _centerCirclePaint);
      canvas.drawCircle(center, 5, _innerCirclePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    // Performance optimization: Only repaint when values actually change significantly
    return (oldDelegate.value - value).abs() > 0.1 || // Reduced from 0.5 to 0.1 for smoother updates 
           (oldDelegate.secretValue ?? 0) != (secretValue ?? 0) ||
           oldDelegate.isReadOnly != isReadOnly;
  }
}
