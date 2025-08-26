// lib/widgets/power_up_chip.dart

import 'package:flutter/material.dart';
import '../models/power_up.dart';

class PowerUpChip extends StatelessWidget {
  final PowerUp powerUp;
  final VoidCallback onTap;

  const PowerUpChip({super.key, required this.powerUp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(powerUp.name),
      avatar: const Icon(Icons.flash_on, size: 20),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
