// lib/widgets/custom_slider_dial.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CustomSliderDial extends StatefulWidget {
  final double value;
  final Function(double) onChanged;
  final bool isReadOnly;
  final bool showValue;

  const CustomSliderDial({
    super.key,
    required this.value,
    required this.onChanged,
    this.isReadOnly = false,
    this.showValue = true,
  });

  @override
  State<CustomSliderDial> createState() => _CustomSliderDialState();
}

class _CustomSliderDialState extends State<CustomSliderDial> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Performance optimization: Track previous values to avoid unnecessary repaints
  // Note: These are used in didUpdateWidget for optimization
  double _lastValue = 0.0;
  bool _lastShowValue = true;
  bool _lastIsReadOnly = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Initialize tracking values
    _lastValue = widget.value;
    _lastShowValue = widget.showValue;
    _lastIsReadOnly = widget.isReadOnly;
  }

  @override
  void didUpdateWidget(CustomSliderDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Performance optimization: Only update if values actually changed
    if (oldWidget.value != widget.value) {
      _lastValue = widget.value;
    }
    if (oldWidget.showValue != widget.showValue) {
      _lastShowValue = widget.showValue;
    }
    if (oldWidget.isReadOnly != widget.isReadOnly) {
      _lastIsReadOnly = widget.isReadOnly;
    }
  }
  
  void _onPanStart(DragStartDetails details) {
    if (widget.isReadOnly) return;
    _controller.forward();
  }

  void _onPanUpdate(DragUpdateDetails details, BuildContext context) {
    if (widget.isReadOnly) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final position = box.globalToLocal(details.globalPosition);
    final newValue = (position.dx / box.size.width).clamp(0.0, 1.0) * 100;
    
    // Performance optimization: Only call onChanged if value actually changed significantly
    if ((newValue - widget.value).abs() > 0.5) {
      widget.onChanged(newValue);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.isReadOnly) return;
    HapticFeedback.lightImpact();
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: (details) => _onPanUpdate(details, context),
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(double.infinity, 60 * _animation.value),
            painter: _SliderPainter(
              value: widget.value,
              thumbScale: _animation.value,
              showValue: widget.showValue,
            ),
          );
        },
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double value;
  final double thumbScale;
  final bool showValue;

  _SliderPainter({required this.value, required this.thumbScale, required this.showValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double trackHeight = 12.0;
    final double trackY = size.height / 2 - trackHeight / 2;
    
    // Performance optimization: Pre-calculate values
    final double activeWidth = (value / 100) * size.width;
    final double thumbRadius = 18.0 * thumbScale;
    final double thumbCenterX = activeWidth.clamp(thumbRadius, size.width - thumbRadius);
    final double thumbCenterY = size.height / 2;
    
    // --- Track Paint ---
    final inactiveTrackPaint = Paint()
      ..color = AppColors.surface.withOpacity(0.8)
      ..style = PaintingStyle.fill;
      
    final activeTrackPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.accent, AppColors.accentVariant],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // --- Draw Track ---
    final trackRect = RRect.fromLTRBAndCorners(
      0, trackY, size.width, trackY + trackHeight,
      topLeft: const Radius.circular(6),
      bottomLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );
    canvas.drawRRect(trackRect, inactiveTrackPaint);
    
    final activeTrackRect = RRect.fromLTRBAndCorners(
      0, trackY, activeWidth, trackY + trackHeight,
      topLeft: const Radius.circular(6),
      bottomLeft: const Radius.circular(6),
    );
    canvas.drawRRect(activeTrackRect, activeTrackPaint);
    
    // --- Thumb Paint ---
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final thumbShadowPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      
    // --- Draw Thumb ---
    canvas.drawCircle(Offset(thumbCenterX, thumbCenterY), thumbRadius + 2, thumbShadowPaint);
    canvas.drawCircle(Offset(thumbCenterX, thumbCenterY), thumbRadius, thumbPaint);
    
    // --- Draw Value Text ---
    if (showValue) {
              final textSpan = TextSpan(
          text: value.round().toString(),
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16 * thumbScale,
          ),
        );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final textOffset = Offset(
        thumbCenterX - textPainter.width / 2,
        thumbCenterY - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _SliderPainter oldDelegate) {
    // Performance optimization: More granular repaint conditions
    return (oldDelegate.value - value).abs() > 0.5 || 
           (oldDelegate.thumbScale - thumbScale).abs() > 0.01 ||
           oldDelegate.showValue != showValue;
  }
}
