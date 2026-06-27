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

final allProductsProvider = Provider<List<MarketProduct>>((ref) {
  return ref.watch(marketRepositoryProvider).getAllProducts();
});

/// Filters all products by the given query string (case-insensitive).
/// Matches on product name, category, and pricePerKg.
final searchProductsProvider =
    Provider.family<List<MarketProduct>, String>((ref, query) {
  if (query.trim().isEmpty) return [];
  final q = query.trim().toLowerCase();
  return ref
      .watch(allProductsProvider)
      .where(
        (p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q),
      )
      .take(8) // cap at 8 results to keep the dropdown concise
      .toList();
});
