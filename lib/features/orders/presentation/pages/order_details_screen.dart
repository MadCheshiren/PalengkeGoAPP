import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/config/fee_config.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/core/services/app_services.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_failure.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/presentation/widgets/order_details_items_list.dart';
import 'package:palengkego/features/orders/presentation/widgets/order_details_cards.dart';
import 'package:palengkego/features/orders/presentation/widgets/order_summary_row.dart';
import 'package:palengkego/features/orders/presentation/widgets/tracking_map_preview.dart';
import 'package:palengkego/features/profile/application/preferences_provider.dart';
import 'package:palengkego/features/profile/application/blocked_vendors_provider.dart';
import 'package:palengkego/features/vendors/presentation/widgets/block_vendor_dialog.dart';
import 'package:palengkego/features/vendors/presentation/widgets/report_vendor_dialog.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final MarketOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  Timer? _cancelTimer;
  late MarketOrder _order;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _startCancelTimer();
  }

  void _startCancelTimer() {
    final cancelUntil = _order.placedAt.add(FeeConfig.cancelWindow);
    _updateTimeRemaining(cancelUntil);

    if (_timeRemaining > Duration.zero) {
      _cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateTimeRemaining(cancelUntil);
        if (_timeRemaining <= Duration.zero) {
          timer.cancel();
          _autoCancelIfNeeded();
        }
      });
    } else {
      _autoCancelIfNeeded();
    }
  }

  Future<void> _autoCancelIfNeeded() async {
    final currentOrder = ref
        .read(orderServiceProvider)
        .value
        ?.firstWhere((o) => o.id == _order.id, orElse: () => _order);

    if (currentOrder != null && currentOrder.status == OrderStatus.pending) {
      try {
        await ref
            .read(orderServiceProvider.notifier)
            .cancelOrder(
              _order.id,
              now: _order.placedAt.add(FeeConfig.cancelWindow),
            );
        if (!mounted) return;
        AppServices.showSnackBar('Order automatically cancelled (timeout).');
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) {
            return route.settings.name != null &&
                route.settings.name != AppRoutes.orderDetails &&
                route.settings.name != AppRoutes.trackOrder;
          });
        } else {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
        }
      } on OrderFailure {
        // Window already expired server-side — leave the order untouched.
      }
    }
  }

  void _updateTimeRemaining(DateTime cancelUntil) {
    final remaining = cancelUntil.difference(DateTime.now());
    if (mounted) {
      setState(() {
        _timeRemaining = remaining > Duration.zero ? remaining : Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _cancelTimer?.cancel();
    super.dispose();
  }

  String _getStatusDescription(MarketOrder order) {
    if (order.status == OrderStatus.completed) {
      return 'Delivered and completed successfully';
    } else if (order.status == OrderStatus.cancelled) {
      return 'This order has been cancelled';
    } else if (order.status == OrderStatus.confirmed) {
      return 'Confirmed by stall holder';
    } else if (order.status == OrderStatus.preparing) {
      return 'Stall Holder is preparing your items';
    } else if (order.status == OrderStatus.ready) {
      return 'Your order is ready';
    } else {
      return 'Waiting for stall holder confirmation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderServiceProvider);

    return ordersAsync.when(
      data: (orders) {
        final order = orders.firstWhere(
          (o) => o.id == _order.id,
          orElse: () => _order,
        );
        final subtotalAmount = order.subtotal;
        final deliveryFeeAmount = order.deliveryFee;
        final serviceFeeAmount = order.serviceFee;
        final totalAmount = order.total;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          bottomNavigationBar:
              (order.status == OrderStatus.pending &&
                  _timeRemaining > Duration.zero)
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _showCancelDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B372B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          'Cancel Order (${_timeRemaining.inMinutes.toString().padLeft(2, '0')}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')})',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
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
                          onTap: () {
                            if (Navigator.canPop(this.context)) {
                              Navigator.pop(this.context);
                            } else {
                              Navigator.of(
                                this.context,
                              ).pushReplacementNamed(AppRoutes.main);
                            }
                          },
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

                // Map Preview
                SliverToBoxAdapter(child: TrackingMapPreview(order: order)),

                // Status Timeline Bento Section
                SliverToBoxAdapter(
                  child: OrderDetailsStatusCard(
                    order: order,
                    statusDescription: _getStatusDescription(order),
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
                SliverToBoxAdapter(child: OrderDetailsVendorCard(order: order)),

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
                SliverToBoxAdapter(child: OrderDetailsNotesCard(order: order)),

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
                          if (order.isPriority) ...[
                            const SizedBox(height: 12),
                            OrderSummaryRow(
                              label: 'Priority Delivery Fee',
                              value: '₱${order.priorityFee.toStringAsFixed(2)}',
                            ),
                          ],
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

                // History Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.status == OrderStatus.completed ||
                            order.status == OrderStatus.cancelled) ...[
                          const Text(
                            'Stall Holder Actions',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B372B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  label: 'Report Stall Holder',
                                  icon: Icons.flag_outlined,
                                  backgroundColor: Colors.white,
                                  textColor: const Color(0xFFF59E0B),
                                  borderColor: const Color(0xFFFDE68A),
                                  onTap: () {
                                    _showReportDialog(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  label: 'Block Stall Holder',
                                  icon: Icons.block,
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  textColor: const Color(0xFFDC2626),
                                  borderColor: const Color(0xFFFECACA),
                                  onTap: () {
                                    _showBlockDialog(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0B372B)),
        ),
      ),
      error: (err, stack) =>
          const Scaffold(body: Center(child: Text('Error loading order'))),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) async {
    final reason = await ReportVendorDialog.show(context, 'stall holder');
    if (reason != null && reason.isNotEmpty && context.mounted) {
      AppServices.showSnackBar('Stall Holder reported successfully.');
    }
  }

  void _showBlockDialog(BuildContext context) async {
    final confirmed = await BlockVendorDialog.show(
      context,
      vendorName: widget.order.vendorName,
    );
    if (confirmed == true && context.mounted) {
      final vendorName = widget.order.vendorName;
      final stallId = widget.order.stallId;

      if (stallId != null && stallId.isNotEmpty) {
        ref.read(blockedVendorsProvider.notifier).block(stallId);
        ref.read(preferencesProvider.notifier).blockStall(stallId);
      }
      ref.read(blockedVendorsProvider.notifier).block(vendorName);
      ref.read(preferencesProvider.notifier).blockStall(vendorName);

      AppServices.showSnackBar('$vendorName has been blocked.');
      Navigator.of(context).pop();
    }
  }

  void _showCancelDialog() async {
    final orders = ref.read(orderServiceProvider).value ?? [];
    final activeOrders = orders
        .where(
          (o) =>
              o.status == OrderStatus.pending &&
              o.placedAt
                  .add(const Duration(minutes: 2))
                  .isAfter(DateTime.now()),
        )
        .toList();

    if (activeOrders.isEmpty) return;

    List<String>? idsToCancel;

    if (activeOrders.length == 1) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'No, Keep It',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        idsToCancel = [widget.order.id];
      }
    } else {
      idsToCancel = await showDialog<List<String>>(
        context: context,
        builder: (dialogContext) => _CancelOrdersDialog(
          activeOrders: activeOrders,
          currentOrderId: widget.order.id,
        ),
      );
    }

    if (idsToCancel != null && idsToCancel.isNotEmpty) {
      if (!mounted) return;

      int successCount = 0;
      String? firstFailure;
      for (final id in idsToCancel) {
        try {
          await ref.read(orderServiceProvider.notifier).cancelOrder(id);
          successCount++;
          if (id == widget.order.id) {
            _cancelTimer?.cancel();
          }
        } on OrderFailure catch (e) {
          firstFailure ??= e.message;
        }
      }

      if (!mounted) return;

      if (successCount > 0) {
        AppServices.showSnackBar(
          '$successCount order(s) cancelled successfully.',
        );
      }
      if (firstFailure != null) {
        AppServices.showSnackBar(firstFailure);
      }

      final currentOrderCancelled = idsToCancel.contains(widget.order.id);

      if (currentOrderCancelled) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) {
            return route.settings.name != null &&
                route.settings.name != AppRoutes.orderDetails &&
                route.settings.name != AppRoutes.trackOrder;
          });
        } else {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
        }
      }
    }
  }
}

