import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_line_item.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/domain/order_status_history.dart';

/// Contract for all order data operations.
abstract class OrderRepository {
  /// Place one or more orders from grouped line items.
  /// [groupedItems] maps vendor name -> (vendor image URL, line items).
  /// Returns the list of created orders.
  Future<List<MarketOrder>> placeOrders({
    required Map<String, (String vendorImage, List<OrderLineItem> items)>
    groupedItems,
    required bool isPickup,
    String customerUid,
    String customerName,
    Map<String, String>? vendorNotes,
    String? deliveryAddress,
    bool isPriority = false,
    double priorityFee = 0.0,
  });

  /// All orders placed by a specific customer.
  Future<List<MarketOrder>> getOrdersForCustomer(String customerUid);

  /// All orders received by a specific vendor stall.
  Future<List<MarketOrder>> getOrdersForVendor(String stallId);

  /// Update the status of a single order.
  /// [changedByUid] is the UID of whoever triggered the change.
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? changedByUid,
    String? remarks,
    DateTime? estimatedReadyTime,
  });

  /// Cancel an order. Returns false if the cancel window has passed
  /// or the order is already terminal (completed/cancelled/rejected).
  Future<bool> cancelOrder(String orderId, {String? reason});

  /// Status change timeline for a specific order.
  Future<List<OrderStatusHistory>> getOrderHistory(String orderId);
}
