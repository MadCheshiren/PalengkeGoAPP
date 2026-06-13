import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/vendors/application/vendor_orders_provider.dart';

void main() {
  CartItem cartItem({
    String vendorName = "Juan's Fresh Catch",
    String productName = 'Bangus',
  }) {
    return CartItem(
      vendorName: vendorName,
      productName: productName,
      price: 120,
      weight: '1kg',
      pricePerKg: 'PHP 120/kg',
      image: 'bangus.png',
    );
  }

  ProviderContainer buildContainer(OrderService orderService) {
    final container = ProviderContainer(
      overrides: [orderServiceProvider.overrideWithValue(orderService)],
    );
    addTearDown(container.dispose);
    addTearDown(orderService.dispose);
    return container;
  }

  group('VendorOrdersNotifier', () {
    test('filters orders for the current vendor stall', () {
      final orderService = OrderService()
        ..placeOrders(
          isPickup: false,
          items: [
            cartItem(),
            cartItem(vendorName: 'Other Stall', productName: 'Tomato'),
          ],
        );
      final container = buildContainer(orderService);

      final vendorOrders = container.read(vendorOrdersProvider);

      expect(vendorOrders.map((order) => order.vendorName).toSet(), {
        "Juan's Fresh Catch",
      });
      expect(
        vendorOrders.any((order) => order.vendorName == 'Other Stall'),
        isFalse,
      );
    });

    test('acceptOrder moves a pending vendor order to preparing', () {
      final orderService = OrderService()
        ..placeOrders(isPickup: false, items: [cartItem()]);
      final container = buildContainer(orderService);
      final orderId = container
          .read(vendorOrdersProvider)
          .firstWhere((order) => order.status == OrderStatus.pending)
          .id;

      container.read(vendorOrdersProvider.notifier).acceptOrder(orderId);

      final updatedOrder = container
          .read(vendorOrdersProvider)
          .firstWhere((order) => order.id == orderId);
      expect(updatedOrder.status, OrderStatus.preparing);
    });

    test('rejectOrder moves a pending vendor order to cancelled', () {
      final orderService = OrderService()
        ..placeOrders(isPickup: false, items: [cartItem()]);
      final container = buildContainer(orderService);
      final orderId = container
          .read(vendorOrdersProvider)
          .firstWhere((order) => order.status == OrderStatus.pending)
          .id;

      container.read(vendorOrdersProvider.notifier).rejectOrder(orderId);

      final updatedOrder = container
          .read(vendorOrdersProvider)
          .firstWhere((order) => order.id == orderId);
      expect(updatedOrder.status, OrderStatus.cancelled);
    });

    test('markOrderReady moves an accepted vendor order to ready', () {
      final orderService = OrderService()
        ..placeOrders(isPickup: false, items: [cartItem()]);
      final container = buildContainer(orderService);
      final orderId = container
          .read(vendorOrdersProvider)
          .firstWhere((order) => order.status == OrderStatus.pending)
          .id;

      container.read(vendorOrdersProvider.notifier).acceptOrder(orderId);
      container.read(vendorOrdersProvider.notifier).markOrderReady(orderId);

      final updatedOrder = container
          .read(vendorOrdersProvider)
          .firstWhere((order) => order.id == orderId);
      expect(updatedOrder.status, OrderStatus.ready);
    });

    test('completeOrder moves a ready vendor order to completed', () {
      final orderService = OrderService()
        ..placeOrders(isPickup: false, items: [cartItem()]);
      final container = buildContainer(orderService);
      final orderId = container
          .read(vendorOrdersProvider)
          .firstWhere((order) => order.status == OrderStatus.pending)
          .id;

      container.read(vendorOrdersProvider.notifier).acceptOrder(orderId);
      container.read(vendorOrdersProvider.notifier).markOrderReady(orderId);
      container.read(vendorOrdersProvider.notifier).completeOrder(orderId);

      final updatedOrder = container
          .read(vendorOrdersProvider)
          .firstWhere((order) => order.id == orderId);
      expect(updatedOrder.status, OrderStatus.completed);
    });
  });
}
