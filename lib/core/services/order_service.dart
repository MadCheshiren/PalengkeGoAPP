import 'package:flutter/foundation.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_line_item.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';

final globalOrders = OrderService();

class OrderService extends ChangeNotifier {
  final List<MarketOrder> _orders = [
    MarketOrder(
      id: '#88293',
      vendorName: 'Aling Nena\'s Vegetable Stall',
      vendorImage:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=200&auto=format&fit=crop',
      status: OrderStatus.pending,
      placedAt: DateTime(2023, 10, 24, 10, 30),
      isPickup: false,
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
      isPickup: true,
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
      isPickup: false,
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
      status: OrderStatus.confirmed,
      placedAt: DateTime(2023, 10, 25, 9, 15),
      isPickup: false,
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

  int _nextOrderNumber = 89000;

  List<MarketOrder> get orders {
    final sorted = List<MarketOrder>.from(_orders);
    sorted.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return List<MarketOrder>.unmodifiable(sorted);
  }

  List<MarketOrder> placeOrders({required List<CartItem> items, required bool isPickup}) {
    if (items.isEmpty) {
      return [];
    }

    final Map<String, List<CartItem>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.vendorName, () => []);
      grouped[item.vendorName]!.add(item);
    }

    final createdOrders = <MarketOrder>[];

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
        id: '#${_nextOrderNumber++}',
        vendorName: entry.key,
        vendorImage: entry.value.first.image,
        status: isPickup ? OrderStatus.pending : OrderStatus.confirmed,
        placedAt: DateTime.now(),
        items: orderItems,
        isPickup: isPickup,
      );

      _orders.add(order);
      createdOrders.add(order);
    }

    notifyListeners();
    return createdOrders;
  }
}
