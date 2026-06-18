import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/presentation/pages/order_details_screen.dart';

void main() {
  CartItem cartItem() {
    return const CartItem(
      vendorName: 'Aling Nena',
      productName: 'Carrots',
      price: 120,
      weight: '500g',
      pricePerKg: 'PHP 120/500g',
      image: '',
    );
  }

  testWidgets('cancel confirmation updates the order status to cancelled', (
    tester,
  ) async {
    final orderService = OrderService();
    addTearDown(orderService.dispose);
    final order = orderService
        .placeOrders(items: [cartItem()], isPickup: false)
        .single;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [orderServiceProvider.overrideWithValue(orderService)],
        child: MaterialApp(home: OrderDetailsScreen(order: order)),
      ),
    );

    await tester.scrollUntilVisible(
      find.textContaining('Cancel Order'),
      500,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.textContaining('Cancel Order'));
    await tester.pump();
    await tester.tap(find.text('Yes, Cancel'));
    await tester.pump();

    expect(
      orderService.orders.firstWhere((item) => item.id == order.id).status,
      OrderStatus.cancelled,
    );
    expect(find.text('Order cancelled successfully.'), findsOneWidget);
    expect(find.textContaining('Cancel Order'), findsNothing);
  });

  testWidgets('status timeline follows live vendor status updates', (
    tester,
  ) async {
    final orderService = OrderService();
    addTearDown(orderService.dispose);
    final order = orderService
        .placeOrders(items: [cartItem()], isPickup: false)
        .single;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [orderServiceProvider.overrideWithValue(orderService)],
        child: MaterialApp(home: OrderDetailsScreen(order: order)),
      ),
    );

    expect(find.text('Vendor Confirmation'), findsOneWidget);
    expect(find.text('Preparing'), findsOneWidget);
    expect(find.text('Waiting for vendor confirmation'), findsWidgets);

    orderService.updateOrderStatus(order.id, OrderStatus.preparing);
    await tester.pump();

    expect(find.text('Preparing'), findsOneWidget);
    expect(find.text('Vendor is preparing your items'), findsWidgets);
  });
}
