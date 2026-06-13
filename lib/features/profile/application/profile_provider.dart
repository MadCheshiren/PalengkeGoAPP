import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/profile/data/mock_profile_repository.dart';
import 'package:palengkego/features/profile/data/profile_repository.dart';
import 'package:palengkego/features/profile/domain/customer_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

final currentProfileProvider = FutureProvider<CustomerProfile?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);

  final authState = await ref.watch(authStateProvider.future);
  if (authState == null) {
    return null; // Not logged in
  }

  return repository.getProfile(authState.uid);
});
