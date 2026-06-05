import 'package:flutter/material.dart';

class VendorNotificationsScreen extends StatefulWidget {
  const VendorNotificationsScreen({super.key});

  @override
  State<VendorNotificationsScreen> createState() => _VendorNotificationsScreenState();
}

class _VendorNotificationsScreenState extends State<VendorNotificationsScreen> {
  // Mock notifications list to allow items to be dismissed or updated
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'notif-1',
      'type': 'order',
      'title': 'New Order Received!',
      'description': 'Order #RG-1030 from Maria Santos is ready for preparation (2kg Bangus).',
      'time': 'Just now',
      'isRead': false,
      'primaryAction': 'Start Preparing',
    },
    {
      'id': 'notif-2',
      'type': 'stock',
      'title': 'Low Stock Alert!',
      'description': 'Your Tilapia inventory is currently at 3kg (Critical threshold: 5kg).',
      'time': '10 mins ago',
      'isRead': false,
      'primaryAction': 'Restock Now',
    },
    {
      'id': 'notif-3',
      'type': 'review',
      'title': 'New 5-Star Rating!',
      'description': 'Ricardo D. left a review: "Super fresh tilapia and fast preparation. Will buy again!"',
      'time': '2 hours ago',
      'isRead': true,
      'primaryAction': 'Thank Customer',
      'rating': 5,
    },
    {
      'id': 'notif-4',
      'type': 'admin',
      'title': 'Market Maintenance Notice',
      'description': 'The Wet Market section will undergo sanitization this Sunday, May 31, from 8:00 PM to 11:00 PM.',
      'time': 'Yesterday',
      'isRead': true,
      'primaryAction': 'Acknowledge',
    },
  ];

  void _handleAction(String id, String action, String title) {
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // Simulate updating notification state
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0B372B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Success: $action for "$title"',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0B372B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text(
          'All notifications marked as read',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Standard Premium Header with Back Button and Mark All Read
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
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
                    if (unreadCount > 0)
                      GestureDetector(
                        onTap: _markAllAsRead,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B372B),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Morphing Sticky Header showing priority vendor breakdown
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: _VendorStatusBannerDelegate(unreadCount: unreadCount),
            ),

            // Tailored List of Vendor Notification Cards
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  
                  // Today Section
                  _buildSectionHeader('OPERATIONAL ALERTS'),
                  const SizedBox(height: 12),
                  
                  ..._notifications.map((notif) {
                    return _buildVendorNotificationCard(notif);
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Security / Tips box for vendors
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFF0369A1),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vendor Pro-Tip',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0369A1),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Keeping your inventory updated reduces order cancellations and builds buyer trust. Try editing your stock levels immediately after a low-stock alert!',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF075985),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
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
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildVendorNotificationCard(Map<String, dynamic> notif) {
    final String type = notif['type'];
    final String id = notif['id'];
    final String title = notif['title'];
    final String description = notif['description'];
    final String time = notif['time'];
    final bool isRead = notif['isRead'];
    final String primaryAction = notif['primaryAction'];
    
    IconData icon;
    Color accentColor;
    Color bgColor;

    switch (type) {
      case 'order':
        icon = Icons.receipt_long_rounded;
        accentColor = const Color(0xFF22C55E); // Green
        bgColor = const Color(0xFFF0FDF4);
        break;
      case 'stock':
        icon = Icons.inventory_2_outlined;
        accentColor = const Color(0xFFEF4444); // Red/Amber
        bgColor = const Color(0xFFFEF2F2);
        break;
      case 'review':
        icon = Icons.star_rate_rounded;
        accentColor = const Color(0xFFF59E0B); // Amber/Gold
        bgColor = const Color(0xFFFEF3C7);
        break;
      case 'admin':
      default:
        icon = Icons.campaign_rounded;
        accentColor = const Color(0xFF3B82F6); // Blue
        bgColor = const Color(0xFFEFF6FF);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isRead ? const Color(0xFFE2E8F0) : accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isRead ? const Color(0xFFCBD5E1) : accentColor,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: accentColor, size: 20),
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
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isRead ? const Color(0xFF475569) : const Color(0xFF0F172A),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleAction(id, primaryAction, title),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isRead ? const Color(0xFFF1F5F9) : accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        primaryAction,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isRead ? const Color(0xFF64748B) : accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorStatusBannerDelegate extends SliverPersistentHeaderDelegate {
  _VendorStatusBannerDelegate({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Horizontal padding: starts at 16, shrinks to 0 to touch screen edges
    final horizontalPadding = 16.0 * (1.0 - progress);

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
                      isAllCaughtUp ? 'STALL OPERATIONAL STATUS' : 'URGENT NOTIFICATIONS',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xB2FFFFFF),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAllCaughtUp 
                          ? "All alerts cleared! Nice job." 
                          : "$unreadCount critical tasks require attention",
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
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
  bool shouldRebuild(covariant _VendorStatusBannerDelegate oldDelegate) {
    return oldDelegate.unreadCount != unreadCount;
  }
}
