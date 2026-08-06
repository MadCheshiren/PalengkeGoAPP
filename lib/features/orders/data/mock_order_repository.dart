import 'package:palengkego/core/config/fee_config.dart';
import 'package:palengkego/core/mock/mock_data.dart';
import 'package:palengkego/features/orders/domain/fulfillment_method.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_line_item.dart';
import 'package:palengkego/features/orders/domain/order_repository.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/domain/order_status_history.dart';
import 'package:palengkego/features/orders/domain/payment_status.dart';

import 'package:palengkego/features/orders/data/shared_order_store.dart';

class MockOrderRepository implements OrderRepository {
  static const _cancelWindow = FeeConfig.cancelWindow;

  // ── Seeded mock orders ────────────────────────────────────────────────────
  final List<MarketOrder> _orders = SharedOrderStore.orders;

  // Status history per orderId.
  final Map<String, List<OrderStatusHistory>> _history =
      SharedOrderStore.history;

  int _seq = 1;

  @override
  Future<List<MarketOrder>> placeOrders({
    required Map<String, (String vendorImage, List<OrderLineItem> items)>
    groupedItems,
    required bool isPickup,
    String customerUid = '',
    String customerName = 'Customer',
    Map<String, String>? vendorNotes,
    String? deliveryAddress,
    bool isPriority = false,
    double priorityFee = 0.0,
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    final todayPrefix = '#$dateStr';
    final maxSeq = SharedOrderStore.orders
        .where((o) => o.id.startsWith(todayPrefix))
        .map((o) => int.tryParse(o.id.replaceFirst(todayPrefix, '')) ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);
    _seq = maxSeq + 1;

    final created = <MarketOrder>[];
    for (final entry in groupedItems.entries) {
      final orderId = '#$dateStr${_seq++}';
      final vendorName = entry.key;
      final vendorImage = entry.value.$1;
      final lineItems = entry.value.$2;

      final vendor = MockDataService.featuredVendors.firstWhere(
        (v) => v['name'] == vendorName,
        orElse: () => {'id': 'stall holder-001'},
      );
      final stallId = vendor['id'] as String;

      final order = MarketOrder(
        id: orderId,
        customerUid: customerUid.isEmpty ? 'customer-001' : customerUid,
        stallId: stallId,
        vendorName: vendorName,
        vendorImage: vendorImage,
        customerName: customerName,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        fulfillmentMethod: isPickup
            ? FulfillmentMethod.pickup
            : FulfillmentMethod.delivery,
        deliveryAddress: isPickup
            ? null
            : (deliveryAddress ?? '123 Default Address'),
        deliveryFee: isPickup ? 0.0 : FeeConfig.deliveryFee,
        serviceFee: FeeConfig.serviceFee,
        isPriority: isPickup ? false : isPriority,
        priorityFee: isPickup ? 0.0 : priorityFee,
        placedAt: now,
        notes: vendorNotes?[entry.key],
        items: lineItems,
      );
      _orders.add(order);
      _history[orderId] = [
        OrderStatusHistory(
          historyId: 'h-$orderId-1',
          orderId: orderId,
          newStatus: OrderStatus.pending,
          changedBy: customerUid.isEmpty ? 'customer' : customerUid,
          changedAt: now,
        ),
      ];

      created.add(order);
    }
    await SharedOrderStore.save();
    return created;
  }

  @override
  Future<List<MarketOrder>> getOrdersForCustomer(String customerUid) async {
    // In mock mode all orders belong to the same customer.
    final sorted = List<MarketOrder>.from(_orders)
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return List.unmodifiable(sorted);
  }

  @override
  Future<List<MarketOrder>> getOrdersForVendor(String stallId) async {
    // Resolve vendor name from ID
    final vendor = MockDataService.featuredVendors.firstWhere(
      (v) => v['id'] == stallId,
      orElse: () => {'name': stallId},
    );
    final vendorName = vendor['name'] as String;
    final filtered = _orders.where((o) => o.vendorName == vendorName).toList();
    final sorted = List<MarketOrder>.from(filtered)
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return List.unmodifiable(sorted);
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? changedByUid,
    String? remarks,
    DateTime? estimatedReadyTime,
  }) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;

    final previous = _orders[idx].status;
    _orders[idx] = _orders[idx].copyWith(
      status: newStatus,
      paymentStatus: newStatus == OrderStatus.completed
          ? PaymentStatus.paid
          : _orders[idx].paymentStatus,
      estimatedReadyTime: estimatedReadyTime ?? _orders[idx].estimatedReadyTime,
      cancellationReason:
          (newStatus == OrderStatus.cancelled ||
              newStatus == OrderStatus.rejected)
          ? (remarks ?? _orders[idx].cancellationReason)
          : _orders[idx].cancellationReason,
    );

    if (newStatus == OrderStatus.completed &&
        previous != OrderStatus.completed) {
      for (final item in _orders[idx].items) {
        MockDataService.decreaseProductStockByName(
          item.productName,
          _orders[idx].vendorName,
          item.quantity,
        );
      }
    }

    _history.putIfAbsent(orderId, () => []);
    _history[orderId]!.add(
      OrderStatusHistory(
        historyId: 'h-$orderId-${_history[orderId]!.length + 1}',
        orderId: orderId,
        previousStatus: previous,
        newStatus: newStatus,
        changedBy: changedByUid ?? 'system',
        changedAt: DateTime.now(),
        remarks: remarks,
      ),
    );
    await SharedOrderStore.save();
  }

  @override
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return false;

    final order = _orders[idx];
    if (order.status != OrderStatus.pending) return false;

    final cancelUntil = order.placedAt.add(_cancelWindow);
    if (DateTime.now().isAfter(cancelUntil)) return false;

    await updateOrderStatus(
      orderId,
      OrderStatus.cancelled,
      changedByUid: 'customer',
      remarks: reason,
    );
    return true;
  }

  @override
  Future<List<OrderStatusHistory>> getOrderHistory(String orderId) async {
    return List.unmodifiable(_history[orderId] ?? []);
  }
}
