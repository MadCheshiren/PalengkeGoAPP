import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:palengkego/core/mock/mock_data.dart';
import 'package:palengkego/core/services/app_services.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/features/vendors/domain/vendor_profile.dart';
import 'package:palengkego/features/vendors/domain/vendor_review.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_reviews_screen.dart';
import 'package:palengkego/core/utils/unit_helper.dart';
import 'package:palengkego/features/vendors/presentation/widgets/add_to_cart_bottom_sheet.dart';


class VendorProfileTopBar extends StatelessWidget {
  const VendorProfileTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _circleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
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
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                onSelected: (value) {
                  // Defer to next frame so the popup menu route fully dismisses
                  // before we call ScaffoldMessenger — prevents deactivated-
                  // ancestor errors from the popup menu's own cleanup code.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    if (value == 'flag') {
                      AppServices.showSnackBar('Vendor flagged successfully');
                    } else if (value == 'block') {
                      AppServices.showSnackBar('Vendor blocked successfully');
                    }
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'flag',
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text('Flag Vendor'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.black54, size: 20),
                        SizedBox(width: 8),
                        Text('Block Vendor'),
                      ],
                    ),
                  ),
                ],
                child: _circleButton(icon: Icons.more_vert_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFFF6F8F7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF0B372B)),
      ),
    );
  }
}

class VendorProfileHeroSection extends StatelessWidget {
  final VendorProfile profile;

  const VendorProfileHeroSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 208,
      child: Stack(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black12),
                bottom: BorderSide(color: Colors.black12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Image.network(
              profile.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(color: const Color(0xFFE5E7EB));
              },
            ),
          ),
          Positioned(
            left: 16,
            top: 104,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -1,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  profile.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Container(
                      color: const Color(0xFFF6F8F7),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 40,
                        color: Color(0xFF64748B),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 12,
            child: Container(
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: profile.isOpen
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: profile.isOpen
                      ? const Color.fromRGBO(22, 163, 74, 0.2)
                      : const Color.fromRGBO(100, 116, 139, 0.2),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                profile.isOpen ? 'Open Now' : 'Closed',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: profile.isOpen
                      ? const Color(0xFF166534)
                      : const Color(0xFF64748B),
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VendorProfileDetailsSection extends StatelessWidget {
  final VendorProfile profile;

  const VendorProfileDetailsSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    // Fetch mock reviews for this vendor
    final reviews = MockDataService.getReviewsAsObjects(profile.id);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B372B),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _inlineMeta(
                    icon: Icons.storefront_outlined,
                    text: profile.stallLocation,
                  ),
                  const SizedBox(width: 16),
                  _inlineMeta(
                    icon: Icons.photo_library_outlined,
                    text: '${profile.category} Section',
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorReviewsScreen(vendorId: profile.id),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: Color(0xFFFACC15),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${profile.rating}',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${profile.reviewCount})',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0B372B),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (reviews.isNotEmpty) ...[
              const SizedBox(height: 16),
              // We need to wrap it in a slightly transformed padding so it bleeds out if we want,
              // but since we are already inside a Padding(horizontal: 16), we should offset it
              Transform.translate(
                offset: const Offset(-16, 0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: VendorReviewsCarousel(reviews: reviews),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    context,
                    icon: Icons.call_outlined,
                    label: 'Call',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _actionButton(
                    context,
                    icon: Icons.message_outlined,
                    label: 'Message',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _inlineMeta({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF4B5563)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        if (!context.mounted) return;
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text('$label vendor coming soon!')));
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(11, 55, 43, 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF0B372B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B372B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorProfileProductCard extends StatelessWidget {
  final VendorProduct product;
  final String vendorName;

  const VendorProfileProductCard({
    super.key,
    required this.product,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    final price = product.price.toInt();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: UnitHelper.isPieceUnit(product.name, product.description)
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFF0FDF4),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: product.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (product.imageUrl.isEmpty)
                    const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discountPercentage!.toInt()}%',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    if (product.stockQuantity == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Out of stock',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      )
                    else if (product.stockQuantity <= 5)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Only ${product.stockQuantity} left',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'PHP ${product.discountedPrice.toInt()}',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B372B),
                              ),
                            ),
                            if (product.hasDiscount)
                              TextSpan(
                                text: ' PHP $price',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF94A3B8),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            TextSpan(
                              text:
                                  '/${UnitHelper.getUnitString(UnitHelper.isPieceUnit(product.name, product.description))}',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: product.stockQuantity > 0 ? () {
                        AddToCartBottomSheet.show(
                          context,
                          vendorName: vendorName,
                          product: product,
                        );
                      } : null,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: product.stockQuantity > 0 ? const Color(0xFF0B372B) : const Color(0xFFD1D5DB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class VendorReviewsCarousel extends StatefulWidget {
  final List<VendorReview> reviews;

  const VendorReviewsCarousel({super.key, required this.reviews});

  @override
  State<VendorReviewsCarousel> createState() => _VendorReviewsCarouselState();
}

class _VendorReviewsCarouselState extends State<VendorReviewsCarousel> {
  late ScrollController _scrollController;
  Timer? _tickerTimer;
  Timer? _resumeTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.reviews.isNotEmpty) {
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isUserInteracting || !_scrollController.hasClients) return;

      final position = _scrollController.position;
      final maxScroll = position.maxScrollExtent;
      final current = position.pixels;

      if (maxScroll <= 0) return;

      if (current >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(current + 0.4);
      }
    });
  }

  void _pauseAutoScroll() {
    _resumeTimer?.cancel();
    _isUserInteracting = true;
  }

  void _scheduleResume() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviews.isEmpty) return const SizedBox.shrink();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          if (notification.dragDetails != null) {
            _pauseAutoScroll();
          }
        } else if (notification is ScrollEndNotification) {
          _scheduleResume();
        }
        return false;
      },
      child: Listener(
        onPointerDown: (_) {
          _pauseAutoScroll();
        },
        onPointerUp: (_) {
          _scheduleResume();
        },
        onPointerCancel: (_) {
          _scheduleResume();
        },
        child: SizedBox(
          height: 88,
          child: ScrollConfiguration(
            behavior: MouseDragScrollBehavior(),
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.reviews.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final review = widget.reviews[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorReviewsScreen(vendorId: review.vendorId),
                      ),
                    );
                  },
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.customerName,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFACC15)),
                            const SizedBox(width: 2),
                            Text(
                              '${review.rating}',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"${review.comment}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
