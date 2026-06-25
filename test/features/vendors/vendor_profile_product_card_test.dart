import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/features/vendors/presentation/widgets/add_to_cart_bottom_sheet.dart';
import 'package:palengkego/features/vendors/presentation/widgets/vendor_profile_components.dart';

void main() {
  Widget buildCard({
    required VendorProduct product,
    required CartService cart,
  }) {
    return ProviderScope(
      overrides: [cartServiceProvider.overrideWithValue(cart)],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 260,
            child: VendorProfileProductCard(
              product: product,
              vendorName: 'Diosa Fruit Stand',
            ),
          ),
        ),
      ),
    );
  }

  VendorProduct product({required int stockQuantity}) {
    return VendorProduct(
      id: 'p1',
      vendorId: 'v1',
      name: 'Sweet Mangoes',
      description: 'Fresh mangoes',
      category: 'Fruits',
      price: 150,
      pricePerKg: 'PHP 150/kg',
      weight: '1kg',
      imageUrl: '',
      stockQuantity: stockQuantity,
    );
  }

  group('VendorProfileProductCard stock state', () {
    testWidgets(
      'out-of-stock product shows disabled state and does not open cart sheet',
      (tester) async {
        final cart = CartService();
        addTearDown(cart.dispose);

        await tester.pumpWidget(
          buildCard(product: product(stockQuantity: 0), cart: cart),
        );

        expect(find.text('Out of stock'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(AddToCartBottomSheet), findsNothing);
        expect(cart.items, isEmpty);
      },
    );

    testWidgets(
      'low-stock product shows remaining stock and opens add-to-cart sheet',
      (tester) async {
        final cart = CartService();
        addTearDown(cart.dispose);

        await tester.pumpWidget(
          buildCard(product: product(stockQuantity: 3), cart: cart),
        );

        expect(find.text('Only 3 left'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(AddToCartBottomSheet), findsOneWidget);
      },
    );
  });
}
