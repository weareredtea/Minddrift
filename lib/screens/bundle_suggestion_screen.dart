// lib/screens/bundle_suggestion_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bundle_suggestion.dart';
import '../providers/premium_provider.dart';
import '../l10n/app_localizations.dart';

class BundleSuggestionScreen extends StatefulWidget {
  static const routeName = '/bundle-suggestion';
  
  const BundleSuggestionScreen({super.key});

  @override
  State<BundleSuggestionScreen> createState() => _BundleSuggestionScreenState();
}

class _BundleSuggestionScreenState extends State<BundleSuggestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bundleNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedCategories = [];
  bool _isLoading = false;

  // Sample categories for suggestions
  final List<String> _availableCategories = [
    'Movies & TV Shows',
    'Music & Artists',
    'Sports & Athletes',
    'Food & Cuisine',
    'Travel & Destinations',
    'Technology & Gadgets',
    'Books & Literature',
    'Animals & Nature',
    'History & Events',
    'Science & Discovery',
    'Art & Culture',
    'Fashion & Style',
    'Games & Gaming',
    'Business & Finance',
    'Health & Fitness',
    'Education & Learning',
    'Hobbies & Activities',
    'Celebrities & Influencers',
    'Politics & Current Events',
    'Mythology & Folklore',
  ];

  @override
  void dispose() {
    _bundleNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _submitSuggestion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final suggestion = BundleSuggestion(
        id: '', // Will be set by Firestore
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        bundleName: _bundleNameController.text.trim(),
        description: _descriptionController.text.trim(),
        categories: _selectedCategories,
        status: SuggestionStatus.pending,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('bundle_suggestions')
          .add(suggestion.toFirestore());

      // Clear form
      _bundleNameController.clear();
      _descriptionController.clear();
      _selectedCategories.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bundle suggestion submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit suggestion: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Suggest Bundle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PremiumProvider>(
        builder: (context, premium, child) {
          if (!premium.hasBundleSuggestions) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Premium Feature',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upgrade to Premium to suggest bundles',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(loc.upgradeToPremium),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bundle name
                  TextFormField(
                    controller: _bundleNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Bundle Name',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a bundle name';
                      }
                      if (value.trim().length < 3) {
                        return 'Bundle name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: const TextStyle(color: Colors.grey),
                      hintText: 'Describe what this bundle should contain...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.trim().length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Categories section
                  Text(
                    'Select Categories (${_selectedCategories.length}/5)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose up to 5 categories that would fit this bundle',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categories grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCategories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      final isDisabled = !isSelected && _selectedCategories.length >= 5;

                      return FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                          ),
                        ),
                        selected: isSelected,
                        onSelected: isDisabled ? null : (_) => _toggleCategory(category),
                        backgroundColor: Colors.grey[800],
                        selectedColor: Colors.purple,
                        checkmarkColor: Colors.white,
                        disabledColor: Colors.grey[700],
                        labelStyle: TextStyle(
                          color: isDisabled ? Colors.grey[500] : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitSuggestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Suggestion',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'How it works',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your bundle suggestions will be reviewed by our team. If approved, they may be added to the game for all players to enjoy!',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
