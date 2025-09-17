// lib/screens/bundle_preview_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/category_service.dart';
import '../providers/purchase_provider_new.dart';
import '../widgets/bundle_indicator.dart';
import '../utils/responsive_helper.dart';

class BundlePreviewScreen extends StatelessWidget {
  final String bundleId;
  
  const BundlePreviewScreen({
    super.key,
    required this.bundleId,
  });

  @override
  Widget build(BuildContext context) {
    final purchase = context.watch<PurchaseProviderNew>();
    final categories = CategoryService.getCategoriesByBundle(bundleId);
    final bundleInfo = _getBundleInfo(bundleId);
    final isOwned = purchase.isOwned(bundleId);

    return Scaffold(
      appBar: AppBar(
        title: Text(bundleInfo.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isOwned)
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => purchase.buy(bundleId),
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Bundle header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                                          bundleInfo.color.withValues(alpha: 0.3),
                        bundleInfo.color.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  bundleInfo.icon,
                  size: 64,
                  color: bundleInfo.color,
                ),
                const SizedBox(height: 16),
                Text(
                  bundleInfo.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: bundleInfo.color,
                                            fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${categories.length} Categories',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                if (isOwned) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Text(
                      'Owned',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Categories list
          Expanded(
            child: ListView.builder(
              padding: ResponsiveHelper.getResponsivePadding(context),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.grey[900],
                  child: ListTile(
                    leading: BundleIndicator(
                      categoryId: category.id,
                      showIcon: true,
                      showLabel: false,
                      size: 20,
                    ),
                    title: Text(
                      '${CategoryService.getLocalizedCategoryText(context, category.id, true)} ↔ ${CategoryService.getLocalizedCategoryText(context, category.id, false)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Category ${index + 1}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  BundleInfo _getBundleInfo(String bundleId) {
    switch (bundleId) {
      case 'bundle.free':
        return BundleInfo(
          name: 'Free Bundle',
          color: Colors.green,
          icon: Icons.free_breakfast,
        );
      case 'bundle.horror':
        return BundleInfo(
          name: 'Horror Bundle',
          color: Colors.red,
          icon: Icons.psychology,
        );
      case 'bundle.kids':
        return BundleInfo(
          name: 'Kids Bundle',
          color: Colors.orange,
          icon: Icons.child_care,
        );
      case 'bundle.food':
        return BundleInfo(
          name: 'Food Bundle',
          color: Colors.brown,
          icon: Icons.restaurant,
        );
      case 'bundle.nature':
        return BundleInfo(
          name: 'Nature Bundle',
          color: Colors.green,
          icon: Icons.eco,
        );
      case 'bundle.fantasy':
        return BundleInfo(
          name: 'Fantasy Bundle',
          color: Colors.purple,
          icon: Icons.auto_awesome,
        );
      default:
        return BundleInfo(
          name: 'Unknown Bundle',
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }
}
