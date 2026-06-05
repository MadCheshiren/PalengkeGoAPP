import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return globalOrders;
});
