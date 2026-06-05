import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/vendors/data/mock_vendor_repository.dart';
import 'package:palengkego/features/vendors/data/vendor_repository.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/features/vendors/domain/vendor_profile.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return MockVendorRepository();
});

final vendorProfileProvider = FutureProvider.family<VendorProfile, String>((ref, vendorId) async {
  final repository = ref.read(vendorRepositoryProvider);
  return repository.getVendorProfile(vendorId);
});

final vendorProductsProvider = FutureProvider.family<List<VendorProduct>, String>((ref, vendorId) async {
  final repository = ref.read(vendorRepositoryProvider);
  return repository.getVendorProducts(vendorId);
});
