import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/vendors/application/vendor_orders_provider.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:intl/intl.dart';

class DashboardSalesCard extends ConsumerWidget {
  const DashboardSalesCard({super.key});

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
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(vendorOrdersProvider);

    final pendingOrdersCount = orders
        .where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.preparing)
        .length;

    final completedOrdersCount = orders
        .where((o) => o.status == OrderStatus.completed)
        .length;

    final todaysSales = orders
        .where((o) => o.status == OrderStatus.completed)
        .fold<double>(0.0, (sum, o) => sum + o.total);

    final currencyFormatter = NumberFormat.currency(symbol: 'PHP ', decimalDigits: 2);

    return Container(
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
          Text(
            currencyFormatter.format(todaysSales),
            style: const TextStyle(
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
                  value: pendingOrdersCount == 1 ? '1 Order' : '$pendingOrdersCount Orders',
                  color: const Color(0xFFFFF7ED),
                  textColor: const Color(0xFFB45309),
                  badge: pendingOrdersCount > 0 ? 'ACTION REQUIRED' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  label: 'Completed',
                  value: completedOrdersCount == 1 ? '1 Order' : '$completedOrdersCount Orders',
                  color: const Color(0xFFF0FDF4),
                  textColor: const Color(0xFF166534),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
