import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palengkego/core/config/fee_config.dart';
import 'package:palengkego/features/orders/domain/fulfillment_method.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_line_item.dart';
import 'package:palengkego/features/orders/domain/order_repository.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/domain/order_status_history.dart';
import 'package:palengkego/features/orders/domain/payment_status.dart';

/// Firestore implementation of [OrderRepository].
///
/// Collections:
///   `orders/{orderId}`
///   `orders/{orderId}/statusHistory/{historyId}`
class FirebaseOrderRepository implements OrderRepository {
  FirebaseOrderRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const _cancelWindow = FeeConfig.cancelWindow;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  // ── Place orders ────────────────────────────────────────────────────────────

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
    // Pre-fetch stallIds
    final vendorStallIds = <String, String>{};
    for (final vendorName in groupedItems.keys) {
      try {
        final stallSnap = await _firestore
            .collection('vendorStalls')
            .where('name', isEqualTo: vendorName)
            .limit(1)
            .get();
        if (stallSnap.docs.isNotEmpty) {
          vendorStallIds[vendorName] = stallSnap.docs.first.id;
        }
      } catch (e) {
        // Fallback
      }
    }

    final created = <MarketOrder>[];

    await _firestore.runTransaction((transaction) async {
      for (final entry in groupedItems.entries) {
        final ref = _orders.doc();
        final orderId = ref.id;
        final vendorName = entry.key;
        final vendorImage = entry.value.$1;
        final lineItems = entry.value.$2;

        final order = MarketOrder(
          id: orderId,
          vendorName: vendorName,
          vendorImage: vendorImage,
          customerName: customerName,
          status: OrderStatus.pending,
          paymentStatus: PaymentStatus.pending,
          fulfillmentMethod: isPickup
              ? FulfillmentMethod.pickup
              : FulfillmentMethod.delivery,
          deliveryAddress: isPickup ? null : (deliveryAddress ?? ''),
          deliveryFee: isPickup ? 0.0 : FeeConfig.deliveryFee,
          serviceFee: FeeConfig.serviceFee,
          isPriority: isPickup ? false : isPriority,
          priorityFee: isPickup ? 0.0 : priorityFee,
          placedAt: now,
          notes: vendorNotes?[vendorName],
          items: lineItems,
        );

        final stallId = vendorStallIds[entry.key];

        // Deduct stock
        if (stallId != null) {
          for (final item in order.items) {
            if (!item.productId.startsWith('dummy') &&
                !item.productId.startsWith('recipe_')) {
              final productRef = _firestore
                  .collection('vendorStalls')
                  .doc(stallId)
                  .collection('products')
                  .doc(item.productId);

              final productDoc = await transaction.get(productRef);
              if (productDoc.exists) {
                final currentStock =
                    (productDoc.data()?['stockQuantity'] as num?)?.toInt() ?? 0;
                final qty = item.quantity.ceil();
                final newStock = (currentStock - qty).clamp(0, 999999);

                final updates = <String, dynamic>{'stockQuantity': newStock};
                if (newStock <= 0) {
                  updates['isActive'] = false;
                }

                transaction.update(productRef, updates);
              }
            }
          }
        }

        transaction.set(
          ref,
          _toFirestore(order, customerUid: customerUid, stallId: stallId),
        );

        // Initial status history entry.
        final histRef = ref.collection('statusHistory').doc();
        transaction.set(histRef, {
          'orderId': orderId,
          'previousStatus': null,
          'newStatus': OrderStatus.pending.name,
          'changedBy': customerUid,
          'changedAt': FieldValue.serverTimestamp(),
          'remarks': null,
        });

        created.add(order);
      }
    });

