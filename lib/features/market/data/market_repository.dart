import 'package:palengkego/features/market/domain/market_product.dart';
import 'package:palengkego/features/market/domain/market_vendor.dart';

abstract class MarketRepository {
  List<MarketVendor> getFeaturedVendors();

  List<MarketVendor> getVendorsByCategory(String category);

  List<MarketProduct> getProductsForVendor(String vendorId);
}
