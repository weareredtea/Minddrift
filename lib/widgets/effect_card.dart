import 'package:flutter/material.dart';
import '../models/round.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class EffectCard extends StatelessWidget {
  final Effect effect;
  final String? customDescription;
  final bool showIcon;

  const EffectCard({
    super.key,
    required this.effect,
    this.customDescription,
    this.showIcon = true,
  });

  String _getEffectDescription(BuildContext context) {
    if (customDescription != null) return customDescription!;
    
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      // Fallback to English if localization is not available
      switch (effect) {
        case Effect.doubleScore:
          return 'Double Score!';
        case Effect.halfScore:
          return 'Half Score!';
        case Effect.token:
          return 'Navigator gets a Token!';
        case Effect.reverseSlider:
          return 'Reverse Slider!';
        case Effect.noClue:
          return 'No Clue!';
        case Effect.blindGuess:
          return 'Blind Guess!';
        case Effect.none:
          return 'No Effect';
      }
    }
    
    switch (effect) {
      case Effect.doubleScore:
        return loc.doubleScore;
      case Effect.halfScore:
        return loc.halfScore;
      case Effect.token:
        return loc.navigatorGetsToken;
      case Effect.reverseSlider:
        return loc.reverseSlider;
      case Effect.noClue:
        return loc.noClue;
      case Effect.blindGuess:
        return loc.blindGuess;
      case Effect.none:
        return loc.noEffect;
    }
  }

  IconData _getEffectIcon() {
    switch (effect) {
      case Effect.doubleScore:
        return Icons.star;
      case Effect.halfScore:
        return Icons.star_half;
      case Effect.token:
        return Icons.token;
      case Effect.reverseSlider:
        return Icons.swap_horiz;
      case Effect.noClue:
        return Icons.block;
      case Effect.blindGuess:
        return Icons.visibility_off;
      case Effect.none:
        return Icons.info;
    }
  }

  Color _getEffectColor() {
    switch (effect) {
      case Effect.doubleScore:
        return Colors.amber;
      case Effect.halfScore:
        return Colors.orange;
      case Effect.token:
        return Colors.purple;
      case Effect.reverseSlider:
        return Colors.blue;
      case Effect.noClue:
        return Colors.red;
      case Effect.blindGuess:
        return Colors.grey;
      case Effect.none:
        return AppColors.accentVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (effect == Effect.none) return const SizedBox.shrink();
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
                              color: _getEffectColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
                                _getEffectColor().withValues(alpha: 0.1),
                  _getEffectColor().withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(
                  _getEffectIcon(),
                  color: _getEffectColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  _getEffectDescription(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getEffectColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
