import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';

void main() {
  test('orderServiceProvider exposes the app order service', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final orders = container.read(orderServiceProvider);

    expect(orders, isA<OrderService>());
  });
}
