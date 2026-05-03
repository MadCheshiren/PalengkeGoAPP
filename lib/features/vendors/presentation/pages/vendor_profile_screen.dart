import 'package:flutter/material.dart';
import 'package:palengkego/core/mock/mock_data.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/core/widgets/app_bottom_nav_bar.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';
import 'package:palengkego/features/vendors/presentation/widgets/add_to_cart_bottom_sheet.dart';

class VendorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> vendor;

  const VendorProfileScreen({super.key, required this.vendor});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  late final List<Map<String, dynamic>> _products;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _products = _productsForVendor();
    globalCart.addListener(_onCartChanged);
    _cartItemCount = globalCart.itemCount;
  }

  @override
  void dispose() {
    globalCart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {
      _cartItemCount = globalCart.itemCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final heroImage = _heroImageForVendor();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroSection(heroImage),
                    _detailsSection(),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Text(
                        'Fresh Catch Today',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0B372B),
                          height: 1.2,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.79,
                            ),
                        itemBuilder: (context, index) {
                          return _ProductCard(
                            product: _products[index],
                            vendorName:
                                widget.vendor['name'] as String? ?? 'Vendor',
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
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0, // Market tab
        onTap: (index) => navigateToMainTab(context, index),
        cartBadgeCount: _cartItemCount > 0 ? _cartItemCount : null,
        isCartAction: true,
      ),
    );
  }

  Widget _topBar() {
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
            Text(
              'Vendor Profile',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B372B),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _circleButton(icon: Icons.more_vert_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroSection(String heroImage) {
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
              heroImage,
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
                  _avatarImageForVendor(),
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
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color.fromRGBO(22, 163, 74, 0.2),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Open Now',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF166534),
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsSection() {
    return SizedBox(
      height: 169,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.vendor['name'] as String? ?? 'Vendor',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B372B),
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
                    text: _stallLabelFor(widget.vendor['id'] as String?),
                  ),
                  const SizedBox(width: 16),
                  _inlineMeta(
                    icon: Icons.photo_library_outlined,
                    text: '${widget.vendor['category'] ?? 'Fish'} Section',
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: Color(0xFFFACC15),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.vendor['rating'] ?? '4.5'}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '(112)',
                    style: TextStyle(
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
                    icon: Icons.call_outlined,
                    label: 'Call',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _actionButton(
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

  Widget _actionButton({required IconData icon, required String label}) {
    return Container(
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
    );
  }

  List<Map<String, dynamic>> _productsForVendor() {
    final vendorName = (widget.vendor['name'] as String? ?? '').toLowerCase();
    final products = MockDataService.getProductsForVendor(widget.vendor['id']);

    if (products.isNotEmpty) {
      return products;
    }

    if (vendorName.contains('aicel')) {
      return [
        {
          'name': 'Tilapia',
          'price': 120.0,
          'description': 'Locally sourced',
          'weight': '1kg',
          'pricePerKg': 'PHP 120/kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?w=400&h=300&fit=crop',
        },
        {
          'name': 'Bangus (Milkfish)',
          'price': 180.0,
          'description': 'Boneless available',
          'weight': '1kg',
          'pricePerKg': 'PHP 180/kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400&h=300&fit=crop',
        },
        {
          'name': 'Tiger Prawns',
          'price': 350.0,
          'description': 'Medium size',
          'weight': '1kg',
          'pricePerKg': 'PHP 350/kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400&h=300&fit=crop',
        },
        {
          'name': 'Squid',
          'price': 280.0,
          'description': 'Ideal for adobo',
          'weight': '1kg',
          'pricePerKg': 'PHP 280/kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=400&h=300&fit=crop',
        },
        {
          'name': 'Maya-Maya',
          'price': 420.0,
          'description': 'Whole fish',
          'weight': '1kg',
          'pricePerKg': 'PHP 420/kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1574781330855-d0db8cc6a79c?w=400&h=300&fit=crop',
        },
        {
          'name': 'Tahong (Mussels)',
          'price': 80.0,
          'description': 'Fresh harvest',
          'weight': '1kg',
          'pricePerKg': 'PHP 80/kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1625943555419-56a2cb596640?w=400&h=300&fit=crop',
        },
      ];
    }

    return products;
  }

  String _heroImageForVendor() {
    final vendorName = (widget.vendor['name'] as String? ?? '').toLowerCase();

    if (vendorName.contains('aicel')) {
      return 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=900&h=400&fit=crop';
    }

    if (_products.isNotEmpty) {
      return _products.first['imageUrl'] as String? ??
          'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=900&h=400&fit=crop';
    }

    return widget.vendor['imageUrl'] as String? ??
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=900&h=400&fit=crop';
  }

  String _avatarImageForVendor() {
    return 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&crop=face';
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
        return 'Block 14 | Stall 2';
    }
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String vendorName;

  const _ProductCard({required this.product, required this.vendorName});

  @override
  Widget build(BuildContext context) {
    final price = (product['price'] as num?)?.toInt() ?? 0;

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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 126.75,
              width: double.infinity,
              child: Image.network(
                product['imageUrl'] as String? ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(
                      Icons.image_rounded,
                      color: Color(0xFF9CA3AF),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String? ?? 'Product',
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
                    product['description'] as String? ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      RichText(
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
                            const TextSpan(
                              text: '/kg',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
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
          ),
        ],
      ),
    );
  }
}
