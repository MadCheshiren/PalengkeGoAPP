class CustomerProfile {
  const CustomerProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    required this.addresses,
  });

  final String uid;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final List<String> addresses;

  CustomerProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    List<String>? addresses,
  }) {
    return CustomerProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      addresses: addresses ?? this.addresses,
    );
  }
}
