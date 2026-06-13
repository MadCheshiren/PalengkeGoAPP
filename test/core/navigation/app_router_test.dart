import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/core/navigation/app_routes.dart';

void main() {
  Widget buildRoutedApp(String routeName, {Object? arguments}) {
    return MaterialApp(
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
}
