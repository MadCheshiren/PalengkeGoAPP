import 'dart:async';
import 'package:palengkego/features/auth/data/auth_repository.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;
  final _authStateController = StreamController<AppUser?>.broadcast();

  MockAuthRepository() {
    // In debug mode, auto-login as customer so the app is explorable immediately.
    // if (kDebugMode) {
    //   _currentUser = MockUsers.customer;
    // }
  }

  @override
  Future<AppUser> login(String email, String password, {UserRole role = UserRole.customer}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = AppUser(
      uid: role == UserRole.vendor ? 'vendor-001' : 'customer-001',
      email: email.isEmpty ? (role == UserRole.vendor ? MockUsers.vendor.email : MockUsers.customer.email) : email,
      displayName: role == UserRole.vendor ? MockUsers.vendor.displayName : MockUsers.customer.displayName,
      role: role,
    );
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> register(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = AppUser(
      uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name,
      role: UserRole.customer,
    );
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }
}
