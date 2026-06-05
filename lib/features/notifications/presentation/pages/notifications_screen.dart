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
              delegate: _StatusBannerDelegate(unreadCount: 3),
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
          const BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
          const BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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

// Sticky Status Banner Delegate - Floating Pill morphs into Sticky Navbar
class _StatusBannerDelegate extends SliverPersistentHeaderDelegate {
  final int unreadCount;

  _StatusBannerDelegate({required this.unreadCount});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // progress: 0.0 = resting state (pill), 1.0 = fully scrolled and stuck (navbar)
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Horizontal padding: starts at 16, shrinks to 0 to touch screen edges
    final horizontalPadding = 16.0 * (1.0 - progress);

    // The layout automatically centers the 84px height pill within the available 120px height,
    // gracefully creating 18px of vertical padding at rest, morphing safely down to 0px when stuck.
    final isAllCaughtUp = unreadCount == 0;
    final bannerColor = isAllCaughtUp ? const Color(0xFF6D9773) : const Color(0xFF0B372B);

    return SizedBox.expand(
      child: Container(
        color: const Color(0xFFF8FAFC),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Container(
          height: 84.0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: bannerColor,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(
                  isAllCaughtUp ? 109 : 11,
                  isAllCaughtUp ? 151 : 55,
                  isAllCaughtUp ? 115 : 43,
                  0.3 * progress,
                ),
                blurRadius: 16 * progress,
                offset: Offset(0, 4 * progress),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAllCaughtUp ? 'STATUS UPDATE' : 'NEW NOTIFICATIONS',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xB2FFFFFF),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAllCaughtUp ? "You're all caught up!" : "$unreadCount new updates today",
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0x26FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAllCaughtUp ? Icons.check_rounded : Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 120; // Resting height

  @override
  double get minExtent => 84; // Stuck height

  @override
  bool shouldRebuild(covariant _StatusBannerDelegate oldDelegate) {
    return oldDelegate.unreadCount != unreadCount;
  }
}
