import 'package:flutter/foundation.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';

/// The audience this notification is aimed at.
enum NotificationTarget { customer, vendor, both }

/// Type determines which icon / color to use in the UI.
enum NotificationType { order, stock, review, promo, admin }

/// Immutable in-app notification.
class AppNotification {
  final String id;
  final NotificationType type;
  final NotificationTarget target;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.target,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      target: target,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// In-app notification store.
/// Notifies listeners whenever notifications are added or read.
class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [
    // Seed with a few demo notifications so UI looks populated on first launch.
    AppNotification(
      id: 'seed-1',
      type: NotificationType.promo,
      target: NotificationTarget.customer,
      title: 'Organic Week!',
      body: '20% off on all leafy greens across the market. Valid until Sunday.',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    AppNotification(
      id: 'seed-2',
      type: NotificationType.promo,
      target: NotificationTarget.customer,
      title: 'Flash Sale on Seafood 🐟',
      body: '50% off on all seafood until 6 PM today. Stocks limited!',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AppNotification(
      id: 'seed-v1',
      type: NotificationType.review,
      target: NotificationTarget.vendor,
      title: 'New 5-Star Rating!',
      body:
          'Ricardo D. left a review: "Super fresh tilapia and fast preparation. Will buy again!"',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'seed-v2',
      type: NotificationType.admin,
      target: NotificationTarget.vendor,
      title: 'Market Maintenance Notice',
      body:
          'The Wet Market section will undergo sanitization this Sunday from 8 PM to 11 PM.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  /// All notifications, newest-first.
  List<AppNotification> get all {
    final sorted = List<AppNotification>.from(_notifications);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  /// Notifications visible to the customer.
  List<AppNotification> get forCustomer => all
      .where((n) =>
          n.target == NotificationTarget.customer ||
          n.target == NotificationTarget.both)
      .toList();

  /// Notifications visible to the vendor.
  List<AppNotification> get forVendor => all
      .where((n) =>
          n.target == NotificationTarget.vendor ||
          n.target == NotificationTarget.both)
      .toList();

  int get customerUnreadCount => forCustomer.where((n) => !n.isRead).length;
  int get vendorUnreadCount => forVendor.where((n) => !n.isRead).length;

  /// Push a new notification into the list.
  void addNotification(AppNotification notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  /// Mark a single notification as read.
  void markRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read (for the given target audience).
  void markAllRead(NotificationTarget target) {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      final matches =
          n.target == target || n.target == NotificationTarget.both;
      if (matches && !n.isRead) {
        _notifications[i] = n.copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Called by OrderService when a vendor changes an order's status.
  /// Creates the right notification for both customer and vendor.
  void onOrderStatusChanged(
    String orderId,
    String vendorName,
    OrderStatus newStatus,
  ) {
    String? customerTitle;
    String? customerBody;
    String? vendorTitle;
    String? vendorBody;

    switch (newStatus) {
      case OrderStatus.preparing:
        customerTitle = 'Order $orderId is being prepared!';
        customerBody = '$vendorName has started preparing your order.';
        vendorTitle = 'You accepted order $orderId';
        vendorBody = 'Order from $vendorName is now in preparation.';
        break;
      case OrderStatus.ready:
        customerTitle = 'Order $orderId is ready! 🎉';
        customerBody =
            'Your order from $vendorName is ready for pick-up or awaiting rider.';
        break;
      case OrderStatus.completed:
        customerTitle = 'Order $orderId completed ✅';
        customerBody =
            'Your order from $vendorName has been completed. Thanks for shopping!';
        vendorTitle = 'Order $orderId marked complete';
        vendorBody = 'Earnings from this order will be reflected shortly.';
        break;
      case OrderStatus.cancelled:
        customerTitle = 'Order $orderId was cancelled';
        customerBody =
            'Your order from $vendorName was cancelled. Contact support if this is a mistake.';
        vendorTitle = 'Order $orderId cancelled';
        vendorBody = 'The order has been cancelled.';
        break;
      default:
        break;
    }

    final now = DateTime.now();

    if (customerTitle != null) {
      addNotification(AppNotification(
        id: '${orderId}_${newStatus.name}_cust_${now.millisecondsSinceEpoch}',
        type: NotificationType.order,
        target: NotificationTarget.customer,
        title: customerTitle,
        body: customerBody ?? '',
        createdAt: now,
      ));
    }

    if (vendorTitle != null) {
      addNotification(AppNotification(
        id: '${orderId}_${newStatus.name}_vend_${now.millisecondsSinceEpoch}',
        type: NotificationType.order,
        target: NotificationTarget.vendor,
        title: vendorTitle,
        body: vendorBody ?? '',
        createdAt: now,
      ));
    }
  }
}
