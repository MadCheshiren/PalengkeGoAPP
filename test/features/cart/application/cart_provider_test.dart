import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';

void main() {
  test('cartServiceProvider exposes a cart service', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final cart = container.read(cartServiceProvider);

    expect(cart, isA<CartService>());
  });

  test('cartServiceProvider can update the shared cart state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(cartServiceProvider)
        .addToCart(
          vendorName: 'Aling Nena',
          productName: 'Carrots',
          price: 120,
          weight: '500g',
          pricePerKg: 'PHP 120/500g',
          image: 'carrots.png',
        );

    expect(container.read(cartServiceProvider).itemCount, 1);
  });

  test(
    'cartItemsProvider keeps existing items after cart provider rebuilds',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cart = container.read(cartServiceProvider);
      cart.addToCart(
        vendorName: 'Aling Nena',
        productName: 'Carrots',
        price: 120,
        weight: '500g',
        pricePerKg: 'PHP 120/500g',
        image: 'carrots.png',
      );

      expect(container.read(cartItemsProvider), hasLength(1));

      container.invalidate(cartItemsProvider);

      expect(container.read(cartItemsProvider), hasLength(1));
      expect(container.read(cartItemsProvider).single.productName, 'Carrots');
    },
  );

  test(
    'cartItemsProvider keeps existing items when a different item is added',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cart = container.read(cartServiceProvider);
      cart
        ..addToCart(
          vendorName: 'Aling Nena',
          productName: 'Carrots',
          price: 120,
          weight: '500g',
          pricePerKg: 'PHP 120/500g',
          image: 'carrots.png',
        )
        ..addToCart(
          vendorName: 'Mang Juan',
          productName: 'Bangus',
          price: 90,
          weight: '1pc',
          pricePerKg: 'PHP 90/pc',
          image: 'bangus.png',
        );

      final itemNames = container
          .read(cartItemsProvider)
          .map((item) => item.productName)
          .toList();

      expect(itemNames, ['Carrots', 'Bangus']);
      expect(container.read(cartCountProvider), 2);
    },
  );

  test('cart state survives login and logout auth state changes', () {
    final container = ProviderContainer(
      overrides: [authProvider.overrideWith(_MutableAuthNotifier.new)],
    );
    addTearDown(container.dispose);

    final cart = container.read(cartServiceProvider);
    cart
      ..addToCart(
        vendorName: 'Diosa Fruit Stand',
        productName: 'Sweet Mangoes',
        price: 150,
        weight: '1kg',
        pricePerKg: 'PHP 150/kg',
        image: 'mango.png',
        quantity: 2,
      )
      ..addToCart(
        vendorName: 'Mang Juan',
        productName: 'Bangus',
        price: 90,
        weight: '1pc',
        pricePerKg: 'PHP 90/pc',
        image: 'bangus.png',
      )
      ..toggleSelect(1);

    expect(container.read(cartItemsProvider), hasLength(2));
    expect(container.read(cartCountProvider), 2);
    expect(cart.subtotal, 300);

    (container.read(authProvider.notifier) as _MutableAuthNotifier)
        .loginAsCustomer();

    expect(container.read(authProvider), MockUsers.customer);
    expect(container.read(cartItemsProvider), hasLength(2));
    expect(container.read(cartCountProvider), 2);
    expect(cart.subtotal, 300);

    (container.read(authProvider.notifier) as _MutableAuthNotifier)
        .logoutForTest();

    expect(container.read(authProvider), isNull);
    expect(container.read(cartItemsProvider), hasLength(2));
    expect(container.read(cartCountProvider), 2);
    expect(cart.items.map((item) => item.productName), [
      'Sweet Mangoes',
      'Bangus',
    ]);
  });
}

class _MutableAuthNotifier extends AuthNotifier {
  @override
  AppUser? build() => null;

  void loginAsCustomer() {
    state = MockUsers.customer;
  }

  void logoutForTest() {
    state = null;
  }
}
