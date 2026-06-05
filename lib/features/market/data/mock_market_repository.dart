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

    return vendors
        .where((vendor) => vendor.category == category)
        .toList(growable: false);
  }

  @override
  List<MarketProduct> getProductsForVendor(String vendorId) {
    return MockDataService.getProductsForVendor(vendorId)
        .map(MarketProduct.fromMap)
        .toList(growable: false);
  }
}
