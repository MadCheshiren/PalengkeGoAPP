import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/notifications/application/notification_provider.dart';

/// Global OrderService singleton.
/// Wires the notification callback so vendor status changes
/// automatically produce in-app notifications for both sides.
final orderServiceProvider = Provider<OrderService>((ref) {
  final notifService = ref.read(notificationServiceProvider);
  final service = OrderService()
    ..onStatusChanged = notifService.onOrderStatusChanged;
  ref.onDispose(service.dispose);
  return service;
});