    return created;
  }

  // ── Queries ─────────────────────────────────────────────────────────────────

  @override
  Future<List<MarketOrder>> getOrdersForCustomer(String customerUid) async {
    final snap = await _orders
        .where('customerUid', isEqualTo: customerUid)
        .orderBy('placedAt', descending: true)
        .get();
    return snap.docs.map((d) => _fromFirestore(d.id, d.data())).toList();
  }

  @override
  Future<List<MarketOrder>> getOrdersForVendor(String stallId) async {
    final snap = await _orders
        .where('stallId', isEqualTo: stallId)
        .orderBy('placedAt', descending: true)
        .get();
    return snap.docs.map((d) => _fromFirestore(d.id, d.data())).toList();
  }

  // ── Status update ───────────────────────────────────────────────────────────

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? changedByUid,
    String? remarks,
    DateTime? estimatedReadyTime,
  }) async {
    final ref = _orders.doc(orderId);
    final snap = await ref.get();
    if (!snap.exists) return;

    final previous = OrderStatus.values.firstWhere(
      (s) => s.name == (snap.data()!['status'] as String? ?? 'pending'),
      orElse: () => OrderStatus.pending,
    );

    await ref.update({
      'status': newStatus.name,
      if (newStatus == OrderStatus.completed)
        'paymentStatus': PaymentStatus.paid.name,
      'updatedAt': FieldValue.serverTimestamp(),
      if (estimatedReadyTime != null)
        'estimatedReadyTime': estimatedReadyTime.toIso8601String(),
      if (newStatus == OrderStatus.cancelled ||
          newStatus == OrderStatus.rejected)
        'cancellationReason': remarks,
    });

    await ref.collection('statusHistory').add({
      'orderId': orderId,
      'previousStatus': previous.name,
      'newStatus': newStatus.name,
      'changedBy': changedByUid ?? 'system',
      'changedAt': FieldValue.serverTimestamp(),
      'remarks': remarks,
    });
  }

  // ── Cancel ──────────────────────────────────────────────────────────────────

  @override
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    final snap = await _orders.doc(orderId).get();
    if (!snap.exists) return false;

    final data = snap.data()!;
    final status = OrderStatus.values.firstWhere(
      (s) => s.name == (data['status'] as String? ?? 'pending'),
      orElse: () => OrderStatus.pending,
    );

    if (status != OrderStatus.pending) return false;

    final placedAt = (data['placedAt'] as Timestamp).toDate();
    if (DateTime.now().isAfter(placedAt.add(_cancelWindow))) return false;

    await updateOrderStatus(
      orderId,
      OrderStatus.cancelled,
      changedByUid: 'customer',
      remarks: reason,
    );
    return true;
  }

  // ── History ─────────────────────────────────────────────────────────────────

  @override
  Future<List<OrderStatusHistory>> getOrderHistory(String orderId) async {
    final snap = await _orders
        .doc(orderId)
        .collection('statusHistory')
        .orderBy('changedAt')
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return OrderStatusHistory(
        historyId: d.id,
        orderId: orderId,
        previousStatus: data['previousStatus'] != null
            ? OrderStatus.values.firstWhere(
                (s) => s.name == data['previousStatus'],
                orElse: () => OrderStatus.pending,
              )
            : null,
        newStatus: OrderStatus.values.firstWhere(
          (s) => s.name == (data['newStatus'] as String? ?? 'pending'),
          orElse: () => OrderStatus.pending,
        ),
        changedBy: data['changedBy'] as String? ?? '',
        changedAt:
            (data['changedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        remarks: data['remarks'] as String?,
      );
    }).toList();
  }

  // ── Serialization ───────────────────────────────────────────────────────────

  Map<String, dynamic> _toFirestore(
    MarketOrder o, {
    String customerUid = '',
    String? stallId,
  }) {
    return {
      'customerUid': customerUid,
      'stallId': stallId,
      'vendorName': o.vendorName,
      'vendorImage': o.vendorImage,
      'customerName': o.customerName,
      'status': o.status.name,
      'paymentStatus': o.paymentStatus.name,
      'fulfillmentMethod': o.fulfillmentMethod.name,
      'deliveryAddress': o.deliveryAddress,
      'deliveryFee': o.deliveryFee,
      'serviceFee': o.serviceFee,
      'isPriority': o.isPriority,
      'priorityFee': o.priorityFee,
      'notes': o.notes,
      'placedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'estimatedReadyTime': o.estimatedReadyTime?.toIso8601String(),
      'cancellationReason': o.cancellationReason,
      'items': o.items
          .map(
            (i) => {
              'productId': i.productId,
              'productName': i.productName,
              'quantity': i.quantity,
              'unitPrice': i.unitPrice,
              'unit': i.unit,
              'image': i.image,
            },
          )
          .toList(),
    };
  }

  MarketOrder _fromFirestore(String id, Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>? ?? [])
        .map(
          (i) => OrderLineItem(
            productId: i['productId'] as String? ?? 'dummy',
            productName: i['productName'] as String? ?? '',
            quantity: (i['quantity'] as num?)?.toDouble() ?? 1,
            unitPrice: (i['unitPrice'] as num?)?.toDouble() ?? 0,
            unit: i['unit'] as String? ?? '',
            image: i['image'] as String? ?? '',
          ),
        )
        .toList();

    return MarketOrder(
      id: id,
      vendorName: data['vendorName'] as String? ?? '',
      vendorImage: data['vendorImage'] as String? ?? '',
      customerName: data['customerName'] as String? ?? 'Customer',
      status: OrderStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (s) => s.name == (data['paymentStatus'] as String? ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      fulfillmentMethod: FulfillmentMethod.values.firstWhere(
        (f) => f.name == (data['fulfillmentMethod'] as String? ?? 'pickup'),
        orElse: () => FulfillmentMethod.pickup,
      ),
      deliveryAddress: data['deliveryAddress'] as String?,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0,
      serviceFee: (data['serviceFee'] as num?)?.toDouble() ?? 0,
      isPriority: data['isPriority'] as bool? ?? false,
      priorityFee: (data['priorityFee'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'] as String?,
      placedAt: (data['placedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedReadyTime: data['estimatedReadyTime'] != null
          ? DateTime.tryParse(data['estimatedReadyTime'] as String)
          : null,
      cancellationReason: data['cancellationReason'] as String?,
      items: items,
    );
  }
}
