import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/features/vendors/presentation/widgets/add_to_cart_bottom_sheet.dart';

void main() {
  group('AddToCartBottomSheet', () {
    testWidgets('adds a typed vendor product to the shared cart', (
      tester,
    ) async {
      final cart = CartService();
      addTearDown(cart.dispose);

      const product = VendorProduct(
        id: 'p1',
        vendorId: 'v1',
        name: 'Bangus',
        description: 'Fresh milkfish',
        category: 'Seafood',
        price: 80,
        pricePerKg: 'PHP 80/kg',
        weight: '1kg',
        imageUrl: '',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [cartServiceProvider.overrideWithValue(cart)],
          child: const MaterialApp(
            home: Scaffold(
              body: AddToCartBottomSheet(
                vendorName: 'Aling Nena',
                product: product,
              ),
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Add to cart'));
      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();

      expect(cart.items, hasLength(1));
      expect(cart.items.single.vendorName, 'Aling Nena');
      expect(cart.items.single.productName, 'Bangus');
      expect(cart.items.single.price, 80);
      expect(cart.items.single.weight, '1kg');
      expect(cart.items.single.pricePerKg, 'PHP 80/kg');
    });

    testWidgets('uses piece pricing when product category is piece-based', (
      tester,
    ) async {
      final cart = CartService();
      addTearDown(cart.dispose);

      const product = VendorProduct(
        id: 'p2',
        vendorId: 'v1',
        name: 'Egg',
        description: 'Fresh eggs',
        category: 'Eggs',
        price: 10,
        pricePerKg: 'PHP 10/pc',
        weight: '1 pc',
        imageUrl: '',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [cartServiceProvider.overrideWithValue(cart)],
          child: const MaterialApp(
            home: Scaffold(
              body: AddToCartBottomSheet(
                vendorName: 'Aling Nena',
                product: product,
              ),
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('3 pcs'));
      await tester.tap(find.text('3 pcs'));
      await tester.pump();
      await tester.ensureVisible(find.text('Add to cart'));
      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();

      expect(cart.items, hasLength(1));
      expect(cart.items.single.productName, 'Egg');
      expect(cart.items.single.price, 30);
      expect(cart.items.single.weight, '3 pcs');
      expect(cart.items.single.pricePerKg, 'PHP 10/pc');
    });
  });
}
