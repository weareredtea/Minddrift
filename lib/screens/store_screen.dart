// lib/screens/store_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../providers/purchase_provider.dart';
import '../l10n/app_localizations.dart';
// import '../screens/bundle_preview_screen.dart'; // Hidden for now

class StoreScreen extends StatelessWidget {
  static const routeName = '/store';

  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final purchase = context.watch<PurchaseProvider>();
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.store),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              context.read<PurchaseProvider>().restorePurchases();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restoring purchases...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text(
              'Restore Purchases',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Debug: Show current user ID
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Info:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Patch Version: 2 (Firestore Path Fix)',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final packageInfo = snapshot.data!;
                      return Text(
                        'App Version: ${packageInfo.version}+${packageInfo.buildNumber}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }
                    return const Text('Loading version...');
                  },
                ),
                const SizedBox(height: 8),
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    if (user != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: ${user.uid}'),
                          Text('Email: ${user.email ?? 'Anonymous'}'),
                          Text('Provider: ${user.providerData.isNotEmpty ? user.providerData.first.providerId : 'None'}'),
                        ],
                      );
                    } else {
                      return const Text('Not signed in');
                    }
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final purchase = context.read<PurchaseProvider>();
                      final success = await purchase.ensureAuthentication();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Authentication successful!'), backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('❌ Authentication failed'), backgroundColor: Colors.red),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Test Authentication'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final purchase = context.read<PurchaseProvider>();
                      final token = await purchase.getIdToken();
                      if (token != null) {
                        await Clipboard.setData(ClipboardData(text: token));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🔑 ID Token copied to clipboard!'), backgroundColor: Colors.blue),
                        );
                        print('🔑 Full ID Token: $token');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('❌ Failed to get ID token'), backgroundColor: Colors.red),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Get ID Token for Testing'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Force app restart to check for patches
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔄 Restart app to check for patches!'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Check for Patches'),
                ),
              ],
            ),
          ),
          
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
    required PurchaseProvider purchase,
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
