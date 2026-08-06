import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palengkego/features/auth/data/auth_repository.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;
  final _authStateController = StreamController<AppUser?>.broadcast();

  MockAuthRepository() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('mock_auth_uid');
    final roleString = prefs.getString('mock_auth_role');

    if (uid != null && roleString != null) {
      final role = roleString == 'stall holder'
          ? UserRole.vendor
          : UserRole.customer;
      _currentUser = AppUser(
        uid: uid,
        email: role == UserRole.vendor
            ? MockUsers.vendor.email
            : MockUsers.customer.email,
        displayName: role == UserRole.vendor
            ? MockUsers.vendor.displayName
            : MockUsers.customer.displayName,
        role: role,
      );
      _authStateController.add(_currentUser);
    }
  }

  Future<void> _saveSession(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mock_auth_uid', user.uid);
    await prefs.setString(
      'mock_auth_role',
      user.role == UserRole.vendor ? 'stall holder' : 'customer',
    );
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mock_auth_uid');
    await prefs.remove('mock_auth_role');
  }

  @override
  Future<AppUser> login(
    String email,
    String password, {
    UserRole role = UserRole.customer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = AppUser(
      uid: role == UserRole.vendor ? 'stall holder-001' : 'customer-001',
      email: email.isEmpty
          ? (role == UserRole.vendor
                ? MockUsers.vendor.email
                : MockUsers.customer.email)
          : email,
      displayName: role == UserRole.vendor
          ? MockUsers.vendor.displayName
          : MockUsers.customer.displayName,
      role: role,
    );
    await _saveSession(_currentUser!);
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
    await _saveSession(_currentUser!);
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _clearSession();
    _authStateController.add(null);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    // Mock: simulate a Google OAuth login as a customer.
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = AppUser(
      uid: 'google-mock-001',
      email: 'google.user@gmail.com',
      displayName: 'Google User',
      role: UserRole.customer,
    );
    await _saveSession(_currentUser!);
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }
}
