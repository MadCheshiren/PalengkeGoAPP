import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';
import 'package:palengkego/features/orders/domain/fulfillment_method.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_line_item.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/domain/payment_status.dart';
import 'package:palengkego/features/orders/presentation/pages/order_details_screen.dart';

void main() {
  Widget buildRoutedApp(String routeName, {Object? arguments}) {
    return ProviderScope(
      overrides: [authProvider.overrideWith(() => _TestAuthNotifier())],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: routeName,
        routes: {routeName: (_) => const SizedBox.shrink()},
        onGenerateInitialRoutes: (initialRoute) {
          return [
            AppRouter.onGenerateRoute(
              RouteSettings(name: initialRoute, arguments: arguments),
            ),
          ];
        },
      ),
    );
  }

  group('AppRouter invalid route arguments', () {
    testWidgets('shows error route for order confirmation without typed args', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildRoutedApp(AppRoutes.orderConfirmation, arguments: 'bad-args'),
      );

      expect(find.text('Route not found'), findsOneWidget);
    });

    testWidgets('shows error route for track order without typed args', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildRoutedApp(AppRoutes.trackOrder, arguments: {'order': 'bad'}),
      );

      expect(find.text('Route not found'), findsOneWidget);
    });

    testWidgets('shows error route for order details without typed args', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildRoutedApp(AppRoutes.orderDetails, arguments: 123),
      );

      expect(find.text('Route not found'), findsOneWidget);
    });

    testWidgets('shows error route for unknown route name', (tester) async {
      await tester.pumpWidget(buildRoutedApp('/missing-route'));

      expect(find.text('Route not found'), findsOneWidget);
    });
  });

  group('AppRouter order tracking', () {
    testWidgets('track order route opens the canonical order details screen', (
      tester,
    ) async {
      final order = MarketOrder(
        id: '#test',
        vendorName: 'Diosa Fruit Stand',
        vendorImage: '',
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        fulfillmentMethod: FulfillmentMethod.delivery,
        placedAt: DateTime.now(),
        deliveryFee: 49,
        serviceFee: 15,
        items: const [
          OrderLineItem(
            productName: 'Mango',
            quantity: 1,
            unitPrice: 100,
            weight: '1kg',
            pricePerKg: 'PHP 100/kg',
            image: '',
          ),
        ],
      );

      await tester.pumpWidget(
        buildRoutedApp(
          AppRoutes.trackOrder,
          arguments: TrackOrderRouteArgs(order: order, isPickup: false),
        ),
      );

      expect(find.byType(OrderDetailsScreen), findsOneWidget);
      expect(find.text('Current Status'), findsOneWidget);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  @override
  AppUser? build() {
    return MockUsers.customer;
  }
}
