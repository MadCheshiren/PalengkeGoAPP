import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/vendors/domain/vendor_stall.dart';

/// Riverpod Notifier that manages the currently logged-in vendor's stall state.
/// Replaces the old VendorStallController singleton.
class VendorStallNotifier extends Notifier<VendorStall> {
  @override
  VendorStall build() {
    final user = ref.watch(authProvider);
    if (user != null && user.isVendor) {
      return VendorStall(
        name: user.displayName ?? 'My Stall',
        description: 'Fresh products directly to your doorstep. Quality and freshness guaranteed!',
        category: user.displayName == 'Diosa Fruit Stand' ? 'Fruits' : 'General',
        location: 'Stall 4, Wet Market Section',
        isOpen: true,
      );
    }
    return const VendorStall(
      name: "Juan's Fresh Catch",
      description:
          'We offer the freshest seafood directly from local ports. Quality and freshness guaranteed!',
      category: 'Fish & Seafood',
      location: 'Stall 14, Wet Market Section',
      isOpen: true,
    );
  }

  void updateStall({
    String? name,
    String? description,
    String? category,
    String? location,
    String? bannerImage,
    String? avatarImage,
    bool? isOpen,
  }) {
    state = state.copyWith(
      name: name,
      description: description,
      category: category,
      location: location,
      bannerImage: bannerImage == '' ? null : bannerImage,
      avatarImage: avatarImage == '' ? null : avatarImage,
      clearBanner: bannerImage == '',
      clearAvatar: avatarImage == '',
      isOpen: isOpen,
    );
  }

  void toggleOpen() {
    state = state.copyWith(isOpen: !state.isOpen);
  }
}

final vendorStallProvider = NotifierProvider<VendorStallNotifier, VendorStall>(
  VendorStallNotifier.new,
);
