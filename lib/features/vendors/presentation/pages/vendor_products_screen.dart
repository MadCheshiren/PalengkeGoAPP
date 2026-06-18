import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/vendors/application/vendor_provider.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:intl/intl.dart';
import 'package:palengkego/core/utils/unit_helper.dart';
import '../widgets/vendor_screen_header.dart';
import 'vendor_add_product_screen.dart';

/// Vendor Products Screen
/// Shows all vendor products with stock toggle.
class VendorProductsScreen extends ConsumerStatefulWidget {
  const VendorProductsScreen({super.key});

  @override
  ConsumerState<VendorProductsScreen> createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends ConsumerState<VendorProductsScreen> {
  String _selectedFilter = 'All Products';
  String _searchQuery = '';
  late String _vendorId;

  @override
  Widget build(BuildContext context) {
    _vendorId = ref.watch(currentVendorIdProvider);
    final productsAsync = ref.watch(vendorProductsProvider(_vendorId));

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
                  productsAsync.when(
                    data: (products) {
                      final filteredProducts = products.where((product) {
                        final matchesFilter = switch (_selectedFilter) {
                          'Out of Stock' => !product.isActive,
                          _ => true,
                        };
                        final matchesSearch = product.name.toLowerCase().contains(
                          _searchQuery.trim().toLowerCase(),
                        );
                        return matchesFilter && matchesSearch;
                      }).toList();

                      if (filteredProducts.isEmpty) {
                        return const Center(
                          child: Text(
                            'No products match this filter yet.',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductGridCard(product);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0B372B)),
                    ),
                    error: (error, _) => Center(
                      child: Text('Error: $error'),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VendorAddProductScreen(),
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
              color: isSelected ? const Color(0xFF0B372B) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected) Container(width: 40, height: 2, color: const Color(0xFF0B372B)),
        ],
      ),
    );
  }

  Widget _buildProductGridCard(VendorProduct product) {
    final formatCurrency = NumberFormat.currency(symbol: 'PHP ', decimalDigits: 0);
    final isFruit = UnitHelper.isPieceUnit(product.name, product.description);
    final imageColor = isFruit ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4);
    final unitLabel = UnitHelper.getUnitString(isFruit);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VendorAddProductScreen(existingProduct: product),
          ),
        );
      },
      child: Container(
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
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: imageColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
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
                  // Edit badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.08),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatCurrency.format(product.price)}/$unitLabel',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.stockQuantity > 0
                              ? 'Stock: ${product.stockQuantity} $unitLabel'
                              : (product.isActive ? 'In Stock' : 'Out of Stock'),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            color: product.isActive
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.75,
                        alignment: Alignment.centerRight,
                        child: Switch(
                          value: product.isActive,
                          onChanged: (value) async {
                            final messenger = ScaffoldMessenger.of(context);
                            final updated = product.copyWith(isActive: value);
                            await ref
                                .read(vendorProductsManagerProvider(_vendorId))
                                .updateProduct(updated);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.name} is now ${value ? 'in stock' : 'out of stock'}.'
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          activeThumbColor: const Color(0xFF0B372B),
                          activeTrackColor:
                              const Color(0xFF0B372B).withValues(alpha: 0.25),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
