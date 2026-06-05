import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';

void main() {
  CartItem cartItem({
    required String vendorName,
    required String productName,
    required double price,
    String weight = '1kg',
    String pricePerKg = 'PHP 100/kg',
    String image = 'item.png',
    int quantity = 1,
  }) {
    return CartItem(
      vendorName: vendorName,
      productName: productName,
      price: price,
      weight: weight,
      pricePerKg: pricePerKg,
      image: image,
      quantity: quantity,
    );
  }

  group('OrderService', () {
    test('returns no orders for an empty cart item list', () {
      final service = OrderService();

      final orders = service.placeOrders(items: const [], isPickup: false);

      expect(orders, isEmpty);
    });

    test('groups created orders by vendor', () {
      final service = OrderService();

      final orders = service.placeOrders(
        isPickup: false,
        items: [
          cartItem(
            vendorName: 'Aling Nena',
            productName: 'Carrots',
            price: 120,
          ),
          cartItem(
            vendorName: 'Mang Juan',
            productName: 'Bangus',
            price: 90,
            weight: '1pc',
            pricePerKg: 'PHP 90/pc',
          ),
          cartItem(
            vendorName: 'Aling Nena',
            productName: 'Baguio Beans',
            price: 140,
            weight: '500g',
            pricePerKg: 'PHP 140/500g',
          ),
        ],
      );

      expect(orders, hasLength(2));
      expect(orders.map((order) => order.vendorName), [
        'Aling Nena',
        'Mang Juan',
      ]);
      expect(orders.first.items.map((item) => item.productName), [
        'Carrots',
        'Baguio Beans',
      ]);
      expect(orders.last.items.single.productName, 'Bangus');
    });

    test('copies cart item details into order line items', () {
      final service = OrderService();

      final orders = service.placeOrders(
        isPickup: false,
        items: [
          cartItem(
            vendorName: 'Aling Nena',
            productName: 'Carrots',
            price: 120,
            weight: '500g',
            pricePerKg: 'PHP 120/500g',
            image: 'carrots.png',
            quantity: 3,
          ),
        ],
      );

      final lineItem = orders.single.items.single;
      expect(lineItem.productName, 'Carrots');
      expect(lineItem.quantity, 3);
      expect(lineItem.unitPrice, 120);
      expect(lineItem.weight, '500g');
      expect(lineItem.pricePerKg, 'PHP 120/500g');
      expect(lineItem.image, 'carrots.png');
      expect(lineItem.total, 360);
    });

    test('pickup orders start as pending', () {
      final service = OrderService();

      final orders = service.placeOrders(
        isPickup: true,
        items: [
          cartItem(
            vendorName: 'Aling Nena',
            productName: 'Carrots',
            price: 120,
          ),
        ],
      );

      expect(orders.single.status, OrderStatus.pending);
      expect(orders.single.statusLabel, 'Pending');
      expect(orders.single.isPickup, isTrue);
    });

    test('delivery orders start as confirmed', () {
      final service = OrderService();

      final orders = service.placeOrders(
        isPickup: false,
        items: [
          cartItem(
            vendorName: 'Aling Nena',
            productName: 'Carrots',
            price: 120,
          ),
        ],
      );

      expect(orders.single.status, OrderStatus.confirmed);
      expect(orders.single.statusLabel, 'Confirmed');
      expect(orders.single.isPickup, isFalse);
    });
  });
}
