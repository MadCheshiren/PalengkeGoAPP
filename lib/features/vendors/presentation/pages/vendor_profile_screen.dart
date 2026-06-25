import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/services/app_services.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/profile/application/favorites_provider.dart';
import 'package:palengkego/features/profile/application/blocked_vendors_provider.dart';

import 'package:palengkego/core/widgets/app_bottom_nav_bar.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';
import 'package:palengkego/features/vendors/application/vendor_provider.dart';
import 'package:palengkego/features/vendors/presentation/widgets/vendor_profile_components.dart';
import 'package:palengkego/features/vendors/presentation/widgets/block_vendor_dialog.dart';
import 'package:palengkego/features/vendors/presentation/widgets/flag_vendor_bottom_sheet.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_reviews_screen.dart';
class VendorProfileScreen extends ConsumerStatefulWidget {
  final String vendorId;
  final String? filterCategory;

  const VendorProfileScreen({
    super.key, 
    required this.vendorId,
    this.filterCategory,
  });

  @override
  ConsumerState<VendorProfileScreen> createState() =>
      _VendorProfileScreenState();
}

class _VendorProfileScreenState extends ConsumerState<VendorProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(vendorProfileProvider(widget.vendorId));
    final productsAsync = ref.watch(vendorProductsProvider(widget.vendorId));
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(widget.vendorId)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF0B372B)),
          ),
          error: (error, stack) =>
              Center(child: Text('Error loading vendor: $error')),
          data: (profile) {
            return Column(
              children: [
                // Top bar with back + title + favorite heart
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: SizedBox(
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF6F8F7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Color(0xFF0B372B),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'Vendor Profile',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B372B),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ❤️ Favorite button
                              GestureDetector(
                                onTap: () {
                                  if (!context.mounted) return;
                                  ref
                                      .read(favoritesProvider.notifier)
                                      .toggle(widget.vendorId);
                                  final msg = isFavorite
                                      ? 'Removed from favorites'
                                      : '${profile.name} added to favorites';
                                  AppServices.showSnackBar(msg);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isFavorite
                                        ? const Color(0xFFFEE2E2)
                                        : const Color(0xFFF6F8F7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_outline_rounded,
                                    size: 16,
                                    color: isFavorite
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF0B372B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // ⋮ More menu
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.white,
                                onSelected: (value) {
                                  // Defer to next frame so the popup menu route
                                  // fully dismisses before we push a new route.
                                  // This prevents "deactivated ancestor" errors
                                  // from the PopupMenu's own route cleanup code.
                                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                                    if (!context.mounted) return;
                                    if (value == 'flag') {
                                      FlagVendorBottomSheet.show(context, vendorName: profile.name);
                                    } else if (value == 'block') {
                                      // Await dialog — it ONLY returns true/false, never pops
                                      // this screen or touches any provider.
                                      final confirmed = await BlockVendorDialog.show(
                                        context,
                                        vendorName: profile.name,
                                      );
                                      // Guard: VendorProfileScreen must still be mounted.
                                      // All operations below happen on a live widget —
                                      // no deactivated-context errors possible.
                                      if (confirmed && context.mounted) {
                                        ref
                                            .read(blockedVendorsProvider.notifier)
                                            .block(profile.id);
                                        AppServices.showSnackBar(
                                          '${profile.name} has been blocked.',
                                        );
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  });
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    value: 'flag',
                                    child: Row(
                                      children: [
                                        Icon(Icons.flag_outlined,
                                            color: Colors.redAccent, size: 20),
                                        SizedBox(width: 8),
                                        Text('Flag Vendor'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'block',
                                    child: Row(
                                      children: [
                                        Icon(Icons.block,
                                            color: Colors.black54, size: 20),
                                        SizedBox(width: 8),
                                        Text('Block Vendor'),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF6F8F7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.more_vert_rounded,
                                      size: 16, color: Color(0xFF0B372B)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VendorProfileHeroSection(profile: profile),
                        VendorProfileDetailsSection(profile: profile),
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: Text(
                            'Fresh Catch Today',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B372B),
                              height: 1.2,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          child: productsAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF0B372B),
                              ),
                            ),
                            error: (error, stack) =>
                                Text('Error loading products: $error'),
                            data: (products) {
                              final displayedProducts = widget.filterCategory == null || widget.filterCategory == 'All'
                                  ? products
                                  : products.where((p) => 
                                      p.category.toLowerCase().contains(widget.filterCategory!.toLowerCase())
                                    ).toList();

                              if (displayedProducts.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('No products found for this category.'),
                                  ),
                                );
                              }
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: displayedProducts.length,
                                itemBuilder: (context, index) {
                                  return VendorProfileProductCard(
                                    product: displayedProducts[index],
                                    vendorName: profile.name,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: Text(
                            'Customer Reviews',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B372B),
                              height: 1.2,
                            ),
                          ),
                        ),
                        VendorReviewsSection(vendorId: widget.vendorId),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 1, // Market tab
        onTap: (index) {
          if (!context.mounted) return;
          navigateToMainTab(context, index);
        },
        cartBadgeCount: ref.watch(cartCountProvider) > 0
            ? ref.watch(cartCountProvider)
            : null,
        isCartAction: true,
      ),
    );
  }
}
