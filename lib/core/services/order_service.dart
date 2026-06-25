import 'package:flutter/foundation.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_line_item.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/domain/fulfillment_method.dart';
import 'package:palengkego/features/orders/domain/payment_status.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/mock/mock_data.dart';
import 'package:palengkego/features/vendors/application/vendor_provider.dart';
import 'package:palengkego/features/profile/application/profile_provider.dart';

/// Callback fired after an order status changes.
/// Provides the orderId, vendorName, and the new status so the
/// notification layer can react without coupling to Riverpod.
typedef OrderStatusChangedCallback =
    void Function(String orderId, String vendorName, OrderStatus newStatus);

class OrderService extends ChangeNotifier {
  final Ref? ref;
  OrderService({this.ref});
  static const cancelWindow = Duration(minutes: 5);

  /// Optional callback wired by [orderServiceProvider] to route
  /// status-change events into [NotificationService].
  OrderStatusChangedCallback? onStatusChanged;
  final List<MarketOrder> _orders = [
    MarketOrder(
      id: '#88293',
      vendorName: 'Aling Nena\'s Vegetable Stall',
      vendorImage:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=200&auto=format&fit=crop',
      status: OrderStatus.completed,
      placedAt: DateTime(2023, 10, 24, 10, 30),
      paymentStatus: PaymentStatus.paid,
      fulfillmentMethod: FulfillmentMethod.delivery,
      deliveryAddress: '123 Main St, Manila',
      deliveryFee: 49.0,
      serviceFee: 15.0,
      items: const [
        OrderLineItem(
          productName: 'Pork Belly',
          quantity: 1,
          unitPrice: 280,
          weight: '1kg',
          pricePerKg: 'PHP 280/kg',
          image:
              'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300&h=300&fit=crop',
        ),
        OrderLineItem(
          productName: 'Carrots',
          quantity: 1,
          unitPrice: 120,
          weight: '500g',
          pricePerKg: 'PHP 120/500g',
          image:
              'https://images.unsplash.com/photo-1447175008436-054170c2e979?q=80&w=300&auto=format&fit=crop',
        ),
        OrderLineItem(
          productName: 'Baguio Beans',
          quantity: 1,
          unitPrice: 140,
          weight: '500g',
          pricePerKg: 'PHP 140/500g',
          image:
              'https://images.unsplash.com/photo-1567375698348-5d9d5ae99de0?q=80&w=300&auto=format&fit=crop',
        ),
      ],
    ),
    MarketOrder(
      id: '#88102',
      vendorName: 'Mang Juan\'s Fresh Fish',
      vendorImage:
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=200&auto=format&fit=crop',
      status: OrderStatus.completed,
      placedAt: DateTime(2023, 10, 22, 8, 15),
      paymentStatus: PaymentStatus.pending,
      fulfillmentMethod: FulfillmentMethod.pickup,
      deliveryFee: 0.0,
      serviceFee: 15.0,
      items: const [
        OrderLineItem(
          productName: 'Bangus',
          quantity: 2,
          unitPrice: 90,
          weight: '1pc',
          pricePerKg: 'PHP 90/pc',
          image:
              'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&h=300&fit=crop',
        ),
        OrderLineItem(
          productName: 'Tilapia',
          quantity: 1,
          unitPrice: 120,
          weight: '1kg',
          pricePerKg: 'PHP 120/kg',
          image:
              'https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?w=300&h=300&fit=crop',
        ),
        OrderLineItem(
          productName: 'Tahong',
          quantity: 1,
          unitPrice: 80,
          weight: '1kg',
          pricePerKg: 'PHP 80/kg',
          image:
              'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?q=80&w=300&auto=format&fit=crop',
        ),
      ],
    ),
    MarketOrder(
      id: '#87955',
      vendorName: 'Daily Meat Shop',
      vendorImage:
          'https://images.unsplash.com/photo-1602470520998-f4a52199a3d6?q=80&w=200&auto=format&fit=crop',
      status: OrderStatus.cancelled,
      placedAt: DateTime(2023, 10, 20, 14, 45),
      paymentStatus: PaymentStatus.failed,
      fulfillmentMethod: FulfillmentMethod.delivery,
      deliveryAddress: '456 Elm St, Quezon City',
      deliveryFee: 49.0,
      serviceFee: 15.0,
      items: const [
        OrderLineItem(
          productName: 'Ground Beef',
          quantity: 1,
          unitPrice: 350,
          weight: '1kg',
          pricePerKg: 'PHP 350/kg',
          image:
              'https://images.unsplash.com/photo-1602470520998-f4a52199a3d6?w=300&h=300&fit=crop',
        ),
        OrderLineItem(
          productName: 'Chicken Breast',
          quantity: 1,
          unitPrice: 70,
          weight: '500g',
          pricePerKg: 'PHP 70/500g',
          image:
              'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=300&h=300&fit=crop',
        ),
      ],
    ),
    MarketOrder(
      id: '#88301',
      vendorName: 'Bicol Fruits Center',
      vendorImage:
          'https://images.unsplash.com/photo-1488459716781-31db52582fe9?q=80&w=200&auto=format&fit=crop',
      status: OrderStatus.completed,
      placedAt: DateTime(2023, 10, 25, 9, 15),
      paymentStatus: PaymentStatus.paid,
      fulfillmentMethod: FulfillmentMethod.delivery,
      deliveryAddress: '789 Pine St, Makati',
      deliveryFee: 49.0,
      serviceFee: 15.0,
      items: const [
        OrderLineItem(
          productName: 'Pineapple',
          quantity: 2,
          unitPrice: 55,
          weight: '1pc',
          pricePerKg: 'PHP 55/pc',
          image:
              'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=300&h=300&fit=crop',
        ),
        OrderLineItem(
          productName: 'Watermelon',
          quantity: 1,
          unitPrice: 100,
          weight: '1pc',
          pricePerKg: 'PHP 100/pc',
          image:
              'https://images.unsplash.com/photo-1563114773-84221bd62daa?q=80&w=300&auto=format&fit=crop',
        ),
        OrderLineItem(
          productName: 'Mangoes',
          quantity: 1,
          unitPrice: 70,
          weight: '1kg',
          pricePerKg: 'PHP 70/kg',
          image:
              'https://images.unsplash.com/photo-1553279768-865429fa0078?w=300&h=300&fit=crop',
        ),
      ],
    ),
  ];

