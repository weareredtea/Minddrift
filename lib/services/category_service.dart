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
  
  /// Get positive (left pole) text
  static String getPositiveCategoryText(BuildContext context, String categoryId) {
    final locale = Localizations.localeOf(context).languageCode;
    if (categoryId.isEmpty) {
      print('⚠️ CategoryService: categoryId is empty');
      return 'LEFT';
    }
    final category = allCategories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () {
        print('⚠️ CategoryService: Category not found for ID: $categoryId');
        return CategoryItem(id: '', positive: const {'en': 'LEFT'}, negative: const {'en': 'RIGHT'}, bundleId: 'bundle.free');
      },
    );
    final result = category.getPositiveText(locale);
    if (result.isEmpty) {
      print('⚠️ CategoryService: Empty positive text for categoryId: $categoryId, locale: $locale');
      return 'LEFT';
    }
    return result;
  }

  /// Get negative (right pole) text
  static String getNegativeCategoryText(BuildContext context, String categoryId) {
    final locale = Localizations.localeOf(context).languageCode;
    if (categoryId.isEmpty) {
      print('⚠️ CategoryService: categoryId is empty');
      return 'RIGHT';
    }
    final category = allCategories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () {
        print('⚠️ CategoryService: Category not found for ID: $categoryId');
        return CategoryItem(id: '', positive: const {'en': 'LEFT'}, negative: const {'en': 'RIGHT'}, bundleId: 'bundle.free');
      },
    );
    final result = category.getNegativeText(locale);
    if (result.isEmpty) {
      print('⚠️ CategoryService: Empty negative text for categoryId: $categoryId, locale: $locale');
      return 'RIGHT';
    }
    return result;
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
