import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/presentation/widgets/floating_order_progress.dart';

void main() {
  CartItem cartItem() {
    return const CartItem(
      vendorName: 'Aling Nena',
      productName: 'Carrots',
      price: 120,
      weight: '1kg',
      pricePerKg: 'PHP 120/kg',
      image: 'carrots.png',
    );
  }

  Widget buildWidget(OrderService orderService) {
    return ProviderScope(
      overrides: [orderServiceProvider.overrideWithValue(orderService)],
      child: const MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: Scaffold(body: Stack(children: [FloatingOrderProgress()])),
      ),
    );
  }

  group('FloatingOrderProgress', () {
    testWidgets('hides when there are no active orders', (tester) async {
      final orderService = OrderService();
      addTearDown(orderService.dispose);
      for (final order in orderService.orders) {
        orderService.updateOrderStatus(order.id, OrderStatus.completed);
      }

      await tester.pumpWidget(buildWidget(orderService));

      expect(find.textContaining('Order #'), findsNothing);
    });

    testWidgets('shows the first active order status', (tester) async {
      final orderService = OrderService()
        ..placeOrders(isPickup: false, items: [cartItem()]);
      addTearDown(orderService.dispose);

      await tester.pumpWidget(buildWidget(orderService));

      expect(find.textContaining('Order #'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('hides immediately when active order is cancelled', (
      tester,
    ) async {
      final orderService = OrderService()
        ..placeOrders(isPickup: false, items: [cartItem()]);
      addTearDown(orderService.dispose);
      final order = orderService.orders.firstWhere(
        (order) => order.status == OrderStatus.pending,
      );

      await tester.pumpWidget(buildWidget(orderService));
      expect(find.textContaining('Order #'), findsOneWidget);

      orderService.cancelOrder(
        order.id,
        now: order.placedAt.add(const Duration(minutes: 1)),
      );
      await tester.pump();

      expect(find.textContaining('Order #'), findsNothing);
    });
  });
}
