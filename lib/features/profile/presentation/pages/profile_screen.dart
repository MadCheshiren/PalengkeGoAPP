import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palengkego/features/auth/presentation/pages/login_screen.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_onboarding_screen.dart';
import 'edit_profile_screen.dart';
import 'security_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Avatar with border
                    Container(
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
                        child: Image.network(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFE8F5E9),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: Color(0xFF0B372B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User Name
                    const Text(
                      'Roonies',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    const Text(
                      'roonies@gmail.com',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Menu Items
                    _buildMenuItem(
                      iconPath: 'assets/icons/profile icon.svg',
                      title: 'Edit Profile',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/icons/Security Icon.svg',
                      title: 'Security',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SecuritySettingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/icons/start selling icon.svg',
                      title: 'Start Selling',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VendorOnboardingScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      iconPath: 'assets/icons/logout icon.svg',
                      title: 'Logout',
                      onTap: () => _showLogoutDialog(context),
                      isLogout: true,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                  color: isLogout ? const Color(0xFFEF4444) : const Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isLogout ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
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
