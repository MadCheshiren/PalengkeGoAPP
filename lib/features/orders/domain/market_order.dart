import 'order_line_item.dart';
import 'order_status.dart';

import 'fulfillment_method.dart';
import 'payment_status.dart';

class MarketOrder {
  final String id;
  final String vendorName;
  final String vendorImage;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final FulfillmentMethod fulfillmentMethod;
  final DateTime placedAt;
  final List<OrderLineItem> items;
  final String? deliveryAddress;
  final double deliveryFee;
  final double serviceFee;
  final String? notes;

  const MarketOrder({
    required this.id,
    required this.vendorName,
    required this.vendorImage,
    required this.status,
    required this.paymentStatus,
    required this.fulfillmentMethod,
    required this.placedAt,
    required this.items,
    this.deliveryAddress,
    required this.deliveryFee,
    required this.serviceFee,
    this.notes,
  });

  MarketOrder copyWith({
    String? id,
    String? vendorName,
    String? vendorImage,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    FulfillmentMethod? fulfillmentMethod,
    DateTime? placedAt,
    List<OrderLineItem>? items,
    String? deliveryAddress,
    double? deliveryFee,
    double? serviceFee,
    String? notes,
  }) {
    return MarketOrder(
      id: id ?? this.id,
      vendorName: vendorName ?? this.vendorName,
      vendorImage: vendorImage ?? this.vendorImage,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      fulfillmentMethod: fulfillmentMethod ?? this.fulfillmentMethod,
      placedAt: placedAt ?? this.placedAt,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      notes: notes ?? this.notes,
    );
  }

  double get subtotal => items.fold<double>(0, (sum, item) => sum + item.total);
  double get total => subtotal + deliveryFee + serviceFee;

  String get statusLabel => status.label;
  bool get isPickup => fulfillmentMethod == FulfillmentMethod.pickup;
}
