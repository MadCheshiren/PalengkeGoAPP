import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/market/domain/market_vendor.dart';
import 'package:palengkego/features/market/application/market_provider.dart';

/// Holds the set of favorite vendor IDs for the current customer session.
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  /// Toggle a vendor as favorite/unfavorite.
  void toggle(String vendorId) {
    if (state.contains(vendorId)) {
      state = {...state}..remove(vendorId);
    } else {
      state = {...state, vendorId};
    }
  }

  bool isFavorite(String vendorId) => state.contains(vendorId);
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// Derives the list of favorited [MarketVendor] objects from the market repo.
final favoriteVendorsProvider = Provider<List<MarketVendor>>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  final repo = ref.watch(marketRepositoryProvider);
  final allVendors = repo.getVendorsByCategory('All');
  return allVendors.where((v) => favoriteIds.contains(v.id)).toList();
});