class _CancelOrdersDialog extends StatefulWidget {
  final List<MarketOrder> activeOrders;
  final String currentOrderId;

  const _CancelOrdersDialog({
    required this.activeOrders,
    required this.currentOrderId,
  });

  @override
  State<_CancelOrdersDialog> createState() => _CancelOrdersDialogState();
}

class _CancelOrdersDialogState extends State<_CancelOrdersDialog> {
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedIds.add(widget.currentOrderId);
  }

  void _toggleAll() {
    setState(() {
      if (_selectedIds.length == widget.activeOrders.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(widget.activeOrders.map((o) => o.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = _selectedIds.length == widget.activeOrders.length;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Cancel Orders',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select the active orders you wish to cancel. This action cannot be undone.',
              style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select All',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Checkbox(
                  value: allSelected,
                  activeColor: const Color(0xFF0B372B),
                  onChanged: (_) => _toggleAll(),
                ),
              ],
            ),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.activeOrders.length,
                itemBuilder: (context, index) {
                  final order = widget.activeOrders[index];
                  final isSelected = _selectedIds.contains(order.id);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.trailing,
                    activeColor: const Color(0xFF0B372B),
                    title: Text(
                      order.vendorName,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Order ${order.id} • ₱${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIds.add(order.id);
                        } else {
                          _selectedIds.remove(order.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
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
          onPressed: _selectedIds.isEmpty
              ? null
              : () => Navigator.pop(context, _selectedIds.toList()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            disabledBackgroundColor: const Color(
              0xFFDC2626,
            ).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Confirm',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
