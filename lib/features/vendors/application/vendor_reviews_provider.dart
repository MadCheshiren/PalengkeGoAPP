import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/mock/mock_data.dart';
import 'package:palengkego/features/vendors/domain/vendor_review.dart';
import 'package:palengkego/features/vendors/application/vendor_stall_provider.dart';

/// Reads the vendor's stall ID from [vendorStallProvider] and returns
/// all typed [VendorReview] objects from the unified mock repository.
/// Pure derived data — no async, no context, no side effects.
final vendorReviewsProvider = Provider<List<VendorReview>>((ref) {
  // The stall provider resolves to the logged-in vendor's stall.
  // For the current mock data, the vendor stall maps to 'v1'.
  // When a real backend is added, swap MockDataService for an API call here.
  final stall = ref.watch(vendorStallProvider);
  final vendorId = _stallNameToId(stall.name);
  return MockDataService.getReviewsAsObjects(vendorId);
});

/// Reads and returns all typed [VendorReview] objects for a given vendor stall ID.
final vendorReviewsFamilyProvider = Provider.family<List<VendorReview>, String>((ref, vendorId) {
  return MockDataService.getReviewsAsObjects(vendorId);
});

/// Temporary name-to-id resolver until the vendor stall exposes its own ID field.
String _stallNameToId(String stallName) {
  const nameToId = {
    'Diosa Fruit Stand': 'v1',
    "William Del Rosario Meat Shop": 'v2',
    "Paul's Meat Shop": 'v3',
    'Merly Diego Dried Fish Store': 'v4',
    'Aling Nena Vegetables': 'v5',
    'Mang Pedro Seafood': 'v6',
  };
  return nameToId[stallName] ?? 'v1';
}
