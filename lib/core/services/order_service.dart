import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/config/fee_config.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';

class OrderService extends AsyncNotifier<List<MarketOrder>> {
  static const cancelWindow = FeeConfig.cancelWindow;

  @override
  Future<List<MarketOrder>> build() async {
    final uid = ref.watch(authProvider)?.uid;
    if (uid == null || uid.isEmpty) return [];
    return ref.watch(orderRepositoryProvider).getOrdersForCustomer(uid);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final uid = ref.read(authProvider)?.uid;
    if (uid == null) return;

    await ref
        .read(orderRepositoryProvider)
        .updateOrderStatus(orderId, newStatus);
    ref.invalidateSelf();
  }

  Future<bool> cancelOrder(String orderId, {DateTime? now}) async {
    final uid = ref.read(authProvider)?.uid;
    if (uid == null) return false;

    final ordersList = state.value;
    if (ordersList == null) return false;

    final order = ordersList.where((o) => o.id == orderId).firstOrNull;
    if (order == null) return false;

    if (order.status == OrderStatus.completed ||
        order.status == OrderStatus.cancelled) {
      return false;
    }

    final currentTime = now ?? DateTime.now();
    final cancelUntil = order.placedAt.add(cancelWindow);
    if (currentTime.isAfter(cancelUntil)) {
      return false;
    }

    await ref
        .read(orderRepositoryProvider)
        .updateOrderStatus(orderId, OrderStatus.cancelled);
    ref.invalidateSelf();
    return true;
  }

  void refresh() {
    ref.invalidateSelf();
  }

  Future<void> clearOrders() async {
    ref.invalidateSelf();
  }
}
