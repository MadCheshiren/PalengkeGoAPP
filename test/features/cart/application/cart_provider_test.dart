import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/cart_service.dart';
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
}
