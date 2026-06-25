import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';
import 'package:palengkego/features/auth/presentation/pages/login_screen.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/cart/presentation/pages/shopping_cart_screen.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  CartService cartWithSelectedItem() {
    return CartService()..addToCart(
      vendorName: 'Diosa Fruit Stand',
      productName: 'Sweet Mangoes',
      price: 150,
      weight: '1kg',
      pricePerKg: 'PHP 150/kg',
      image: 'https://example.com/mango.jpg',
    );
  }

  Widget buildCartApp({required CartService cart, required AppUser? user}) {
    return ProviderScope(
      overrides: [
        cartServiceProvider.overrideWithValue(cart),
        authProvider.overrideWith(() => _TestAuthNotifier(user)),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const ShoppingCartScreen(),
      ),
    );
  }

  group('ShoppingCartScreen auth checkout flow', () {
    testWidgets('guest can view cart items before logging in', (tester) async {
      usePhoneViewport(tester);
      final cart = cartWithSelectedItem();
      addTearDown(cart.dispose);

      await tester.pumpWidget(buildCartApp(cart: cart, user: null));
      await tester.pumpAndSettle();

      expect(find.text('Shopping Cart'), findsOneWidget);
      expect(find.text('Sweet Mangoes'), findsOneWidget);
      expect(find.text('Login Required'), findsNothing);
      expect(cart.items, hasLength(1));
    });

    testWidgets('guest checkout prompts login and keeps cart contents', (
      tester,
    ) async {
      usePhoneViewport(tester);
      final cart = cartWithSelectedItem();
      addTearDown(cart.dispose);

      await tester.pumpWidget(buildCartApp(cart: cart, user: null));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      expect(find.text('Proceed to Checkout'), findsOneWidget);

      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();

      expect(find.text('Login Required'), findsOneWidget);
      expect(
        find.text('You must be logged in to checkout your items.'),
        findsOneWidget,
      );
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(cart.items, hasLength(1));
      expect(cart.items.single.productName, 'Sweet Mangoes');
    });

    testWidgets('guest can back out of login without losing cart contents', (
      tester,
    ) async {
      usePhoneViewport(tester);
      final cart = cartWithSelectedItem();
      addTearDown(cart.dispose);

      await tester.pumpWidget(buildCartApp(cart: cart, user: null));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);

      Navigator.of(tester.element(find.byType(LoginScreen))).pop();
      await tester.pumpAndSettle();

      expect(find.text('Shopping Cart'), findsOneWidget);
      expect(find.text('Sweet Mangoes'), findsOneWidget);
      expect(find.text('Login Required'), findsNothing);
      expect(cart.items, hasLength(1));
      expect(cart.items.single.productName, 'Sweet Mangoes');
    });

    testWidgets('authenticated checkout skips login prompt', (tester) async {
      usePhoneViewport(tester);
      final cart = cartWithSelectedItem();
      addTearDown(cart.dispose);

      await tester.pumpWidget(
        buildCartApp(cart: cart, user: MockUsers.customer),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      expect(find.text('Proceed to Checkout'), findsOneWidget);

      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();

      expect(find.text('Login Required'), findsNothing);
      expect(find.text('Checkout'), findsWidgets);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this.initialUser);

  final AppUser? initialUser;

  @override
  AppUser? build() => initialUser;
}
