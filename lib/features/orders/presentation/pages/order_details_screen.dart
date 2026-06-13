import 'package:flutter/material.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/presentation/widgets/order_details_items_list.dart';
import 'package:palengkego/features/orders/presentation/widgets/order_details_cards.dart';
import 'package:palengkego/features/orders/presentation/widgets/order_summary_row.dart';

class OrderDetailsScreen extends StatelessWidget {
  final MarketOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  String get _statusDescription {
    if (order.status == OrderStatus.completed) {
      return 'Delivered and completed successfully';
    } else if (order.status == OrderStatus.cancelled) {
      return 'This order has been cancelled';
    } else if (order.status == OrderStatus.confirmed) {
      return 'Confirmed by vendor';
    } else if (order.status == OrderStatus.preparing) {
      return 'Vendor is preparing your items';
    } else if (order.status == OrderStatus.ready) {
      return 'Your order is ready';
    } else {
      return 'Waiting for vendor confirmation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotalAmount = order.subtotal;
    final deliveryFeeAmount = order.deliveryFee;
    final serviceFeeAmount = order.serviceFee;
    final totalAmount = order.total;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Status Timeline Bento Section
            SliverToBoxAdapter(
              child: OrderDetailsStatusCard(
                order: order,
                statusDescription: _statusDescription,
              ),
            ),

            // Estimated Arrival / Pickup Ready
            SliverToBoxAdapter(
              child: OrderDetailsArrivalCard(order: order),
            ),

            // Delivery Address
            SliverToBoxAdapter(
              child: OrderDetailsAddressCard(order: order),
            ),

            // Vendor Stall Card
            SliverToBoxAdapter(
              child: OrderDetailsVendorCard(order: order),
            ),

            // Items List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items List',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${order.items.length} Items',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B372B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OrderDetailsItemsList(items: order.items),
                  ],
                ),
              ),
            ),

            // Notes Card
            SliverToBoxAdapter(
              child: OrderDetailsNotesCard(order: order),
            ),

            // Payment Method
            SliverToBoxAdapter(
              child: OrderDetailsPaymentCard(order: order),
            ),

            // Order Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      OrderSummaryRow(
                        label: 'Subtotal',
                        value: '₱${subtotalAmount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      OrderSummaryRow(
                        label: 'Delivery Fee',
                        value: '₱${deliveryFeeAmount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      OrderSummaryRow(
                        label: 'Service Fee',
                        value: '₱${serviceFeeAmount.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24, color: Color(0xFFE5E7EB)),
                      OrderSummaryRow(
                        label: 'Total',
                        value: '₱${totalAmount.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Cancel Order Button (hidden for completed/cancelled/ready/preparing orders)
            if (order.status != OrderStatus.completed &&
                order.status != OrderStatus.cancelled &&
                order.status != OrderStatus.ready &&
                order.status != OrderStatus.preparing)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _showCancelDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B372B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        'Cancel Order',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Order?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No, Keep It',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Order cancellation request submitted!',
                    style: TextStyle(fontFamily: 'PlusJakartaSans'),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(fontFamily: 'PlusJakartaSans'),
            ),
          ),
        ],
      ),
    );
  }
}
