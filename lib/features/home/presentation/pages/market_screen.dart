import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/widgets/animated_entrance.dart';
import 'package:palengkego/features/home/application/search_provider.dart';
import 'package:palengkego/features/home/presentation/widgets/home_header.dart';
import 'package:palengkego/features/home/presentation/widgets/stall_card.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  static const _categories = <String>[
    'All',
    'Fish',
    'Meat',
    'Fruits',
    'Vegetables',
    'Maritatas',
    'Sari-Sari',
  ];

  String _selectedCategory = 'All';
  late final TextEditingController _searchController;
  late final SearchQueryNotifier _searchQueryNotifier;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchQueryNotifier = ref.read(searchQueryProvider.notifier);
    _searchController.addListener(() {
      _searchQueryNotifier.update(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Clear search when leaving the screen using the cached notifier.
    // Defer the modification to a microtask to avoid updating provider state
    // while the widget tree is unmounting/finalizing.
    Future.microtask(() => _searchQueryNotifier.clear());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVendors =
        ref.watch(filteredVendorsProvider(_selectedCategory));
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
              child: Column(
                children: [
                  // Wired search field
                  Container(
                    height: 43,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8F7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search_rounded,
                            size: 18, color: Color(0xFF6D9773)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search stalls, products...',
                              hintStyle: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                          ),
                        ),
                        if (query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              ref
                                  .read(searchQueryProvider.notifier)
                                  .clear();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.close_rounded,
                                  size: 18, color: Color(0xFF94A3B8)),
                            ),
                          )
                        else
                          const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Category chips
                  SizedBox(
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
                          onTap: () => setState(() {
                            _selectedCategory = category;
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            Expanded(
              child: filteredVendors.isEmpty
                  ? _EmptySearchState(query: query)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                query.isEmpty ? 'Stalls' : 'Results',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0B372B),
                                ),
                              ),
                              if (query.isNotEmpty)
                                Text(
                                  '${filteredVendors.length} found',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                            ],
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
                                child: StallCard(vendor: vendor, selectedCategory: _selectedCategory),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty search state
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
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
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
            'No results for "$query"',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B372B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different stall name or category.',
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
// Category chip (unchanged visual)
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
          color:
              isSelected ? const Color(0xFF0B372B) : const Color(0xFFF6F8F7),
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
