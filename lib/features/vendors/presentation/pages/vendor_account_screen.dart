import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/features/vendors/application/vendor_stall_provider.dart';
import 'vendor_earnings_screen.dart';
import 'vendor_stall_settings_screen.dart';
import 'vendor_account_details_screen.dart';
import 'vendor_help_support_screen.dart';

/// Vendor Account Screen
/// The vendor's own profile/settings page, displayed in the Dashboard's Profile tab.
/// Shows stall info, quick links to Earnings, and account settings.
class VendorAccountScreen extends ConsumerWidget {
  const VendorAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stall = ref.watch(vendorStallProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Vendor Avatar & Name
          Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0B372B),
                  border: Border.all(
                    color: const Color(0xFFD5E7DE),
                    width: 3,
                  ),
                  image: stall.avatarImage != null
                      ? DecorationImage(
                          image: NetworkImage(stall.avatarImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: stall.avatarImage == null
                    ? const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 40,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                stall.name,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                  const SizedBox(height: 4),
              Text(
                stall.location,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF22C55E),
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Verified Vendor',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  value: '4.8',
                  label: 'Rating',
                  icon: Icons.star_rounded,
                  iconColor: Color(0xFFF59E0B),
                ),
                _StatItem(
                  value: '152',
                  label: 'Orders',
                  icon: Icons.receipt_long_rounded,
                  iconColor: Color(0xFF22C55E),
                ),
                _StatItem(
                  value: '28',
                  label: 'Products',
                  icon: Icons.inventory_2_rounded,
                  iconColor: Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _buildMenuItem(
            context,
            icon: Icons.account_balance_wallet_rounded,
            title: 'Earnings & Payouts',
            subtitle: 'View your sales and payout history',
            onTap: () {
              Navigator.of(context).push(
                PageTransitions.slideFromRight(const VendorEarningsScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.storefront_rounded,
            title: 'Stall Settings',
            subtitle: 'Edit stall info, photos & operating hours',
            onTap: () {
              Navigator.of(context).push(
                PageTransitions.slideFromRight(
                  const VendorStallSettingsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.person_rounded,
            title: 'Account Details',
            subtitle: 'Edit your personal information',
            onTap: () {
              Navigator.of(context).push(
                PageTransitions.slideFromRight(
                  const VendorAccountDetailsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Get help with your vendor account',
            onTap: () {
              Navigator.of(context).push(
                PageTransitions.slideFromRight(const VendorHelpSupportScreen()),
              );
            },
          ),

          const SizedBox(height: 8),

          // Logout Button
          GestureDetector(
            onTap: () => _showLogoutDialog(context, ref),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: const Color(0xFF0B372B), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your vendor account?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
              Navigator.pop(ctx);
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0B372B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
