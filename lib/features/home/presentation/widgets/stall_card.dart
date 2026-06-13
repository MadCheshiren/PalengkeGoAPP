import 'package:flutter/material.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/features/market/domain/market_vendor.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_profile_screen.dart';

class StallCard extends StatelessWidget {
  final MarketVendor vendor;
  final String? selectedCategory;

  const StallCard({super.key, required this.vendor, this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    final rating = vendor.rating.toStringAsFixed(1);
    final category = vendor.category;
    final stallLocation = _stallLabelFor(vendor.id);
    final status = _statusFor(vendor.id);
    final isOpen = status == 'OPEN';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageTransitions.slideFromRight(
            VendorProfileScreen(vendorId: vendor.id, filterCategory: selectedCategory),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              flex: 163,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox.expand(
                      child: Image.network(
                        vendor.imageUrl,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFFE2E8F0),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0B372B),
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) {
                          return Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Center(
                              child: Icon(
                                Icons.image_rounded,
                                color: Color(0xFF94A3B8),
                                size: 30,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B372B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      height: 23,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF94A3B8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        status,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 92,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6D9773),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          vendor.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0B372B),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stallLocation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(11, 55, 43, 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Color(0xFF0B372B),
                          ),
                        ),
                      ],
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

  String _stallLabelFor(String? vendorId) {
    switch (vendorId) {
      case 'v1':
        return 'Stall 4';
      case 'v2':
        return 'Block 15 | Stall 2';
      case 'v3':
        return 'Stall #33';
      case 'v4':
        return 'Block 3 | Stall 4';
      case 'v5':
        return 'Block 7 | Stall 2';
      case 'v6':
        return 'Block 7 | Stall 1';
      default:
        return 'Market Stall';
    }
  }

  String _statusFor(String? vendorId) {
    switch (vendorId) {
      case 'v3':
        return 'CLOSED';
      default:
        return 'OPEN';
    }
  }
}
