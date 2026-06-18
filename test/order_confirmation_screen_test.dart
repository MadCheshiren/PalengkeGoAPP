import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/checkout/presentation/pages/checkout_screen.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';

void main() {
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 20,
    Duration step = const Duration(milliseconds: 100),
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
  }

  testWidgets(
    'Full Checkout to OrderConfirmationScreen flow with multiple vendors and hover',
    (WidgetTester tester) async {
      final cart = CartService();
      final orders = OrderService();

      cart.clearCart();

      // Add items from two different vendors to global cart
      cart.addToCart(
        vendorName: 'Diosa Fruit Stand',
        productName: 'Sweet Mangoes',
        price: 150.0,
        weight: '1kg',
        pricePerKg: 'PHP 150/kg',
        image: 'https://example.com/mango.jpg',
      );

      cart.addToCart(
        vendorName: 'William Del Rosario Meat Shop',
        productName: 'Pork Belly',
        price: 280.0,
        weight: '1kg',
        pricePerKg: 'PHP 280/kg',
        image: 'https://example.com/pork.jpg',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartServiceProvider.overrideWithValue(cart),
            orderServiceProvider.overrideWithValue(orders),
          ],
          child: MaterialApp(
            initialRoute: AppRoutes.checkout,
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.splash) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Splash Mock')),
                );
              }
              return AppRouter.onGenerateRoute(settings);
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Verify we are on checkout screen and it has items
      expect(find.byType(CheckoutScreen), findsOneWidget);

      // Switch to Pick-Up method
      final pickupTab = find.text('Pick-Up');
      expect(pickupTab, findsOneWidget);
      await tester.tap(pickupTab);
      await tester.pump();

      // Tap on Place Order button
      final placeOrderButton = find.text('Place Order');
      expect(placeOrderButton, findsOneWidget);
      await tester.tap(placeOrderButton);

      // Wait for route transition animations to complete
      await pumpUntilFound(tester, find.text('Orders Placed\nSuccessfully!'));

      // Now we should be on OrderConfirmationScreen
      expect(find.text('Orders Placed\nSuccessfully!'), findsOneWidget);
      expect(find.text('Diosa Fruit Stand'), findsOneWidget);
      expect(find.text('William Del Rosario Meat Shop'), findsOneWidget);

      // Simulate mouse hover / movement to trigger mouse tracker hit tests
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(const Offset(100, 100));
      await tester.pump();

      await gesture.moveTo(const Offset(200, 200));
      await tester.pump();

      await gesture.moveTo(const Offset(300, 300));
      await tester.pump();
    },
  );
}
