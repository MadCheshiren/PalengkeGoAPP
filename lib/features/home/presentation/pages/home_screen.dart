import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/widgets/animated_entrance.dart';
import 'package:palengkego/features/market/application/market_provider.dart';
import 'package:palengkego/features/profile/application/blocked_vendors_provider.dart';
import 'package:palengkego/features/home/presentation/widgets/home_header.dart';
import 'package:palengkego/features/home/presentation/widgets/search_field.dart';
import 'package:palengkego/features/home/presentation/widgets/stall_card.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_profile_screen.dart';
import 'package:palengkego/features/home/presentation/widgets/discounted_item_card.dart';
import 'package:palengkego/core/mock/mock_promos.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onMarketSelected;
  const HomeScreen({super.key, required this.onMarketSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allVendors = ref
        .watch(marketRepositoryProvider)
        .getVendorsByCategory('All');
    final blockedIds = ref.watch(blockedVendorsProvider);
    final vendors = allVendors.where((v) => !blockedIds.contains(v.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HomeHeader(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: SearchField(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promo Cards Carousel
                    AnimatedEntrance(
                      index: 0,
                      child: Consumer(
                        builder: (context, ref, _) {
                          final promos = ref.watch(promosProvider);
                          return SizedBox(
                            height: 180,
                            child: PageView.builder(
                              controller: PageController(viewportFraction: 0.9),
                              itemCount: promos.length,
                              itemBuilder: (context, index) {
                                final promo = promos[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0B372B),
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=600',
                                        ),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black38,
                                          BlendMode.darken,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            promo.title,
                                            style: const TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Get up to ${promo.discountPercentage.toInt()}% off today!',
                                            style: TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white.withValues(alpha: 0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // Flash Deals Section
                    Consumer(
                      builder: (context, ref, _) {
                        final discountedProducts = ref.watch(discountedProductsProvider);
                        if (discountedProducts.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Flash Deals',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0B372B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 240,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: discountedProducts.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final product = discountedProducts[index];
                                  return AnimatedEntrance(
                                    index: index + 1,
                                    child: DiscountedItemCard(
                                      product: product,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VendorProfileScreen(vendorId: product.vendorId),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // Popular Stalls Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular Stalls',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B372B),
                            ),
                          ),
                          TextButton(
                            onPressed: onMarketSelected,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'View All',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6D9773),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Popular Stalls Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.55,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: vendors.take(4).length,
                        itemBuilder: (context, index) {
                          final vendor = vendors[index];
                          return AnimatedEntrance(
                            index: index + 1,
                            child: StallCard(vendor: vendor),
                          );
                        },
                      ),
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
