import 'package:palengkego/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Empty state for the market: no stalls (browse mode) or no search results.
class MarketEmptyState extends StatelessWidget {
  final String query;

  const MarketEmptyState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppTheme.accentGreen,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'No stalls available' : 'No results for "$query"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different stall name, product, or category.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
