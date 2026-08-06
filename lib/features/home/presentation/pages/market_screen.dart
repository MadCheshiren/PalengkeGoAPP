import 'package:palengkego/core/config/categories.dart';
import 'package:palengkego/core/presentation/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/widgets/animated_entrance.dart';
import 'package:palengkego/features/home/application/search_provider.dart';
import 'package:palengkego/features/home/presentation/widgets/home_header.dart';
import 'package:palengkego/features/home/presentation/widgets/stall_card.dart';
import 'package:palengkego/features/home/presentation/widgets/search_field.dart';
import 'package:palengkego/features/market/domain/market_product.dart';
import 'package:palengkego/features/market/domain/market_vendor.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/core/navigation/app_router.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HomeHeader(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: const SearchField(isInline: true),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            Expanded(
              child: query.trim().isEmpty
                  ? const _StallBrowser()
                  : _CombinedSearchResults(query: query),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stall browser (no active query) — category chips + stall grid
// ---------------------------------------------------------------------------
class _StallBrowser extends ConsumerStatefulWidget {
  const _StallBrowser();

  @override
  ConsumerState<_StallBrowser> createState() => _StallBrowserState();
}

class _StallBrowserState extends ConsumerState<_StallBrowser> {
  static final _categories = <String>['All', ...AppCategories.all];

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredVendorsAsync = ref.watch(
      filteredVendorsProvider(_selectedCategory),
    );

    return Column(
      children: [
        // Category chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return _CategoryChip(
                  label: category,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    ref
                        .read(selectedSubcategoryProvider.notifier)
                        .setSubcategory('All');
                  },
                );
              },
            ),
          ),
        ),
        // Subcategory chips (Animated drop-down)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
          child: _selectedCategory == 'Meat'
              ? Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final subcats = ['All', 'Beef', 'Pork'];
                        final subcat = subcats[index];
                        final selectedSub = ref.watch(
                          selectedSubcategoryProvider,
                        );
                        return _SubcategoryChip(
                          label: subcat,
                          isSelected: selectedSub == subcat,
                          onTap: () => ref
                              .read(selectedSubcategoryProvider.notifier)
                              .setSubcategory(subcat),
                        );
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        Expanded(
          child: filteredVendorsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (filteredVendors) {
              if (filteredVendors.isEmpty) {
                return const _EmptySearchState(query: '');
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stalls',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredVendors.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 18,
                            childAspectRatio: 0.55,
                          ),
                      itemBuilder: (context, index) {
                        final vendor = filteredVendors[index];
                        return AnimatedEntrance(
                          index: index,
                          child: StallCard(
                            vendor: vendor,
                            selectedCategory: _selectedCategory,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Combined search results (products + stalls) — shown when query is active
// ---------------------------------------------------------------------------
class _CombinedSearchResults extends ConsumerWidget {
  final String query;
  const _CombinedSearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(appSearchProvider(query));

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (results) {
        if (results.isEmpty) return _EmptySearchState(query: query);

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Results',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                    Text(
                      '${results.length} found',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.separated(
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 0,
                  color: Color(0xFFF1F5F9),
                ),
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final result = results[i];
                  return result.isProduct
                      ? _ProductTile(product: result.product!)
                      : _VendorTile(vendor: result.vendor!);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  final MarketProduct product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.vendorProfile,
        arguments: VendorProfileRouteArgs(vendorId: product.vendorId),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AdaptiveImage(
                product.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: Container(
                  width: 48,
                  height: 48,
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(
                    Icons.image_rounded,
                    size: 20,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₱${product.discountedPrice.toStringAsFixed(0)}/${product.unit}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B372B),
                  ),
                ),
                // Product badge
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Product',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorTile extends StatelessWidget {
  final MarketVendor vendor;
  const _VendorTile({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.vendorProfile,
        arguments: VendorProfileRouteArgs(vendorId: vendor.id),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AdaptiveImage(
                vendor.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: Container(
                  width: 48,
                  height: 48,
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 20,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vendor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Stall Holder',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vendor.category,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Stall',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF6D9773),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'No stalls available' : 'No results for "$query"',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B372B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different stall name, product, or category.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category chip
// ---------------------------------------------------------------------------
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B372B) : const Color(0xFFF6F8F7),
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6D9773),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subcategory chip
// ---------------------------------------------------------------------------
class _SubcategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubcategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6D9773) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF0B372B),
          ),
        ),
      ),
    );
  }
}
