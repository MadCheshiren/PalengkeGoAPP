class ProductStock {
  final String productId;
  final int availableCount;
  
  ProductStock({
    required this.productId,
    required this.availableCount,
  });

  bool get isLowStock => availableCount > 0 && availableCount <= 5;
  bool get isOutOfStock => availableCount == 0;
}

class OrderCancellationWindow {
  final String orderId;
  final DateTime placedAt;
  final DateTime cancelUntil;

  OrderCancellationWindow({
    required this.orderId,
    required this.placedAt,
    required this.cancelUntil,
  });

  bool get canCancel => DateTime.now().isBefore(cancelUntil);
}

class OrderEta {
  final String orderId;
  final DateTime estimatedTime;
  final String type; // 'pickup' or 'delivery'

  OrderEta({
    required this.orderId,
    required this.estimatedTime,
    required this.type,
  });
}

class Promo {
  final String id;
  final String title;
  final double discountPercentage;
  final DateTime validUntil;
  final List<String> eligibleProductIds;

  Promo({
    required this.id,
    required this.title,
    required this.discountPercentage,
    required this.validUntil,
    required this.eligibleProductIds,
  });

  bool get isValid => DateTime.now().isBefore(validUntil);
}

class VendorReviewSummary {
  final String vendorId;
  final double averageRating;
  final int totalReviews;
  final String topReviewText;

  VendorReviewSummary({
    required this.vendorId,
    required this.averageRating,
    required this.totalReviews,
    required this.topReviewText,
  });
}

class OrderRating {
  final String orderId;
  final int rating;
  final String comment;

  OrderRating({
    required this.orderId,
    required this.rating,
    required this.comment,
  });
}

class SalesReport {
  final String dateRange; // e.g. "Today", "This Week"
  final double totalRevenue;
  final int totalOrders;
  final Map<String, double> breakdownByCustomer;

  SalesReport({
    required this.dateRange,
    required this.totalRevenue,
    required this.totalOrders,
    required this.breakdownByCustomer,
  });
}
