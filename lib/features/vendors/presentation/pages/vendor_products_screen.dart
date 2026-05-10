import 'package:flutter/material.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import '../widgets/vendor_screen_header.dart';
import 'vendor_add_product_screen.dart';

/// Vendor Products Screen
/// Shows all vendor products with stock toggle.
class VendorProductsScreen extends StatefulWidget {
  const VendorProductsScreen({super.key});

  @override
  State<VendorProductsScreen> createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends State<VendorProductsScreen> {
  String _selectedFilter = 'All Products';
  String _searchQuery = '';

  final List<_VendorProduct> _products = [
    _VendorProduct(
      name: 'Fresh Bangus',
      price: 'PHP 180/kg',
      imageColor: const Color(0xFFD5E7DE),
      isActive: true,
    ),
    _VendorProduct(
      name: 'Whole Chicken',
      price: 'PHP 210/kg',
      imageColor: const Color(0xFFFFF7ED),
      isActive: true,
    ),
    _VendorProduct(
      name: 'Carrots',
      price: 'PHP 60/kg',
      imageColor: const Color(0xFFF0FDF4),
      isActive: true,
    ),
    _VendorProduct(
      name: 'Potatoes',
      price: 'PHP 90/kg',
      imageColor: const Color(0xFFF8FAFC),
      isActive: false,
    ),
    _VendorProduct(
      name: 'Red Onion',
      price: 'PHP 120/kg',
      imageColor: const Color(0xFFFFF7ED),
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      final matchesFilter = switch (_selectedFilter) {
        'Out of Stock' => !product.isActive,
        _ => true,
      };
      final matchesSearch = product.name.toLowerCase().contains(
        _searchQuery.trim().toLowerCase(),
      );
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const VendorScreenHeader(title: 'My Products'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF6F8F7),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF0B372B),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildFilterTab(
                    'All Products',
                    _selectedFilter == 'All Products',
                  ),
                  const SizedBox(width: 24),
                  _buildFilterTab(
                    'Out of Stock',
                    _selectedFilter == 'Out of Stock',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            'No products match this filter yet.',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return _buildProductGridCard(product);
                          },
                        ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransitions.slideFromRight(
                            const VendorAddProductScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0B372B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF0B372B)
                  : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(width: 40, height: 2, color: const Color(0xFF0B372B)),
        ],
      ),
    );
  }

  Widget _buildProductGridCard(_VendorProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 24, 40, 0.04),
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
                color: product.imageColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
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
                          color: Color(0xFF0B372B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.price,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.isActive ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: product.isActive
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: product.isActive,
                  onChanged: (value) {
                    setState(() {
                      product.isActive = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product.name} is now ${value ? 'in stock' : 'out of stock'}.',
                        ),
                      ),
                    );
                  },
                  activeThumbColor: const Color(0xFF0B372B),
                  activeTrackColor: const Color(0xFF0B372B).withValues(alpha: 0.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorProduct {
  _VendorProduct({
    required this.name,
    required this.price,
    required this.imageColor,
    required this.isActive,
  });

  final String name;
  final String price;
  final Color imageColor;
  bool isActive;
}
