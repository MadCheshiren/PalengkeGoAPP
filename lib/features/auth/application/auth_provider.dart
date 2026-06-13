import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/auth/data/auth_repository.dart';
import 'package:palengkego/features/auth/data/mock_auth_repository.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

/// Notifier that holds the current user session.
/// In debug mode, starts pre-authenticated as a customer (no password needed).
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    // Seed from the repository's initial state (MockAuthRepository auto-sets
    // a customer user in debug mode inside its constructor).
    final repo = ref.read(authRepositoryProvider);
    AppUser? initial;
    repo.authStateChanges().first.then((user) {
      if (state == null && user != null) state = user;
    });
    return initial;
  }

  Future<void> loginAs(UserRole role) async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.login('', '', role: role);
    state = user;
  }

  Future<void> login(String email, String password, {UserRole role = UserRole.customer}) async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.login(email, password, role: role);
    state = user;
  }

  Future<void> register(String email, String password, String name) async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.register(email, password, name);
    state = user;
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(
  AuthNotifier.new,
);

/// Convenience: stream-based provider kept for backward compatibility.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Map the current user's UID to vendor ID (maps 'vendor-001' to 'v1' for mock data).
final currentVendorIdProvider = Provider<String>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return 'v1';
  if (user.uid == 'vendor-001') return 'v1';
  return user.uid;
});
