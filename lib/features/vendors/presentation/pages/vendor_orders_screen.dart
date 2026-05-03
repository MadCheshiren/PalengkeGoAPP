import 'package:flutter/material.dart';

import '../widgets/vendor_screen_header.dart';

/// Vendor Orders Screen
/// Shows all orders with tabs for All, Pending, Preparing, and Ready.
class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_VendorOrder> _allOrders = [
    _VendorOrder(
      id: '1029',
      customer: 'Maria S.',
      items: ['2kg Bangus', '1kg Tomato', '0.5kg Garlic'],
      total: 'PHP 450.00',
      time: 'Today, 08:30 AM',
      status: 'Pending',
      deliveryType: 'Pick-Up',
    ),
    _VendorOrder(
      id: '1032',
      customer: 'Jose R.',
      items: [
        '1kg Pork Belly',
        '2kg Rice (Jasmine)',
        '1 bunch Kangkong',
        '2 pcs Onion',
      ],
      total: 'PHP 820.00',
      time: 'Today, 09:15 AM',
      status: 'Pending',
      deliveryType: 'Delivery',
    ),
    _VendorOrder(
      id: '1030',
      customer: 'Juan D.',
      items: ['1kg Chicken Breast', '1 dozen Eggs'],
      total: 'PHP 320.00',
      time: 'Today, 08:10 AM',
      status: 'Preparing',
      deliveryType: 'Delivery',
    ),
  ];

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
                  _VendorOrdersTab(status: 'All'),
                  _VendorOrdersTab(status: 'Pending'),
                  _VendorOrdersTab(status: 'Preparing'),
                  _VendorOrdersTab(status: 'Ready'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_VendorOrder> _filteredOrders(String filterStatus) {
    if (filterStatus == 'All') return _allOrders;
    return _allOrders.where((order) => order.status == filterStatus).toList();
  }

  void _rejectOrder(_VendorOrder order) {
    setState(() {
      _allOrders.removeWhere((candidate) => candidate.id == order.id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order #${order.id} was rejected.')));
  }

  void _updateOrderStatus(_VendorOrder order, String status, String message) {
    setState(() {
      order.status = status;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _completeOrder(_VendorOrder order) {
    setState(() {
      _allOrders.removeWhere((candidate) => candidate.id == order.id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order #${order.id} was completed.')));
  }
}

class _VendorOrdersTab extends StatelessWidget {
  const _VendorOrdersTab({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_VendorOrdersScreenState>()!;
    final orders = state._filteredOrders(status);

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
                          order.status,
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
                        order.deliveryType,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    order.total,
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
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    order.time,
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
                order.customer,
                style: const TextStyle(
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
                    '• $item',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _VendorOrderActions(order: order, owner: state),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFB902);
      case 'Preparing':
        return const Color(0xFF3B82F6);
      case 'Ready':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF64748B);
    }
  }
}

class _VendorOrderActions extends StatelessWidget {
  const _VendorOrderActions({required this.order, required this.owner});

  final _VendorOrder order;
  final _VendorOrdersScreenState owner;

  @override
  Widget build(BuildContext context) {
    if (order.status == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Reject',
              isPrimary: false,
              textColor: const Color(0xFFEF4444),
              onTap: () => owner._rejectOrder(order),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              label: 'Accept',
              isPrimary: true,
              onTap: () => owner._updateOrderStatus(
                order,
                'Preparing',
                'Order #${order.id} is now preparing.',
              ),
            ),
          ),
        ],
      );
    }

    if (order.status == 'Preparing') {
      return SizedBox(
        width: double.infinity,
        child: _buildActionButton(
          label: 'Mark as Ready',
          isPrimary: false,
          backgroundColor: const Color(0xFFF1F5F9),
          textColor: const Color(0xFF64748B),
          icon: Icons.inventory_2_outlined,
          onTap: () => owner._updateOrderStatus(
            order,
            'Ready',
            'Order #${order.id} is ready for pickup or dispatch.',
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: _buildActionButton(
        label: 'Mark as Picked Up',
        isPrimary: true,
        onTap: () => owner._completeOrder(order),
      ),
    );
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
          color: isPrimary ? const Color(0xFF0B372B) : (backgroundColor ?? Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: textColor ?? const Color(0xFF64748B)),
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
                    color: isPrimary ? Colors.white : (textColor ?? const Color(0xFF0B372B)),
                  ),
                ),
        ),
      ),
    );
  }
}

class _VendorOrder {
  _VendorOrder({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.time,
    required this.status,
    required this.deliveryType,
  });

  final String id;
  final String customer;
  final List<String> items;
  final String total;
  final String time;
  String status;
  final String deliveryType;
}
