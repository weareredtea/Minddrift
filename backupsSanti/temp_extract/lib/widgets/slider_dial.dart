// lib/widgets/slider_dial.dart

import 'package:flutter/material.dart';

class SliderDial extends StatelessWidget {
  final double value;
  final int divisions;
  final ValueChanged<double> onChanged;
  final bool showValue; // New parameter to control visibility of the label

  const SliderDial({
    super.key,
    required this.value,
    required this.divisions,
    required this.onChanged,
    this.showValue = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      divisions: divisions,
      min: 0,
      max: 100,
      label: showValue ? value.round().toString() : null, // Conditionally show label
      onChanged: onChanged,
    );
  }
}
