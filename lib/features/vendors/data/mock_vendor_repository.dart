import 'package:palengkego/core/mock/mock_data.dart';
import 'package:palengkego/features/vendors/data/vendor_repository.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/features/vendors/domain/vendor_profile.dart';

class MockVendorRepository implements VendorRepository {
  @override
  Future<VendorProfile> getVendorProfile(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Find the vendor in MockDataService.featuredVendors
    final vendorMap = MockDataService.featuredVendors.firstWhere(
      (v) => v['id'] == id,
      orElse: () => MockDataService.featuredVendors.first,
    );

    return VendorProfile(
      id: vendorMap['id'] as String? ?? '',
      name: vendorMap['name'] as String? ?? 'Vendor',
      category: vendorMap['category'] as String? ?? 'General',
      rating: (vendorMap['rating'] as num?)?.toDouble() ?? 4.0,
      reviewCount: id == 'v3' ? 84 : 112,
      isOpen: id != 'v3',
      stallLocation: vendorMap['stallNumber'] as String? ?? 'Market Stall',
      imageUrl: vendorMap['imageUrl'] as String? ?? '',
      avatarUrl: id == 'v2'
          ? 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200&h=200&fit=crop&crop=face'
          : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&crop=face',
    );
  }

  @override
  Future<List<VendorProduct>> getVendorProducts(String vendorId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final rawProducts = MockDataService.getProductsForVendor(vendorId);

    return rawProducts.asMap().entries.map((entry) {
      final p = entry.value;

      // Use the stored stockQuantity directly; fall back to 15 for legacy
      // mock rows that have no stockQuantity field yet.
      // NOTE: never derive stock from list index — that causes the wrong
      // product to appear out-of-stock when another product is deleted.
      final stock = (p['stockQuantity'] as num?)?.toInt() ?? 15;

      // Respect the explicitly-saved isActive flag; if stock hits 0 the
      // product is also treated as inactive regardless of the flag.
      final explicitlyActive = p['isActive'] as bool? ?? true;
      final active = explicitlyActive && stock > 0;

      return VendorProduct(
        id: p['id'] as String? ?? '',
        vendorId: p['vendorId'] as String? ?? '',
        name: p['name'] as String? ?? '',
        category: p['category'] as String? ?? '',
        price: (p['price'] as num?)?.toDouble() ?? 0.0,
        description: p['description'] as String? ?? '',
        weight: p['weight'] as String? ?? '',
        pricePerKg: p['pricePerKg'] as String? ?? '',
        imageUrl: p['imageUrl'] as String? ?? '',
        isActive: active,
        stockQuantity: stock,
        discountPercentage: (p['discountPercentage'] as num?)?.toDouble(),
      );
    }).toList();
  }

  @override
  Future<VendorProduct> addVendorProduct(VendorProduct product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    MockDataService.addProduct(product.toMap());
    return product;
  }

  @override
  Future<VendorProduct> updateVendorProduct(VendorProduct product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    MockDataService.updateProduct(product.toMap());
    return product;
  }

  @override
  Future<void> deleteVendorProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    MockDataService.deleteProduct(productId);
  }
}
