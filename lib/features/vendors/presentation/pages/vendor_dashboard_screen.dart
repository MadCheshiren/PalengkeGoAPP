import 'package:flutter/material.dart';

import 'vendor_orders_screen.dart';
import 'vendor_products_screen.dart';

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
  Widget build(BuildContext context) {
    final screens = [
      _DashboardHome(
        isStallOpen: _isStallOpen,
        onToggleStallOpen: (value) {
          setState(() {
            _isStallOpen = value;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isStallOpen
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
      const _ProfilePlaceholder(),
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
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: Colors.white,
                  size: 20,
                ),
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
                onTap: () {},
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B372B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Sales',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'PHP 4,250.00',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        label: 'Pending',
                        value: '12 Orders',
                        color: const Color(0xFFFFF7ED),
                        textColor: const Color(0xFFB45309),
                        badge: 'ACTION REQUIRED',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(
                        label: 'Completed',
                        value: '45 Orders',
                        color: const Color(0xFFF0FDF4),
                        textColor: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD5E7DE),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 48,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Juan\'s Fresh Catch',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B372B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Stall 14, Wet Market Section',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            isStallOpen ? 'OPEN' : 'CLOSED',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isStallOpen
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: isStallOpen,
                            onChanged: onToggleStallOpen,
                            activeThumbColor: const Color(0xFF0B372B),
                            activeTrackColor: const Color(0xFF0B372B).withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          _buildRecentOrderCard(
            orderId: 'Order #RG-1029',
            customer: 'Maria Santos',
            items: '2kg Bangus | 1kg Tomatoes | 500g Ginger',
            total: 'PHP 450.00',
            time: '2 mins ago',
            onPrimaryAction: onStartPreparing,
          ),
          const SizedBox(height: 12),
          _buildRecentOrderCard(
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

  Widget _buildStatBox({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderCard({
    required String orderId,
    required String customer,
    required String items,
    required String total,
    required String time,
    required VoidCallback onPrimaryAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderId,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B372B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            items,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onPrimaryAction,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B372B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Start Preparing',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Vendor Profile',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0B372B),
        ),
      ),
    );
  }
}
