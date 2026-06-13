import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/services/notification_service.dart';

/// Global singleton for NotificationService.
/// Riverpod v3 does not have ChangeNotifierProvider — widgets that need to
/// react to internal mutations should wrap reads in [ListenableBuilder].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(service.dispose);
  return service;
});
