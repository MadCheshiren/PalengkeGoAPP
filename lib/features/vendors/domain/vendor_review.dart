/// The type of entity being reviewed.
enum ReviewType { vendor, product }

/// A single customer review for a vendor or one of their products.
class VendorReview {
  final String id;
  final String vendorId;
  final String customerName;
  final double rating;
  final String comment;
  final DateTime date;

  /// Whether the customer is reviewing the stall overall or a specific product.
  final ReviewType reviewType;

  /// Populated only when [reviewType] is [ReviewType.product].
  final String? productName;

  VendorReview({
    required this.id,
    required this.vendorId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
    this.reviewType = ReviewType.vendor,
    this.productName,
  });
}
