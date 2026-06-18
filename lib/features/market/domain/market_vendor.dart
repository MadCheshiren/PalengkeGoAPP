class MarketVendor {
  const MarketVendor({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.isVerified,
    required this.distance,
    required this.imageUrl,
    this.stallNumber,
    this.marketSection,
    this.reviewCount = 0,
    this.topReviewText,
  });

  final String id;
  final String name;
  final String category;
  final double rating;
  final bool isVerified;
  final String distance;
  final String imageUrl;
  final String? stallNumber;
  final String? marketSection;
  final int reviewCount;
  final String? topReviewText;

  factory MarketVendor.fromMap(Map<String, dynamic> map) {
    return MarketVendor(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Vendor',
      category: map['category'] as String? ?? 'General',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      isVerified: map['isVerified'] as bool? ?? false,
      distance: map['distance'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      stallNumber: map['stallNumber'] as String?,
      marketSection: map['marketSection'] as String?,
      reviewCount: map['reviewCount'] as int? ?? 0,
      topReviewText: map['topReviewText'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'rating': rating,
      'isVerified': isVerified,
      'distance': distance,
      'imageUrl': imageUrl,
      if (stallNumber != null) 'stallNumber': stallNumber,
      if (marketSection != null) 'marketSection': marketSection,
      'reviewCount': reviewCount,
      if (topReviewText != null) 'topReviewText': topReviewText,
    };
  }
}
