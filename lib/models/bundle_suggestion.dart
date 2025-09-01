// lib/models/bundle_suggestion.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum SuggestionStatus {
  pending,
  approved,
  rejected,
  implemented,
}

class BundleSuggestion {
  final String id;
  final String userId;
  final String userName;
  final String bundleName;
  final String description;
  final List<String> categories;
  final SuggestionStatus status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const BundleSuggestion({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bundleName,
    required this.description,
    required this.categories,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.reviewedAt,
  });

  // Create from Firestore document
  factory BundleSuggestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BundleSuggestion(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      bundleName: data['bundleName'] ?? '',
      description: data['description'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      status: SuggestionStatus.values.firstWhere(
        (e) => e.toString() == 'SuggestionStatus.${data['status']}',
        orElse: () => SuggestionStatus.pending,
      ),
      adminNotes: data['adminNotes'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      reviewedAt: data['reviewedAt']?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'bundleName': bundleName,
      'description': description,
      'categories': categories,
      'status': status.toString().split('.').last,
      'adminNotes': adminNotes,
      'createdAt': createdAt,
      'reviewedAt': reviewedAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  BundleSuggestion copyWith({
    String? id,
    String? userId,
    String? userName,
    String? bundleName,
    String? description,
    List<String>? categories,
    SuggestionStatus? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? reviewedAt,
  }) {
    return BundleSuggestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bundleName: bundleName ?? this.bundleName,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case SuggestionStatus.pending:
        return '#FFA500'; // Orange
      case SuggestionStatus.approved:
        return '#4CAF50'; // Green
      case SuggestionStatus.rejected:
        return '#F44336'; // Red
      case SuggestionStatus.implemented:
        return '#2196F3'; // Blue
    }
  }

  // Get status text
  String get statusText {
    switch (status) {
      case SuggestionStatus.pending:
        return 'Pending Review';
      case SuggestionStatus.approved:
        return 'Approved';
      case SuggestionStatus.rejected:
        return 'Rejected';
      case SuggestionStatus.implemented:
        return 'Implemented';
    }
  }

  // Check if suggestion is active (not rejected)
  bool get isActive => status != SuggestionStatus.rejected;
}
