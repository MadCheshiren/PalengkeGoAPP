import 'package:flutter/material.dart';

class OrderDetailsTimeline extends StatelessWidget {
  const OrderDetailsTimeline({
    super.key,
    required this.currentStatus,
  });

  final String currentStatus;

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'label': 'Order Placed',
        'time': '10:30 AM, Oct 24',
        'status': 'completed',
      },
      {
        'label': 'Confirmed',
        'time': '10:35 AM, Oct 24',
        'status': 'completed',
      },
      {
        'label': currentStatus,
        'time': 'Vendor is weighing items',
        'status': 'active',
      },
      {'label': 'Out for Delivery', 'time': '', 'status': 'pending'},
      {'label': 'Completed', 'time': '', 'status': 'pending'},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = step['status'] == 'completed';
        final isActive = step['status'] == 'active';
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? const Color(0xFF0B372B)
                        : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : isActive
                          ? const Icon(
                              Icons.more_horiz,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? const Color(0xFF0B372B)
                        : const Color(0xFFE5E7EB),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['label']!,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isActive
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (step['time']!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      step['time']!,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isCompleted
                            ? const Color(0xFF6B7280)
                            : isActive
                                ? const Color(0xFF0B372B)
                                : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
