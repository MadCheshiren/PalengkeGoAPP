import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';

import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/core/navigation/app_routes.dart';

class FloatingOrderProgress extends ConsumerWidget {
  const FloatingOrderProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderService = ref.watch(orderServiceProvider);

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: ListenableBuilder(
        listenable: orderService,
        builder: (context, _) {
          final activeOrders = orderService.orders.where(
            (o) =>
                o.status != OrderStatus.completed &&
                o.status != OrderStatus.cancelled,
          );

          if (activeOrders.isEmpty) {
            return const SizedBox.shrink();
          }

          // For simplicity, show the first active order.
          final order = activeOrders.first;

          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.orderDetails,
                arguments: OrderDetailsRouteArgs(order: order),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B372B),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Order ${order.id}',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.statusLabel,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
