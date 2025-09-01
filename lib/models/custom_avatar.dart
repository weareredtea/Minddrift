// lib/models/custom_avatar.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CustomAvatar {
  final String id;
  final String userId;
  final String imageUrl;
  final String? name;
  final DateTime createdAt;
  final bool isActive;

  const CustomAvatar({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.name,
    required this.createdAt,
    required this.isActive,
  });

  // Create from Firestore document
  factory CustomAvatar.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomAvatar(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'name': name,
      'createdAt': createdAt,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  CustomAvatar copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? name,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return CustomAvatar(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
