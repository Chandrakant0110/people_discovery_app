import 'package:cloud_firestore/cloud_firestore.dart';

/// Portfolio item model representing a work sample in user's portfolio
class PortfolioItem {
  final String portfolioId;
  final String userId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String title;
  final String? description;
  final String? projectUrl;
  final List<String> tags;
  final DateTime createdAt;
  final int order; // For sorting/ordering portfolio items

  PortfolioItem({
    required this.portfolioId,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.title,
    this.description,
    this.projectUrl,
    this.tags = const [],
    required this.createdAt,
    this.order = 0,
  });

  /// Create PortfolioItem from Firestore document
  factory PortfolioItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PortfolioItem(
      portfolioId: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      title: data['title'] ?? '',
      description: data['description'],
      projectUrl: data['projectUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      order: data['order'] ?? 0,
    );
  }

  /// Convert PortfolioItem to Firestore document map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'title': title,
      if (description != null) 'description': description,
      if (projectUrl != null) 'projectUrl': projectUrl,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'order': order,
    };
  }

  /// Create a copy of PortfolioItem with updated fields
  PortfolioItem copyWith({
    String? imageUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? projectUrl,
    List<String>? tags,
    int? order,
  }) {
    return PortfolioItem(
      portfolioId: portfolioId,
      userId: userId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      projectUrl: projectUrl ?? this.projectUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      order: order ?? this.order,
    );
  }
}

