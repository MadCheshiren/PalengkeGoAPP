import 'order_line_item.dart';
import 'order_status.dart';

class MarketOrder {
  final String id;
  final String vendorName;
  final String vendorImage;
  final OrderStatus status;
  final DateTime placedAt;
  final List<OrderLineItem> items;
  final bool isPickup;

  const MarketOrder({
    required this.id,
    required this.vendorName,
    required this.vendorImage,
    required this.status,
    required this.placedAt,
    required this.items,
    required this.isPickup,
  });

  double get total => items.fold<double>(0, (sum, item) => sum + item.total);

  String get statusLabel => status.label;
}
