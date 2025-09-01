// lib/services/category_service.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/category_data.dart';
import '../providers/purchase_provider.dart';

class CategoryService {
  // Cache for filtered categories to avoid repeated filtering
  static final Map<String, List<CategoryItem>> _categoryCache = {};
  
  /// Get available categories based on user's owned bundles
  static List<CategoryItem> getAvailableCategories(Set<String> ownedBundles) {
    final cacheKey = ownedBundles.join(',');
    
    // Return cached result if available
    if (_categoryCache.containsKey(cacheKey)) {
      return _categoryCache[cacheKey]!;
    }
    
    // Filter categories based on owned bundles
    final availableCategories = allCategories.where((category) => 
      ownedBundles.contains(category.bundleId) || 
      ownedBundles.contains('all_access')
    ).toList();
    
    // Cache the result
    _categoryCache[cacheKey] = availableCategories;
    
    return availableCategories;
  }
  
  /// Get a random category from available categories
  static CategoryItem? getRandomCategory(Set<String> ownedBundles, List<String> usedCategoryIds) {
    final availableCategories = getAvailableCategories(ownedBundles);
    
    // Filter out used categories
    final unusedCategories = availableCategories
        .where((category) => !usedCategoryIds.contains(category.id))
        .toList();
    
    // If all categories are used, reset and use all available categories
    if (unusedCategories.isEmpty) {
      return availableCategories.isNotEmpty 
          ? availableCategories[DateTime.now().millisecondsSinceEpoch % availableCategories.length]
          : null;
    }
    
    // Return random unused category
    return unusedCategories[DateTime.now().millisecondsSinceEpoch % unusedCategories.length];
  }
  
  /// Get categories by bundle ID
  static List<CategoryItem> getCategoriesByBundle(String bundleId) {
    return allCategories.where((category) => category.bundleId == bundleId).toList();
  }
  
  /// Get bundle info for a category
  static String getBundleIdForCategory(String categoryId) {
    final category = allCategories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryItem(id: '', left: '', right: '', bundleId: 'bundle.free'),
    );
    return category.bundleId;
  }
  
  /// Clear cache (useful when user purchases new bundles)
  static void clearCache() {
    _categoryCache.clear();
  }
  
  /// Get localized category text
  static String getLocalizedCategoryText(BuildContext context, String categoryId, bool isLeft) {
    final locale = Localizations.localeOf(context).languageCode;
    final category = allCategories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryItem(id: '', left: '', right: '', bundleId: 'bundle.free'),
    );
    
    return isLeft ? category.getLeftText(locale) : category.getRightText(locale);
  }
}

/// Extension to easily access CategoryService from BuildContext
extension CategoryServiceExtension on BuildContext {
  List<CategoryItem> get availableCategories {
    final purchaseProvider = Provider.of<PurchaseProvider>(this, listen: false);
    return CategoryService.getAvailableCategories(purchaseProvider.ownedBundles);
  }
  
  CategoryItem? getRandomCategory(List<String> usedCategoryIds) {
    final purchaseProvider = Provider.of<PurchaseProvider>(this, listen: false);
    return CategoryService.getRandomCategory(purchaseProvider.ownedBundles, usedCategoryIds);
  }
}
