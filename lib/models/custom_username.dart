// lib/models/custom_username.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CustomUsername {
  final String id;
  final String userId;
  final String username;
  final DateTime createdAt;
  final bool isActive;
  final bool isVerified; // To prevent duplicate usernames

  const CustomUsername({
    required this.id,
    required this.userId,
    required this.username,
    required this.createdAt,
    required this.isActive,
    required this.isVerified,
  });

  // Create from Firestore document
  factory CustomUsername.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomUsername(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'createdAt': createdAt,
      'isActive': isActive,
      'isVerified': isVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  CustomUsername copyWith({
    String? id,
    String? userId,
    String? username,
    DateTime? createdAt,
    bool? isActive,
    bool? isVerified,
  }) {
    return CustomUsername(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  // Validate username format
  static bool isValidUsername(String username) {
    // Username must be 3-20 characters, alphanumeric and underscores only
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return regex.hasMatch(username);
  }

  // Get validation error message
  static String? getValidationError(String username) {
    if (username.isEmpty) {
      return 'Username cannot be empty';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (username.length > 20) {
      return 'Username must be 20 characters or less';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }
}
