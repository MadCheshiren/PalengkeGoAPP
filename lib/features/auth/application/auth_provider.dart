import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/infrastructure/firebase_service.dart';
import 'package:palengkego/features/auth/data/auth_repository.dart';
import 'package:palengkego/features/auth/data/firebase_auth_repository.dart';
import 'package:palengkego/features/auth/data/mock_auth_repository.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';
import 'package:palengkego/features/auth/application/has_vendor_stall_provider.dart';

/// Provides the correct [AuthRepository] implementation based on the
/// `FIREBASE_ENABLED` dart-define compile-time flag.
///
/// - **Mock mode (default):** `flutter run`
///   Uses [MockAuthRepository] — no Firebase needed, works offline.
///
/// - **Firebase mode:** `flutter run --dart-define=FIREBASE_ENABLED=true`
///   Uses [FirebaseAuthRepository] — connects to real Firebase Auth
///   and reads user roles from Firestore `users/{uid}`.
///
/// Your friend only needs to run `flutterfire configure` and push
/// `firebase_options.dart`. Everything else is already wired up here.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseEnabled = ref.watch(firebaseEnabledProvider);

  if (firebaseEnabled) {
    return FirebaseAuthRepository(
      auth: ref.watch(firebaseAuthProvider),
      firestore: ref.watch(firestoreProvider),
    );
  }

  return MockAuthRepository();
});

/// Notifier that holds the current user session.
/// In mock mode (debug), starts pre-authenticated as a customer.
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    // Seed from the repository's initial state.
    // MockAuthRepository auto-sets a customer user in debug mode.
    // FirebaseAuthRepository returns null until the user logs in.
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

  Future<void> login(
    String email,
    String password, {
    UserRole role = UserRole.customer,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.login(email, password, role: role);
    state = user;
  }

  Future<void> register(String email, String password, String name) async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.register(email, password, name);
    state = user;
  }

  Future<AppUser> signInWithGoogle() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.signInWithGoogle();
    state = user;
    return user;
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    await ref.read(hasVendorStallProvider.notifier).clear();
    state = null;
  }

  /// Enters vendor mode for demo/dev role-switch taps. In production the
  /// authenticated role is authoritative; returns whether the caller may
  /// proceed into vendor UI.
  Future<bool> enterVendorMode() async {
    if (kDebugMode) {
      await loginAs(UserRole.vendor);
      return true;
    }
    return state?.isVendor == true;
  }

  /// Returns to the customer-facing area. In production the market screens
  /// are open to all authenticated users, so no role switch is performed.
  Future<bool> enterCustomerMode() async {
    if (kDebugMode) {
      await loginAs(UserRole.customer);
    }
    return true;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

/// Convenience: stream-based provider kept for backward compatibility.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Maps the current user's UID to vendor ID.
/// Returns null when the user is not signed in or is not a vendor — never a
/// fabricated vendor identity. In mock mode the vendor uid 'stall holder-001'
/// maps to 'v1'; in Firebase mode the UID is used directly.
final currentVendorIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return null;
  if (user.role != UserRole.vendor) return null;
  if (user.uid == 'stall holder-001') return 'v1'; // mock compatibility
  return user.uid;
});
