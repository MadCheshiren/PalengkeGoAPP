import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/vendors/application/vendor_orders_provider.dart';
import 'package:intl/intl.dart';

import '../widgets/vendor_screen_header.dart';

/// Vendor Orders Screen
/// Shows all orders with tabs for All, Pending, Preparing, and Ready.
class VendorOrdersScreen extends ConsumerStatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  ConsumerState<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends ConsumerState<VendorOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const VendorScreenHeader(title: 'Orders'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF0B372B),
                unselectedLabelColor: const Color(0xFF9CA3AF),
                indicatorColor: const Color(0xFF0B372B),
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Preparing'),
                  Tab(text: 'Ready'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _VendorOrdersTab(statusFilter: null),
                  _VendorOrdersTab(statusFilter: OrderStatus.pending),
                  _VendorOrdersTab(statusFilter: OrderStatus.preparing),
                  _VendorOrdersTab(statusFilter: OrderStatus.ready),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorOrdersTab extends ConsumerWidget {
  const _VendorOrdersTab({this.statusFilter});

  final OrderStatus? statusFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(vendorOrdersProvider);
    final orders = statusFilter == null
        ? allOrders
        : allOrders.where((order) => order.status == statusFilter).toList();

    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders in this tab yet.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: orders.map((order) {
        final statusColor = _getStatusColor(order.status);
        final formatCurrency = NumberFormat.currency(symbol: 'PHP ', decimalDigits: 2);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          order.statusLabel,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.isPickup ? 'Pick-Up' : 'Delivery',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatCurrency.format(order.total),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ${order.id}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, hh:mm a').format(order.placedAt),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order.customerName,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B372B),
                ),
              ),
              const Divider(height: 16, color: Color(0xFFE2E8F0)),
              Text(
                'Items (${order.items.length})',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Text(
                    '• ${item.quantity} ${item.weight} ${item.productName}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFEF3C7)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.note_alt_outlined,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Special Instructions:',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.notes!,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                color: Color(0xFF78350F),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _VendorOrderActions(order: order),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFFB902);
      case OrderStatus.preparing:
        return const Color(0xFF3B82F6);
      case OrderStatus.ready:
        return const Color(0xFF22C55E);
      case OrderStatus.completed:
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF64748B);
    }
  }
}

class _VendorOrderActions extends ConsumerWidget {
  const _VendorOrderActions({required this.order});

  final MarketOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(vendorOrdersProvider.notifier);

    if (order.status == OrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Reject',
              isPrimary: false,
              textColor: const Color(0xFFEF4444),
              onTap: () {
                final messenger = ScaffoldMessenger.of(context);
                notifier.rejectOrder(order.id);
                messenger.showSnackBar(
                  SnackBar(content: Text('Order ${order.id} was rejected.')),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              label: 'Accept',
              isPrimary: true,
              onTap: () {
                final messenger = ScaffoldMessenger.of(context);
                notifier.acceptOrder(order.id);
                messenger.showSnackBar(
                  SnackBar(content: Text('Order ${order.id} is now preparing.')),
                );
              },
            ),
          ),
        ],
      );
    }

    if (order.status == OrderStatus.preparing) {
      return SizedBox(
        width: double.infinity,
        child: _buildActionButton(
          label: 'Mark as Ready',
          isPrimary: false,
          backgroundColor: const Color(0xFFF1F5F9),
          textColor: const Color(0xFF64748B),
          icon: Icons.inventory_2_outlined,
          onTap: () {
            final messenger = ScaffoldMessenger.of(context);
            notifier.markOrderReady(order.id);
            messenger.showSnackBar(
              SnackBar(content: Text('Order ${order.id} is ready for pickup or dispatch.')),
            );
          },
        ),
      );
    }

    if (order.status == OrderStatus.ready) {
      return SizedBox(
        width: double.infinity,
        child: _buildActionButton(
          label: order.isPickup ? 'Mark as Picked Up' : 'Dispatch Order',
          isPrimary: true,
          onTap: () {
            final messenger = ScaffoldMessenger.of(context);
            notifier.completeOrder(order.id);
            messenger.showSnackBar(
              SnackBar(content: Text('Order ${order.id} has been completed.')),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink(); // No actions for completed or cancelled
  }

  Widget _buildActionButton({
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF0B372B)
              : (backgroundColor ?? Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: textColor ?? const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor ?? const Color(0xFF0B372B),
                      ),
                    ),
                  ],
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isPrimary
                        ? Colors.white
                        : (textColor ?? const Color(0xFF0B372B)),
                  ),
                ),
        ),
      ),
    );
  }
}
