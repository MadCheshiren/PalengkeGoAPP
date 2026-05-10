import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header - scrolls away
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Status Banner with shrink effect
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: _StatusBannerDelegate(),
            ),

            // Notifications List with padding
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                    // TODAY Section
                    _buildSectionHeader('TODAY'),
                    const SizedBox(height: 12),
                    _buildNotificationCard(
                      icon: Icons.inventory_2_outlined,
                      iconBgColor: const Color(0xFF0B372B),
                      title: 'Order #1029 is ready!',
                      description: 'Your fresh harvest from Juan\'s Stall is ready for pick-up at the North Wing.',
                      time: '2 mins ago',
                      hasUnreadIndicator: true,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCard(
                      icon: Icons.storefront_outlined,
                      iconBgColor: const Color(0xFF6D9773),
                      title: 'Fresh Arrivals!',
                      description: 'New catch just arrived at Juan\'s Fresh Catch. Get \'em while they\'re cold!',
                      time: '1 hour ago',
                      hasUnreadIndicator: true,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCard(
                      icon: Icons.local_shipping_outlined,
                      iconBgColor: const Color(0xFFF59E0B),
                      title: 'Order Out for Delivery',
                      description: 'Your order #1027 is on the way. Estimated arrival in 15 mins.',
                      time: '3 hours ago',
                      hasUnreadIndicator: true,
                    ),

                    const SizedBox(height: 24),

                    // YESTERDAY Section
                    _buildSectionHeader('YESTERDAY'),
                    const SizedBox(height: 12),
                    _buildNotificationCard(
                      icon: Icons.check_circle_outline,
                      iconBgColor: const Color(0xFF9CA3AF),
                      title: 'Order Delivered',
                      description: 'Order #0988 has been successfully delivered to your location.',
                      time: 'Yesterday, 4:30 PM',
                      hasUnreadIndicator: false,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCard(
                      icon: Icons.payment_outlined,
                      iconBgColor: const Color(0xFF059669),
                      title: 'Payment Confirmed',
                      description: 'Your payment of ₱540.00 for Order #0988 has been confirmed.',
                      time: 'Yesterday, 2:15 PM',
                      hasUnreadIndicator: false,
                    ),

                    const SizedBox(height: 24),

                    // EARLIER Section
                    _buildSectionHeader('EARLIER'),
                    const SizedBox(height: 12),
                    _buildPromoCard(
                      icon: Icons.local_offer_outlined,
                      title: 'Organic Week',
                      description: '20% off on all leafy greens across the market.',
                      label: 'PROMO',
                    ),
                    const SizedBox(height: 12),
                    _buildPromoCard(
                      icon: Icons.celebration_outlined,
                      title: 'Flash Sale!',
                      description: '50% off on all seafood until 6 PM today!',
                      label: 'SALE',
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCard(
                      icon: Icons.receipt_outlined,
                      iconBgColor: const Color(0xFF6B7280),
                      title: 'Order Completed',
                      description: 'Order #0980 has been completed. Rate your experience!',
                      time: '3 days ago',
                      hasUnreadIndicator: false,
                    ),
                    const SizedBox(height: 12),
                    _buildNotificationCard(
                      icon: Icons.person_add_outlined,
                      iconBgColor: const Color(0xFF3B82F6),
                      title: 'Referral Bonus',
                      description: 'You earned ₱50 credit! Your friend made their first purchase.',
                      time: '1 week ago',
                      hasUnreadIndicator: false,
                    ),

                    const SizedBox(height: 40),
                ]),
              ),
            ),
            // Bottom padding for safe area
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9CA3AF),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String description,
    required String time,
    required bool hasUnreadIndicator,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: hasUnreadIndicator
            ? const Border(
                left: BorderSide(
                  color: Color(0xFFFFB902),
                  width: 4,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (hasUnreadIndicator)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFB902),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required IconData icon,
    required String title,
    required String description,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0xFF059669),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sticky Status Banner Delegate - EXPANDS when scrolling down
class _StatusBannerDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Expand progress: 0 = compact (at top), 1 = fully expanded (scrolled down)
    final expandProgress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Interpolate horizontal margins: compact has 48px margin, expanded fills width
    final horizontalMargin = 48.0 * (1.0 - expandProgress);

    // Interpolate border radius: compact = 24px (pill-like), expanded = 0 (full width)
    final borderRadius = 24.0 * (1.0 - expandProgress);

    // Height grows as it expands
    final height = 80.0 + (40.0 * expandProgress);

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.fromLTRB(
        16 + horizontalMargin,
        8,
        16 + horizontalMargin,
        12,
      ),
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: height,
        padding: EdgeInsets.lerp(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          expandProgress,
        )!,
        decoration: BoxDecoration(
          color: const Color(0xFF0B372B),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'STATUS UPDATE',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "You're all caught up!",
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            // Subtitle fades in when expanded
            Opacity(
              opacity: expandProgress,
              child: Text(
                '3 new updates today.',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 160; // Expanded height (when scrolled down)

  @override
  double get minExtent => 110; // Compact height (at top)

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