  int _dailySequence = 1;
  String _lastDateString = '';

  List<MarketOrder> get orders {
    final sorted = List<MarketOrder>.from(_orders);
    sorted.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return List<MarketOrder>.unmodifiable(sorted);
  }

  List<MarketOrder> placeOrders({
    required List<CartItem> items,
    required bool isPickup,
    Map<String, String>? vendorNotes,
  }) {
    if (items.isEmpty) {
      return [];
    }

    final Map<String, List<CartItem>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.vendorName, () => []);
      grouped[item.vendorName]!.add(item);
    }

    final createdOrders = <MarketOrder>[];
    
    String customerName = 'Customer';
    if (ref != null) {
      final profile = ref!.read(currentProfileProvider).value;
      if (profile != null && profile.displayName.isNotEmpty) {
        customerName = profile.displayName;
      }
    }

    final now = DateTime.now();
    final dateString = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    if (dateString != _lastDateString) {
      _lastDateString = dateString;
      _dailySequence = 1;
    }

    final Set<String> affectedVendors = {};

    for (final entry in grouped.entries) {
      final orderItems = entry.value
          .map(
            (item) => OrderLineItem(
              productName: item.productName,
              quantity: item.quantity,
              unitPrice: item.price,
              weight: item.weight,
              pricePerKg: item.pricePerKg,
              image: item.image,
            ),
          )
          .toList();

      final order = MarketOrder(
        id: '#$dateString${_dailySequence++}',
        vendorName: entry.key,
        vendorImage: entry.value.first.image,
        customerName: customerName,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        fulfillmentMethod: isPickup
            ? FulfillmentMethod.pickup
            : FulfillmentMethod.delivery,
        deliveryAddress: isPickup ? null : '123 Default Address',
        deliveryFee: isPickup ? 0.0 : 49.0,
        serviceFee: 15.0,
        placedAt: DateTime.now(),
        items: orderItems,
        notes: vendorNotes?[entry.key],
      );

      _orders.add(order);
      createdOrders.add(order);
      
      // Decrease stock
      for (final item in entry.value) {
        MockDataService.decreaseProductStockByName(item.productName, entry.key, item.quantity);
        affectedVendors.add(entry.key);
      }
    }

    if (ref != null) {
      for (final vendorName in affectedVendors) {
        final vendorId = MockDataService.featuredVendors.firstWhere((v) => v['name'] == vendorName, orElse: () => {'id': ''})['id'] as String;
        if (vendorId.isNotEmpty) {
          ref!.invalidate(vendorProductsProvider(vendorId));
        }
      }
    }

    notifyListeners();
    return createdOrders;
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      _orders[index] = order.copyWith(status: newStatus);
      notifyListeners();
      // Notify the notification layer (wired by orderServiceProvider).
      onStatusChanged?.call(orderId, order.vendorName, newStatus);
    }
  }

  bool cancelOrder(String orderId, {DateTime? now}) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return false;
    }

    final order = _orders[index];
    if (order.status == OrderStatus.completed ||
        order.status == OrderStatus.cancelled) {
      return false;
    }

    final currentTime = now ?? DateTime.now();
    final cancelUntil = order.placedAt.add(cancelWindow);
    if (currentTime.isAfter(cancelUntil)) {
      return false;
    }

    _orders[index] = order.copyWith(status: OrderStatus.cancelled);
    notifyListeners();
    onStatusChanged?.call(orderId, order.vendorName, OrderStatus.cancelled);
    return true;
  }
}
