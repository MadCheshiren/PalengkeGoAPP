import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/market/data/market_repository.dart';
import 'package:palengkego/features/market/data/mock_market_repository.dart';
import 'package:palengkego/features/market/domain/market_product.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MockMarketRepository();
});

final discountedProductsProvider = Provider<List<MarketProduct>>((ref) {
  final repository = ref.watch(marketRepositoryProvider);
  return repository.getDiscountedProducts();
});
