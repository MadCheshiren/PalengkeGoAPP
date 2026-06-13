import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/market/application/market_provider.dart';
import 'package:palengkego/features/market/domain/market_vendor.dart';

/// Holds the current search query string typed in the search bar.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Filtered vendor list based on the current search query + selected category.
/// When query is empty, returns the full category-filtered list.
final filteredVendorsProvider =
    Provider.family<List<MarketVendor>, String>((ref, category) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final repo = ref.watch(marketRepositoryProvider);
  final vendors = repo.getVendorsByCategory(category);

  if (query.isEmpty) return vendors;

  return vendors.where((v) {
    return v.name.toLowerCase().contains(query) ||
        v.category.toLowerCase().contains(query);
  }).toList();
});
