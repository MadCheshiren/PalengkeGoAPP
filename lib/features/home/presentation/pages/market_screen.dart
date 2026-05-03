import 'package:flutter/material.dart';
import 'package:palengkego/core/mock/mock_data.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/core/widgets/animated_entrance.dart';
import 'package:palengkego/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:palengkego/features/profile/presentation/pages/profile_screen.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_profile_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  static const _categories = <String>[
    'All',
    'Fish',
    'Meat',
    'Fruits',
    'Vegetables',
  ];

  String _selectedCategory = 'All';

  List<Map<String, dynamic>> get _filteredVendors {
    if (_selectedCategory == 'All') {
      return MockDataService.featuredVendors;
    }

    return MockDataService.featuredVendors.where((vendor) {
      return vendor['category'] == _selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _MarketHeader(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Column(
                children: [
                  const _SearchField(),
                  const SizedBox(height: 14),
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
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stalls',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B372B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredVendors.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 18,
                            childAspectRatio: 0.685,
                          ),
                      itemBuilder: (context, index) {
                        final vendor = _filteredVendors[index];
                        return AnimatedEntrance(
                          index: index,
                          child: _StallCard(vendor: vendor),
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

class _MarketHeader extends StatelessWidget {
  const _MarketHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NAGA CITY MARKET',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6D9773),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PalengkeGo',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B372B),
                    letterSpacing: -0.6,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 84,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransitions.slideFromRight(
                        const NotificationsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 36,
                    alignment: Alignment.center,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 24,
                          color: Color(0xFF0B372B),
                        ),
                        Positioned(
                          top: 1,
                          right: 1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageTransitions.slideFromRight(
                        const ProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8F7),
                      shape: BoxShape.circle,
                      // No border - using background tone shift per design system
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&h=120&fit=crop&crop=face',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF6D9773)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
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
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

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
          // No border - using background tone shift per design system
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

class _StallCard extends StatelessWidget {
  final Map<String, dynamic> vendor;

  const _StallCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final rating = (vendor['rating'] as num?)?.toStringAsFixed(1) ?? '4.5';
    final category = vendor['category'] as String? ?? 'General';
    final stallLocation = _stallLabelFor(vendor['id'] as String?);
    final status = _statusFor(vendor['id'] as String?);
    final isOpen = status == 'OPEN';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageTransitions.slideFromRight(
            VendorProfileScreen(
              vendor: {
                'id': vendor['id'],
                'name': vendor['name'],
                'category': category,
                'rating': rating,
                'isVerified': vendor['isVerified'] ?? false,
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // No border - shadow provides elevation per design system
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
                        vendor['imageUrl'] as String? ?? '',
                        fit: BoxFit.cover,
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
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                    Text(
                      vendor['name'] as String? ?? 'Vendor',
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
                    const Spacer(),
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
