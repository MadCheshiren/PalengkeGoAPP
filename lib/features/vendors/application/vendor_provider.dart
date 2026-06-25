import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/vendors/data/mock_vendor_repository.dart';
import 'package:palengkego/features/vendors/data/vendor_repository.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/features/vendors/domain/vendor_profile.dart';
import 'package:palengkego/features/market/application/market_provider.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return MockVendorRepository();
});

final vendorProfileProvider = FutureProvider.family<VendorProfile, String>((
  ref,
  vendorId,
) async {
  final repository = ref.read(vendorRepositoryProvider);
  return repository.getVendorProfile(vendorId);
});

final vendorProductsProvider =
    FutureProvider.family<List<VendorProduct>, String>((ref, vendorId) async {
      final repository = ref.read(vendorRepositoryProvider);
      return repository.getVendorProducts(vendorId);
    });

class VendorProductsManager {
  final Ref ref;
  final String vendorId;

  VendorProductsManager(this.ref, this.vendorId);

  Future<void> addProduct(VendorProduct product) async {
    final repository = ref.read(vendorRepositoryProvider);
    await repository.addVendorProduct(product);
    ref.invalidate(vendorProductsProvider(vendorId));
    ref.invalidate(discountedProductsProvider);
  }

  Future<void> updateProduct(VendorProduct product) async {
    final repository = ref.read(vendorRepositoryProvider);
    await repository.updateVendorProduct(product);
    ref.invalidate(vendorProductsProvider(vendorId));
    ref.invalidate(discountedProductsProvider);
  }

  Future<void> deleteProduct(String productId) async {
    final repository = ref.read(vendorRepositoryProvider);
    await repository.deleteVendorProduct(productId);
    ref.invalidate(vendorProductsProvider(vendorId));
    ref.invalidate(discountedProductsProvider);
  }
}

final vendorProductsManagerProvider = Provider.family<VendorProductsManager, String>((ref, vendorId) {
  return VendorProductsManager(ref, vendorId);
});
