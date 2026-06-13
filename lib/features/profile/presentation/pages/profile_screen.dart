import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/profile/application/favorites_provider.dart';
import 'package:palengkego/features/profile/application/profile_provider.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_profile_screen.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_onboarding_screen.dart';
import 'edit_profile_screen.dart';
import 'security_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(currentProfileProvider);
    final favoriteVendors = ref.watch(favoriteVendorsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/back button icon.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF0B372B),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Info Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: profileAsyncValue.when(
                  data: (profile) {
                    if (profile == null) {
                      return const Center(child: Text('Not Logged In'));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // ── Avatar ────────────────────────────────────────
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0B372B),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: profile.avatarUrl != null
                                  ? Image.network(
                                      profile.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _fallbackAvatar(),
                                    )
                                  : _fallbackAvatar(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            profile.displayName,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B372B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            profile.email,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Favorites Section ─────────────────────────────
                        if (favoriteVendors.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'My Favorites',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0B372B),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${favoriteVendors.length}',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0B372B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: favoriteVendors.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final vendor = favoriteVendors[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      PageTransitions.slideFromRight(
                                        VendorProfileScreen(
                                            vendorId: vendor.id),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                              alpha: 0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                            child: Image.network(
                                              vendor.imageUrl,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  Container(
                                                color:
                                                    const Color(0xFFE8F5E9),
                                                child: const Icon(
                                                  Icons.storefront_outlined,
                                                  color: Color(0xFF6D9773),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Text(
                                            vendor.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0B372B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // ── Menu Items ────────────────────────────────────
                        _buildMenuItem(
                          iconPath: 'assets/icons/profile icon.svg',
                          title: 'Edit Profile',
                          onTap: () {
                            Navigator.of(context).push(
                              PageTransitions.slideFromRight(
                                const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          iconPath: 'assets/icons/Security Icon.svg',
                          title: 'Security',
                          onTap: () {
                            Navigator.of(context).push(
                              PageTransitions.slideFromRight(
                                const SecuritySettingsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          iconPath: 'assets/icons/start selling icon.svg',
                          title: 'Start Selling',
                          onTap: () {
                            Navigator.of(context).push(
                              PageTransitions.slideFromRight(
                                const VendorOnboardingScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          iconPath: 'assets/icons/logout icon.svg',
                          title: 'Logout',
                          onTap: () => _showLogoutDialog(context, ref),
                          isLogout: true,
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ),
                  error: (error, stack) =>
                      Center(child: Text('Error: $error')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: const Icon(
        Icons.person_rounded,
        size: 48,
        color: Color(0xFF0B372B),
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isLogout ? Border.all(color: const Color(0xFFEF4444)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                isLogout ? const Color(0xFFEF4444) : const Color(0xFF0B372B),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isLogout
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isLogout
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
