import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/vendors/presentation/widgets/floating_new_order_notification.dart';

void main() {
  CartItem cartItem() {
    return const CartItem(
      vendorName: "Juan's Fresh Catch",
      productName: 'Bangus',
      price: 120,
      weight: '1kg',
      pricePerKg: 'PHP 120/kg',
      image: 'bangus.png',
    );
  }

  Widget buildWidget(OrderService orderService, {VoidCallback? onViewOrders}) {
    return ProviderScope(
      overrides: [orderServiceProvider.overrideWithValue(orderService)],
      child: MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FloatingNewOrderNotification(onViewOrders: onViewOrders ?? () {}),
            ],
          ),
        ),
      ),
    );
  }

  group('FloatingNewOrderNotification', () {
    testWidgets('hides when there are no pending vendor orders', (
      tester,
    ) async {
      final orderService = OrderService();
      addTearDown(orderService.dispose);
      for (final order in orderService.orders) {
        orderService.updateOrderStatus(order.id, OrderStatus.completed);
      }

      await tester.pumpWidget(buildWidget(orderService));

      expect(find.textContaining('New Order'), findsNothing);
    });

    testWidgets('shows count for pending vendor orders', (tester) async {
      final orderService = OrderService()
        ..placeOrders(isPickup: false, items: [cartItem(), cartItem()]);
      addTearDown(orderService.dispose);

      await tester.pumpWidget(buildWidget(orderService));

      expect(find.text('1 New Order!'), findsOneWidget);
      expect(find.text('Tap to review and accept'), findsOneWidget);
    });

    testWidgets('calls callback when tapped', (tester) async {
      var tapped = false;
      final orderService = OrderService()
        ..placeOrders(isPickup: false, items: [cartItem()]);
      addTearDown(orderService.dispose);

      await tester.pumpWidget(
        buildWidget(
          orderService,
          onViewOrders: () {
            tapped = true;
          },
        ),
      );
      await tester.tap(find.text('1 New Order!'));

      expect(tapped, isTrue);
    });
  });
}
