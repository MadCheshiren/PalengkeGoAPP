import 'package:palengkego/features/profile/data/profile_repository.dart';
import 'package:palengkego/features/profile/domain/customer_profile.dart';

class MockProfileRepository implements ProfileRepository {
  CustomerProfile _currentProfile = const CustomerProfile(
    uid: 'user-123',
    displayName: 'Juan Dela Cruz',
    email: 'juan@example.com',
    phoneNumber: '+63 912 345 6789',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
    addresses: [
      '123 Magsaysay Ave, Naga City, Camarines Sur',
      '456 Panganiban Drive, Naga City, Camarines Sur',
    ],
  );

  @override
  Future<CustomerProfile> getProfile(String uid) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return _currentProfile;
  }

  @override
  Future<void> updateProfile(CustomerProfile profile) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    _currentProfile = profile;
  }
}
