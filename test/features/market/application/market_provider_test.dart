import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/features/market/application/market_provider.dart';

void main() {
  group('product search providers', () {
    test('allProductsProvider returns products across vendors', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final products = container.read(allProductsProvider);

      expect(products, isNotEmpty);
      expect(
        products.map((product) => product.vendorId).toSet().length,
        greaterThan(1),
      );
    });

    test('searchProductsProvider returns no results for an empty query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchProductsProvider('')), isEmpty);
      expect(container.read(searchProductsProvider('   ')), isEmpty);
    });

    test('searchProductsProvider filters products by name and category', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mangoResults = container.read(searchProductsProvider('mango'));
      final fruitResults = container.read(searchProductsProvider('fruit'));

      expect(mangoResults, isNotEmpty);
      expect(
        mangoResults.every(
          (product) => product.name.toLowerCase().contains('mango'),
        ),
        isTrue,
      );
      expect(fruitResults, isNotEmpty);
      expect(
        fruitResults.every(
          (product) => product.category.toLowerCase().contains('fruit'),
        ),
        isTrue,
      );
    });

    test('searchProductsProvider caps results for the dropdown', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final results = container.read(searchProductsProvider('a'));

      expect(results.length, lessThanOrEqualTo(8));
    });
  });
}
