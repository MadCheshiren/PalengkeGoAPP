import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/notifications/application/notification_provider.dart';
import 'package:palengkego/features/vendors/application/vendor_stall_provider.dart';
import 'package:palengkego/features/vendors/presentation/widgets/dashboard_sales_card.dart';
import 'package:palengkego/features/vendors/presentation/widgets/dashboard_stall_card.dart';
import 'package:palengkego/features/vendors/presentation/widgets/dashboard_recent_order_card.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/vendors/application/vendor_orders_provider.dart';

import 'vendor_orders_screen.dart';
import 'vendor_products_screen.dart';
import 'vendor_notifications_screen.dart';
import 'vendor_account_screen.dart';
import 'package:palengkego/features/vendors/presentation/widgets/floating_new_order_notification.dart';

/// Vendor Dashboard Screen
/// Main screen for vendors after completing onboarding.
/// Shows earnings summary, order stats, and quick actions.
class VendorDashboardScreen extends ConsumerStatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  ConsumerState<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends ConsumerState<VendorDashboardScreen> {
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    final stall = ref.watch(vendorStallProvider);
    final screens = [
      _DashboardHome(
        isStallOpen: stall.isOpen,
        onToggleStallOpen: (value) {
          ref.read(vendorStallProvider.notifier).updateStall(isOpen: value);
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
      body: SafeArea(
        child: Stack(
          children: [
            screens[_selectedIndex],
            FloatingNewOrderNotification(
              onViewOrders: () => setState(() => _selectedIndex = 1),
            ),
          ],
        ),
      ),
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
            _buildNavItem(
              0,
              Icons.dashboard_outlined,
              Icons.dashboard,
              'Dashboard',
            ),
            _buildNavItem(1, Icons.receipt_outlined, Icons.receipt, 'Orders'),
            _buildNavItem(
              2,
              Icons.inventory_2_outlined,
              Icons.inventory_2,
              'Products',
            ),
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
            color: isSelected
                ? const Color(0xFF0B372B)
                : const Color(0xFF94A3B8),
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

class _DashboardHome extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final stall = ref.watch(vendorStallProvider);
    final user = ref.watch(authProvider);
    final greetingName = user?.displayName ?? stall.name;

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
                  image: stall.avatarImage != null
                      ? DecorationImage(
                          image: NetworkImage(stall.avatarImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: stall.avatarImage == null
                    ? const Icon(
                        Icons.storefront_outlined,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PalengkeGo Vendor',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Good morning, $greetingName!',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final notifService =
                      ref.read(notificationServiceProvider);
                  return ListenableBuilder(
                    listenable: notifService,
                    builder: (context, _) {
                      final unread = notifService.vendorUnreadCount;
                      return GestureDetector(
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
                              if (unread > 0)
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
                      );
                    },
                  );
                },
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
          Consumer(
            builder: (context, ref, _) {
              final orders = ref.watch(vendorOrdersProvider)
                  .where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.preparing)
                  .take(2)
                  .toList();
                  
              if (orders.isEmpty) {
                return const Text(
                  'No recent orders.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: Color(0xFF64748B),
                  ),
                );
              }
              
              return Column(
                children: orders.map((order) {
                  final itemsStr = order.items.map((i) => '${i.quantity} ${i.weight} ${i.productName}').join(' | ');
                  final totalStr = 'PHP ${order.total.toStringAsFixed(2)}';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DashboardRecentOrderCard(
                      orderId: 'Order #${order.id}',
                      customer: 'Customer',
                      items: itemsStr,
                      total: totalStr,
                      time: 'Just now',
                      primaryActionText: order.status == OrderStatus.pending ? 'Start Preparing' : 'View Order',
                      onPrimaryAction: order.status == OrderStatus.pending ? onStartPreparing : onViewOrders,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
