// lib/screens/store_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../providers/purchase_provider_new.dart';
import '../l10n/app_localizations.dart';
// import '../screens/bundle_preview_screen.dart'; // Hidden for now

class StoreScreen extends StatelessWidget {
  static const routeName = '/store';

  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final purchase = context.watch<PurchaseProviderNew>();
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.store),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          // Billing availability warning
          if (!purchase.isBillingAvailable) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        loc.billingUnavailable,
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.billingUnavailableDescription,
                    style: TextStyle(color: Colors.orange.shade200),
                  ),
                ],
              ),
            ),
          ],
          
          // All Access Bundle Message
          if (purchase.hasAllAccess) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'All Access Bundle Active!',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have purchased the All Access Bundle. All current and future bundles are now available to you!',
                    style: TextStyle(color: Colors.purple.shade200),
                  ),
                ],
              ),
            ),
          ],
          
          _buildTile(
            context,
            sku: 'all_access',
            title: loc.allAccessPass,
            description: loc.allAccessPassDescription,
            purchase: purchase,
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            context,
            sku: 'bundle.horror',
            title: loc.horrorBundle,
            description: loc.horrorBundleDescription,
            purchase: purchase,
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            context,
            sku: 'bundle.kids',
            title: loc.kidsBundle,
            description: loc.kidsBundleDescription,
            purchase: purchase,
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            context,
            sku: 'bundle.food',
            title: loc.foodBundle,
            description: loc.foodBundleDescription,
            purchase: purchase,
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            context,
            sku: 'bundle.nature',
            title: loc.natureBundle,
            description: loc.natureBundleDescription,
            purchase: purchase,
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            context,
            sku: 'bundle.fantasy',
            title: loc.fantasyBundle,
            description: loc.fantasyBundleDescription,
            purchase: purchase,
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String sku,
    required String title,
    required String description,
    required PurchaseProviderNew purchase,
  }) {
    final owned = purchase.isOwned(sku);
    final matches = purchase.products.where((pd) => pd.id == sku);
    final ProductDetails? product = matches.isNotEmpty ? matches.first : null;

    return ListTile(
      leading: Icon(
        owned ? Icons.check_circle : Icons.shopping_bag,
        color: owned ? Colors.greenAccent : Colors.white,
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
      subtitle: Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
      trailing: owned
          ? Text('Owned', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.greenAccent))
          : ElevatedButton(
              onPressed: (product == null || !purchase.isBillingAvailable) 
                  ? null 
                  : () => purchase.buy(product.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: Text(product?.price ?? ''),
            ),
      // Bundle preview functionality hidden for now
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => BundlePreviewScreen(bundleId: sku),
      //     ),
      //   );
      // },
    );
  }
}
