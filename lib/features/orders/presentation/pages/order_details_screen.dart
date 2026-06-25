import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/core/services/app_services.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/presentation/widgets/order_details_items_list.dart';
import 'package:palengkego/features/orders/presentation/widgets/order_details_cards.dart';
import 'package:palengkego/features/orders/presentation/widgets/order_summary_row.dart';
import 'package:palengkego/features/orders/presentation/widgets/tracking_map_preview.dart';

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
    final cancelUntil = _order.placedAt.add(const Duration(minutes: 5));
    _updateTimeRemaining(cancelUntil);

    if (_timeRemaining > Duration.zero) {
      _cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateTimeRemaining(cancelUntil);
        if (_timeRemaining <= Duration.zero) {
          timer.cancel();
        }
      });
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
    // Use ref.read — ListenableBuilder below is the sole reactive mechanism.
    // ref.watch here would create a DOUBLE subscription that triggers
    // concurrent rebuilds and the "deactivated widget ancestor" crash.
    final orderService = ref.read(orderServiceProvider);

    return ListenableBuilder(
      listenable: orderService,
      builder: (context, _) {
        final order = orderService.orders.firstWhere(
          (o) => o.id == _order.id,
          orElse: () => _order,
        );
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
                          onTap: () {
                            if (Navigator.canPop(this.context)) {
                              Navigator.pop(this.context);
                            } else {
                              Navigator.of(this.context).pushReplacementNamed(AppRoutes.main);
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
                SliverToBoxAdapter(
                  child: TrackingMapPreview(isPickup: order.isPickup),
                ),

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

                // Cancel Order Button (hidden if time expired or already cancelled/completed)
                if (order.status != OrderStatus.completed &&
                    order.status != OrderStatus.cancelled &&
                    _timeRemaining > Duration.zero)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelDialog() async {
    final activeOrders = ref.read(orderServiceProvider).orders.where(
      (o) =>
          o.status != OrderStatus.completed &&
          o.status != OrderStatus.cancelled &&
          o.placedAt.add(const Duration(minutes: 5)).isAfter(DateTime.now()),
    ).toList();

    if (activeOrders.isEmpty) return;

    List<String>? idsToCancel;

    if (activeOrders.length == 1) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
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
      for (final id in idsToCancel) {
        final cancelled = ref.read(orderServiceProvider).cancelOrder(id);
        if (cancelled) {
          successCount++;
          if (id == widget.order.id) {
            _cancelTimer?.cancel();
          }
        }
      }

      if (!mounted) return;

      if (successCount > 0) {
        AppServices.showSnackBar('$successCount order(s) cancelled successfully.');
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
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.main,
            (route) => false,
          );
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
            disabledBackgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.5),
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
