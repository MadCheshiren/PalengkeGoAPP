import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/features/vendors/domain/vendor_profile.dart';

abstract class VendorRepository {
  Future<VendorProfile> getVendorProfile(String id);
  Future<List<VendorProduct>> getVendorProducts(String vendorId);
}
