import 'package:flutter/material.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/features/vendors/application/vendor_stall_controller.dart';
import 'package:palengkego/features/vendors/presentation/widgets/dashboard_sales_card.dart';
import 'package:palengkego/features/vendors/presentation/widgets/dashboard_stall_card.dart';
import 'package:palengkego/features/vendors/presentation/widgets/dashboard_recent_order_card.dart';

import 'vendor_orders_screen.dart';
import 'vendor_products_screen.dart';
import 'vendor_notifications_screen.dart';
import 'vendor_account_screen.dart';

/// Vendor Dashboard Screen
/// Main screen for vendors after completing onboarding.
/// Shows earnings summary, order stats, and quick actions.
class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _selectedIndex = 0;
  bool _isStallOpen = true;

  @override
  void initState() {
    super.initState();
    _isStallOpen = VendorStallController.instance.isOpen;
    VendorStallController.instance.addListener(_onStallControllerChanged);
  }

  @override
  void dispose() {
    VendorStallController.instance.removeListener(_onStallControllerChanged);
    super.dispose();
  }

  void _onStallControllerChanged() {
    if (mounted) {
      setState(() {
        _isStallOpen = VendorStallController.instance.isOpen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _DashboardHome(
        isStallOpen: _isStallOpen,
        onToggleStallOpen: (value) {
          VendorStallController.instance.updateStall(isOpen: value);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value
                    ? 'Your stall is now open for orders.'
                    : 'Your stall is now marked closed.',
              ),
            ),
          );
        },
        onViewOrders: () => setState(() => _selectedIndex = 1),
        onStartPreparing: () => setState(() => _selectedIndex = 1),
      ),
      const VendorOrdersScreen(),
      const VendorProductsScreen(),
      const VendorAccountScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(child: screens[_selectedIndex]),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
            _buildNavItem(1, Icons.receipt_outlined, Icons.receipt, 'Orders'),
            _buildNavItem(2, Icons.inventory_2_outlined, Icons.inventory_2, 'Products'),
            _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData iconOutlined,
    IconData iconFilled,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? iconFilled : iconOutlined,
            size: 24,
            color: isSelected ? const Color(0xFF0B372B) : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF0B372B)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({
    required this.isStallOpen,
    required this.onToggleStallOpen,
    required this.onViewOrders,
    required this.onStartPreparing,
  });

  final bool isStallOpen;
  final ValueChanged<bool> onToggleStallOpen;
  final VoidCallback onViewOrders;
  final VoidCallback onStartPreparing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B372B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: VendorStallController.instance.avatarImage != null
                      ? DecorationImage(
                          image: NetworkImage(VendorStallController.instance.avatarImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: VendorStallController.instance.avatarImage == null
                    ? const Icon(
                        Icons.storefront_outlined,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PalengkeGo Vendor',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Good morning, Mang Juan!',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageTransitions.slideFromRight(
                      const VendorNotificationsScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF0B372B),
                          size: 20,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const DashboardSalesCard(),
          const SizedBox(height: 24),
          const Text(
            'Your Stall',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B372B),
            ),
          ),
          const SizedBox(height: 16),
          DashboardStallCard(
            isStallOpen: isStallOpen,
            onToggleStallOpen: onToggleStallOpen,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B372B),
                ),
              ),
              GestureDetector(
                onTap: onViewOrders,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B372B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DashboardRecentOrderCard(
            orderId: 'Order #RG-1029',
            customer: 'Maria Santos',
            items: '2kg Bangus | 1kg Tomatoes | 500g Ginger',
            total: 'PHP 450.00',
            time: '2 mins ago',
            onPrimaryAction: onStartPreparing,
          ),
          const SizedBox(height: 12),
          DashboardRecentOrderCard(
            orderId: 'Order #RG-1028',
            customer: 'Ricardo Dalisay',
            items: '1kg Tilapia | 1kg Eggplant | 500g Garlic',
            total: 'PHP 420.00',
            time: '15 mins ago',
            onPrimaryAction: onViewOrders,
          ),
        ],
      ),
    );
  }
}
