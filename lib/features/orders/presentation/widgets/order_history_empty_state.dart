import 'package:flutter/material.dart';
import 'order_history_tab_row.dart';

class OrderHistoryEmptyState extends StatelessWidget {
  final OrderTab currentTab;

  const OrderHistoryEmptyState({
    super.key,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F5F3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 34,
              color: Color(0xFF9AB4AA),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No ${currentTab.label.toLowerCase()} orders yet',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF35554A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Placed orders will show up here automatically.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9AB4AA),
            ),
          ),
        ],
      ),
    );
  }
}
