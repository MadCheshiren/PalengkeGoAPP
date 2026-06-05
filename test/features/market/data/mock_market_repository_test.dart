import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/features/market/data/mock_market_repository.dart';

void main() {
  group('MockMarketRepository', () {
    test('returns featured vendors as typed market vendors', () {
      final repository = MockMarketRepository();

      final vendors = repository.getFeaturedVendors();

      expect(vendors, isNotEmpty);
      expect(vendors.first.id, 'v1');
      expect(vendors.first.name, 'Diosa Fruit Stand');
      expect(vendors.first.category, 'Fruits');
      expect(vendors.first.rating, 4.8);
    });

    test('filters vendors by category', () {
      final repository = MockMarketRepository();

      final vendors = repository.getVendorsByCategory('Fish');

      expect(vendors, isNotEmpty);
      expect(vendors.every((vendor) => vendor.category == 'Fish'), isTrue);
    });

    test('all category returns every featured vendor', () {
      final repository = MockMarketRepository();

      final allVendors = repository.getVendorsByCategory('All');
      final featuredVendors = repository.getFeaturedVendors();

      expect(allVendors.length, featuredVendors.length);
    });

    test('returns products for a vendor', () {
      final repository = MockMarketRepository();

      final products = repository.getProductsForVendor('v1');

      expect(products, isNotEmpty);
      expect(products.every((product) => product.vendorId == 'v1'), isTrue);
      expect(products.first.name, 'Sweet Mangoes');
    });
  });
}
