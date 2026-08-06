import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/infrastructure/firebase_service.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/orders/data/firebase_order_repository.dart';
import 'package:palengkego/features/orders/data/mock_order_repository.dart';
import 'package:palengkego/features/orders/domain/order_repository.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final firebaseEnabled = ref.watch(firebaseEnabledProvider);
  if (firebaseEnabled) {
    final firestore = ref.watch(firestoreProvider);
    return FirebaseOrderRepository(firestore);
  }
  return MockOrderRepository();
});

/// Global OrderService Notifier provider.
final orderServiceProvider =
    AsyncNotifierProvider<OrderService, List<MarketOrder>>(OrderService.new);

final completedOrdersProvider = Provider<AsyncValue<List<MarketOrder>>>((ref) {
  return ref.watch(orderServiceProvider).whenData((orders) {
    return orders.where((o) => o.status == OrderStatus.completed).toList();
  });
});
