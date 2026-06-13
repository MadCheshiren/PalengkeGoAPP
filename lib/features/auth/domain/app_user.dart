enum UserRole { customer, vendor }

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.role = UserRole.customer,
  });

  final String uid;
  final String email;
  final String? displayName;
  final UserRole role;

  bool get isVendor => role == UserRole.vendor;
  bool get isCustomer => role == UserRole.customer;

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
    );
  }
}

/// Mock users for development use — pre-seeded so no password needed.
class MockUsers {
  static const customer = AppUser(
    uid: 'customer-001',
    email: 'customer@palengkego.ph',
    displayName: 'Maria Santos',
    role: UserRole.customer,
  );

  static const vendor = AppUser(
    uid: 'vendor-001',
    email: 'vendor@palengkego.ph',
    displayName: 'Diosa Fruit Stand',
    role: UserRole.vendor,
  );
}
