// lib/screens/gem_store_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';
import '../models/player_wallet.dart';
import '../data/cosmetic_catalog.dart';
import '../l10n/app_localizations.dart';

class GemStoreScreen extends StatefulWidget {
  static const routeName = '/gem-store';
  
  const GemStoreScreen({super.key});

  @override
  State<GemStoreScreen> createState() => _GemStoreScreenState();
}

class _GemStoreScreenState extends State<GemStoreScreen> with SingleTickerProviderStateMixin {
  PlayerWallet? _wallet;
  bool _isLoading = true;
  String? _error;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWallet();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final wallet = await WalletService.getWallet();

      setState(() {
        _wallet = wallet;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '${AppLocalizations.of(context)!.error}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.diamond, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.gemStoreTitle,
              style: const TextStyle(
                fontFamily: 'LuckiestGuy',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (_wallet != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withAlpha(150)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_wallet!.mindGems}',
                      style: const TextStyle(
                        fontFamily: 'LuckiestGuy',
                        fontSize: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: [
            Tab(
              icon: const Icon(Icons.palette),
              text: AppLocalizations.of(context)!.sliderSkins,
            ),
            Tab(
              icon: const Icon(Icons.military_tech),
              text: AppLocalizations.of(context)!.badges,
            ),
            Tab(
              icon: const Icon(Icons.people),
              text: AppLocalizations.of(context)!.avatarPacks,
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Loading Store...',
              style: TextStyle(
                fontFamily: 'Chewy',
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Chewy',
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWallet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: const TextStyle(fontFamily: 'LuckiestGuy'),
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildSliderSkinsTab(),
        _buildBadgesTab(),
        _buildAvatarPacksTab(),
      ],
    );
  }

  Widget _buildSliderSkinsTab() {
    final sliderSkins = CosmeticCatalog.sliderSkins;
    
    return _buildItemGrid(sliderSkins);
  }

  Widget _buildBadgesTab() {
    final badges = CosmeticCatalog.badges;
    
    return _buildItemGrid(badges);
  }

  Widget _buildAvatarPacksTab() {
    final avatarPacks = CosmeticCatalog.getItemsByType(CosmeticType.avatarPack);
    
    return _buildItemGrid(avatarPacks);
  }

  Widget _buildItemGrid(List<CosmeticItem> items) {
    return RefreshIndicator(
      onRefresh: _loadWallet,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildItemCard(items[index]);
          },
        ),
      ),
    );
  }

  Widget _buildItemCard(CosmeticItem item) {
    final isOwned = _isItemOwned(item);
    final canAfford = _wallet?.canAfford(item.gemPrice) ?? false;
    final rarityColor = Color(int.parse(CosmeticCatalog.getRarityColor(item.rarity).substring(1), radix: 16) + 0xFF000000);

    return Card(
      color: const Color(0xFF2A2A4A),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOwned ? Colors.green : rarityColor.withAlpha(100),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isOwned ? null : () => _purchaseItem(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item preview/icon
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: rarityColor.withAlpha(50)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getItemIcon(item.type),
                        size: 48,
                        color: rarityColor,
                      ),
                      if (item.isAnimated) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withAlpha(100),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:                           Text(
                            AppLocalizations.of(context)!.animated,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Item name
              Text(
                item.name,
                style: const TextStyle(
                  fontFamily: 'LuckiestGuy',
                  fontSize: 14,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Rarity
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: rarityColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  CosmeticCatalog.getRarityDisplayName(item.rarity),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: rarityColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Price/Status
              if (isOwned)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.owned,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'LuckiestGuy',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: canAfford ? Colors.amber.withAlpha(100) : Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.diamond,
                        size: 16,
                        color: canAfford ? Colors.amber : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.gemPrice}',
                        style: TextStyle(
                          fontFamily: 'LuckiestGuy',
                          fontSize: 12,
                          color: canAfford ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isItemOwned(CosmeticItem item) {
    if (_wallet == null) return false;
    
    switch (item.type) {
      case CosmeticType.sliderSkin:
        return _wallet!.ownsSliderSkin(item.id);
      case CosmeticType.badge:
        return _wallet!.ownsBadge(item.id);
      case CosmeticType.avatarPack:
        return _wallet!.ownsAvatarPack(item.id);
    }
  }

  IconData _getItemIcon(CosmeticType type) {
    switch (type) {
      case CosmeticType.sliderSkin:
        return Icons.palette;
      case CosmeticType.badge:
        return Icons.military_tech;
      case CosmeticType.avatarPack:
        return Icons.people;
    }
  }

  Future<void> _purchaseItem(CosmeticItem item) async {
    if (_wallet == null) return;

    if (!_wallet!.canAfford(item.gemPrice)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.notEnoughGems} ${AppLocalizations.of(context)!.gems}: ${item.gemPrice - _wallet!.mindGems}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A4A),
        title: Text(
          AppLocalizations.of(context)!.confirmPurchase,
          style: const TextStyle(
            fontFamily: 'LuckiestGuy',
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Purchase "${item.name}" for ${item.gemPrice} Gems?',
              style: const TextStyle(
                fontFamily: 'Chewy',
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${_wallet!.mindGems} → ${_wallet!.mindGems - item.gemPrice}',
                  style: const TextStyle(
                    fontFamily: 'LuckiestGuy',
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: Text(
              AppLocalizations.of(context)!.purchase,
              style: const TextStyle(fontFamily: 'LuckiestGuy'),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Attempt purchase
    try {
      final success = await WalletService.purchaseItem(item);
      
      if (success) {
        HapticFeedback.heavyImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.purchaseSuccessful} ${item.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload wallet to reflect changes
        await _loadWallet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.purchaseFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorGeneric}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
