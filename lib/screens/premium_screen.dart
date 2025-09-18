// lib/screens/premium_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/premium_provider.dart';
import '../providers/purchase_provider.dart';
import '../l10n/app_localizations.dart';

class PremiumScreen extends StatefulWidget {
  static const routeName = '/premium';
  
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(loc.premium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<PremiumProvider, PurchaseProvider>(
        builder: (context, premium, purchase, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Header
                _buildPremiumHeader(loc),
                const SizedBox(height: 32),
                
                // Debug Mode Indicator
                if (kDebugMode)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bug_report, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Debug Mode: Premium Access Enabled',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (kDebugMode) const SizedBox(height: 16),
                
                // Features List
                _buildFeaturesList(loc),
                const SizedBox(height: 32),
                
                // Subscription Status
                if (premium.isPremium) _buildPremiumStatus(premium, loc),
                const SizedBox(height: 32),
                
                // Purchase Button
                if (!premium.isPremium) _buildPurchaseButton(premium, purchase, loc),
                
                // Error Message
                if (premium.error != null) _buildErrorMessage(premium),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumHeader(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4B0082), Color(0xFF800080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            size: 64,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            loc.premiumTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            loc.premiumSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(AppLocalizations loc) {
    final features = [
      {
        'icon': Icons.face,
        'title': loc.avatarCustomization,
        'description': loc.avatarCustomizationDesc,
      },
      {
        'icon': Icons.chat_bubble,
        'title': loc.groupChat,
        'description': loc.groupChatDesc,
      },
      {
        'icon': Icons.mic,
        'title': loc.voiceChat,
        'description': loc.voiceChatDesc,
      },
      {
        'icon': Icons.people,
        'title': loc.onlineMatchmaking,
        'description': loc.onlineMatchmakingDesc,
      },
      {
        'icon': Icons.lightbulb,
        'title': AppLocalizations.of(context)!.suggestBundle,
        'description': AppLocalizations.of(context)!.pleaseEnterDescription,
      },
      {
        'icon': Icons.person,
        'title': AppLocalizations.of(context)!.customUsername,
        'description': AppLocalizations.of(context)!.upgradeToPremium,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.premiumFeatures,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureCard(feature)),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: Colors.purple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature['description']!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatus(PremiumProvider premium, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            loc.premiumActive,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            premium.statusText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.green[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton(
    PremiumProvider premium,
    PurchaseProvider purchase,
    AppLocalizations loc,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(
            children: [
              Text(
                '\$9.99',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.premiumPrice,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading || !purchase.isBillingAvailable
                ? null
                : () => _handlePurchase(purchase),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    loc.upgradeToPremium,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        if (!purchase.isBillingAvailable) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Text(
              loc.billingUnavailable,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange[200],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorMessage(PremiumProvider premium) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              premium.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red[200],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: premium.clearError,
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(PurchaseProvider purchase) async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement premium subscription purchase
      // This will be integrated with the existing PurchaseProvider
      // and Google Play Billing
      
      // For now, show a placeholder
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium purchase coming soon!'),
            backgroundColor: Colors.purple,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
