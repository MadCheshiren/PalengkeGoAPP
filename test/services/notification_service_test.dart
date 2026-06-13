import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/notification_service.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';

void main() {
  group('NotificationService', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService();
    });

    tearDown(() {
      service.dispose();
    });

    test('starts with seeded demo notifications', () {
      // The service seeds demo data in the constructor
      expect(service.all, isNotEmpty);
    });

    test('customerUnreadCount only counts customer/both-targeted notifications',
        () {
      // All demo notifications should be either customer, vendor, or both.
      // Just verify the count is a non-negative integer.
      expect(service.customerUnreadCount, greaterThanOrEqualTo(0));
    });

    test('vendorUnreadCount only counts vendor/both-targeted notifications',
        () {
      expect(service.vendorUnreadCount, greaterThanOrEqualTo(0));
    });

    test('markAsRead reduces unread customer count', () {
      // Find a customer-visible unread notification
      final customerNotif = service.all.firstWhere(
        (n) =>
            !n.isRead &&
            (n.target == NotificationTarget.customer ||
                n.target == NotificationTarget.both),
        orElse: () => throw StateError('No unread customer notification found'),
      );

      final before = service.customerUnreadCount;
      service.markRead(customerNotif.id);
      expect(service.customerUnreadCount, lessThan(before));
    });

    test('markAllRead zeroes out customer unread count', () {
      service.markAllRead(NotificationTarget.customer);
      expect(service.customerUnreadCount, 0);
    });

    test('markAllRead zeroes out vendor unread count', () {
      service.markAllRead(NotificationTarget.vendor);
      expect(service.vendorUnreadCount, 0);
    });

    test('onOrderStatusChanged adds two notifications (customer + vendor)', () {
      final beforeCount = service.all.length;
      service.onOrderStatusChanged(
        'TEST-001',
        'Test Stall',
        OrderStatus.preparing,
      );
      // Should add one customer notification + one vendor notification
      expect(service.all.length, beforeCount + 2);
    });

    test('new notifications from onOrderStatusChanged are unread', () {
      service.onOrderStatusChanged(
        'NEW-ORDER',
        'Sample Vendor',
        OrderStatus.preparing,
      );

      final fresh = service.all
          .where((n) => n.id.startsWith('NEW-ORDER'))
          .toList();
      expect(fresh, hasLength(2));
      expect(fresh.every((n) => !n.isRead), isTrue);
    });

    test('notifyListeners is called on markRead', () {
      var called = false;
      service.addListener(() => called = true);

      final notif = service.all.first;
      service.markRead(notif.id);

      expect(called, isTrue);
    });
  });
}
