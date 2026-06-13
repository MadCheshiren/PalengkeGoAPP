import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/vendors/application/vendor_stall_provider.dart';

/// Notifier to manage orders specifically for the currently logged-in vendor.
/// Watches the global OrderService and filters orders for the current vendor.
class VendorOrdersNotifier extends Notifier<List<MarketOrder>> {
  @override
  List<MarketOrder> build() {
    final orderService = ref.watch(orderServiceProvider);
    final stall = ref.watch(vendorStallProvider);

    void listener() {
      state = _filterForVendor(orderService.orders, stall.name);
    }

    orderService.addListener(listener);
    ref.onDispose(() => orderService.removeListener(listener));

    return _filterForVendor(orderService.orders, stall.name);
  }

  List<MarketOrder> _filterForVendor(List<MarketOrder> allOrders, String vendorName) {
    return allOrders
        .where((order) => order.vendorName == vendorName)
        .toList();
  }

  void acceptOrder(String orderId) =>
      ref.read(orderServiceProvider).updateOrderStatus(orderId, OrderStatus.preparing);

  void rejectOrder(String orderId) =>
      ref.read(orderServiceProvider).updateOrderStatus(orderId, OrderStatus.cancelled);

  void markOrderReady(String orderId) =>
      ref.read(orderServiceProvider).updateOrderStatus(orderId, OrderStatus.ready);

  void completeOrder(String orderId) =>
      ref.read(orderServiceProvider).updateOrderStatus(orderId, OrderStatus.completed);
}

final vendorOrdersProvider =
    NotifierProvider<VendorOrdersNotifier, List<MarketOrder>>(
  VendorOrdersNotifier.new,
);
