import 'package:palengkego/core/mock/mock_data.dart';
import 'package:palengkego/features/market/data/market_repository.dart';
import 'package:palengkego/features/market/domain/market_product.dart';
import 'package:palengkego/features/market/domain/market_vendor.dart';

class MockMarketRepository implements MarketRepository {
  @override
  List<MarketVendor> getFeaturedVendors() {
    return MockDataService.featuredVendors
        .map(MarketVendor.fromMap)
        .toList(growable: false);
  }

  @override
  List<MarketVendor> getVendorsByCategory(String category) {
    final vendors = getFeaturedVendors();

    if (category == 'All') {
      return vendors;
    }

    return vendors.where((vendor) {
      if (vendor.category == category) return true;
      final products = getProductsForVendor(vendor.id);
      return products.any((p) => 
        p.category.toLowerCase().contains(category.toLowerCase())
      );
    }).toList(growable: false);
  }

  @override
  List<MarketProduct> getProductsForVendor(String vendorId) {
    return MockDataService.getProductsForVendor(
      vendorId,
    ).map(MarketProduct.fromMap).toList(growable: false);
  }

  @override
  List<MarketProduct> getDiscountedProducts() {
    return MockDataService.getDiscountedProducts()
        .map(MarketProduct.fromMap)
        .toList(growable: false);
  }
}
