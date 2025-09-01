// lib/screens/custom_username_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/custom_username.dart';
import '../providers/premium_provider.dart';
import '../l10n/app_localizations.dart';

class CustomUsernameScreen extends StatefulWidget {
  static const routeName = '/custom-username';
  
  const CustomUsernameScreen({super.key});

  @override
  State<CustomUsernameScreen> createState() => _CustomUsernameScreenState();
}

class _CustomUsernameScreenState extends State<CustomUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  bool _isAvailable = false;
  CustomUsername? _currentUsername;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('custom_usernames')
          .where('userId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Failed to load current username. Please try again.');
            },
          );

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _currentUsername = CustomUsername.fromFirestore(snapshot.docs.first);
          _usernameController.text = _currentUsername!.username;
        });
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Operation timed out'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load current username: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkAvailability(String username) async {
    if (username.isEmpty) {
      setState(() {
        _isAvailable = false;
        _isCheckingAvailability = false;
      });
      return;
    }

    setState(() => _isCheckingAvailability = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('custom_usernames')
          .where('username', isEqualTo: username.toLowerCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Failed to check username availability. Please try again.');
            },
          );

      setState(() {
        _isAvailable = snapshot.docs.isEmpty;
        _isCheckingAvailability = false;
      });
    } on TimeoutException catch (e) {
      setState(() => _isCheckingAvailability = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Operation timed out'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isCheckingAvailability = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check availability: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveUsername() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isAvailable) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim().toLowerCase();
      
      // Deactivate current username if exists
      if (_currentUsername != null) {
        await FirebaseFirestore.instance
            .collection('custom_usernames')
            .doc(_currentUsername!.id)
            .update({'isActive': false})
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                throw TimeoutException('Failed to update existing username. Please try again.');
              },
            );
      }

      // Create new username
      final customUsername = CustomUsername(
        id: '', // Will be set by Firestore
        userId: user.uid,
        username: username,
        createdAt: DateTime.now(),
        isActive: true,
        isVerified: true,
      );

      await FirebaseFirestore.instance
          .collection('custom_usernames')
          .add(customUsername.toFirestore())
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Failed to save username. Please try again.');
            },
          );

      // Update user profile
      await user.updateDisplayName(username).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Failed to update profile. Please try again.');
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Operation timed out'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _saveUsername,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update username: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _saveUsername,
            ),
          ),
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
        title: const Text('Custom Username'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Consumer<PremiumProvider>(
        builder: (context, premium, child) {
          if (!premium.hasCustomUsername) {
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
                    'Upgrade to Premium to set custom usernames',
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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current username display
                  if (_currentUsername != null) ...[
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
                          Text(
                            'Current Username',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentUsername!.username,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Username input
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'New Username',
                      labelStyle: const TextStyle(color: Colors.grey),
                      hintText: 'Enter your custom username',
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
                      suffixIcon: _isCheckingAvailability
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _usernameController.text.isNotEmpty
                              ? Icon(
                                  _isAvailable ? Icons.check_circle : Icons.cancel,
                                  color: _isAvailable ? Colors.green : Colors.red,
                                )
                              : null,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _checkAvailability(value.trim().toLowerCase());
                      } else {
                        setState(() {
                          _isAvailable = false;
                          _isCheckingAvailability = false;
                        });
                      }
                    },
                    validator: (value) {
                      final error = CustomUsername.getValidationError(value ?? '');
                      if (error != null) return error;
                      if (!_isAvailable && value!.isNotEmpty) {
                        return 'Username is not available';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Availability status
                  if (_usernameController.text.isNotEmpty && !_isCheckingAvailability)
                    Text(
                      _isAvailable ? 'Username is available!' : 'Username is not available',
                      style: TextStyle(
                        color: _isAvailable ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Save button
                  ElevatedButton(
                    onPressed: (_isLoading || !_isAvailable) ? null : _saveUsername,
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
                            'Save Username',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 24),

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
                              'Username Guidelines',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 3-20 characters long\n• Letters, numbers, and underscores only\n• Must be unique across all users\n• Cannot be changed frequently',
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
