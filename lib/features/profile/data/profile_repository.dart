import 'package:palengkego/features/profile/domain/customer_profile.dart';

abstract class ProfileRepository {
  Future<CustomerProfile> getProfile(String uid);
  Future<void> updateProfile(CustomerProfile profile);
}
