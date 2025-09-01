// lib/widgets/bundle_indicator.dart

import 'package:flutter/material.dart';
import '../services/category_service.dart';

class BundleIndicator extends StatelessWidget {
  final String categoryId;
  final bool showIcon;
  final bool showLabel;
  final double size;

  const BundleIndicator({
    super.key,
    required this.categoryId,
    this.showIcon = true,
    this.showLabel = false,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final bundleId = CategoryService.getBundleIdForCategory(categoryId);
    final bundleInfo = _getBundleInfo(bundleId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bundleInfo.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bundleInfo.color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              bundleInfo.icon,
              size: size,
              color: bundleInfo.color,
            ),
            if (showLabel) const SizedBox(width: 4),
          ],
          if (showLabel) ...[
            Text(
              bundleInfo.name,
              style: TextStyle(
                color: bundleInfo.color,
                fontSize: size * 0.7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  BundleInfo _getBundleInfo(String bundleId) {
    switch (bundleId) {
      case 'bundle.free':
        return BundleInfo(
          name: 'Free',
          color: Colors.green,
          icon: Icons.free_breakfast,
        );
      case 'bundle.horror':
        return BundleInfo(
          name: 'Horror',
          color: Colors.red,
          icon: Icons.psychology,
        );
      case 'bundle.kids':
        return BundleInfo(
          name: 'Kids',
          color: Colors.orange,
          icon: Icons.child_care,
        );
      case 'bundle.food':
        return BundleInfo(
          name: 'Food',
          color: Colors.brown,
          icon: Icons.restaurant,
        );
      case 'bundle.nature':
        return BundleInfo(
          name: 'Nature',
          color: Colors.green,
          icon: Icons.eco,
        );
      case 'bundle.fantasy':
        return BundleInfo(
          name: 'Fantasy',
          color: Colors.purple,
          icon: Icons.auto_awesome,
        );
      default:
        return BundleInfo(
          name: 'Unknown',
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }
}

class BundleInfo {
  final String name;
  final Color color;
  final IconData icon;

  const BundleInfo({
    required this.name,
    required this.color,
    required this.icon,
  });
}

// Extension to easily get bundle info from category ID
extension BundleInfoExtension on String {
  BundleInfo get bundleInfo {
    final bundleId = CategoryService.getBundleIdForCategory(this);
    switch (bundleId) {
      case 'bundle.free':
        return BundleInfo(
          name: 'Free',
          color: Colors.green,
          icon: Icons.free_breakfast,
        );
      case 'bundle.horror':
        return BundleInfo(
          name: 'Horror',
          color: Colors.red,
          icon: Icons.psychology,
        );
      case 'bundle.kids':
        return BundleInfo(
          name: 'Kids',
          color: Colors.orange,
          icon: Icons.child_care,
        );
      case 'bundle.food':
        return BundleInfo(
          name: 'Food',
          color: Colors.brown,
          icon: Icons.restaurant,
        );
      case 'bundle.nature':
        return BundleInfo(
          name: 'Nature',
          color: Colors.green,
          icon: Icons.eco,
        );
      case 'bundle.fantasy':
        return BundleInfo(
          name: 'Fantasy',
          color: Colors.purple,
          icon: Icons.auto_awesome,
        );
      default:
        return BundleInfo(
          name: 'Unknown',
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }
}
