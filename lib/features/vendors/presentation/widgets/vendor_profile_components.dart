import 'package:flutter/material.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/features/vendors/domain/vendor_profile.dart';
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
                  if (value == 'flag') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vendor flagged successfully'),
                      ),
                    );
                  } else if (value == 'block') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vendor blocked successfully'),
                      ),
                    );
                  }
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
    return SizedBox(
      height: 169,
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
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$label vendor coming soon!')));
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
              child: product.imageUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Color(0xFF94A3B8),
                      ),
                    )
                  : null,
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
                Text(
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
                              text: 'PHP $price',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B372B),
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
                      onTap: () {
                        AddToCartBottomSheet.show(
                          context,
                          vendorName: vendorName,
                          product: product,
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0B372B),
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
