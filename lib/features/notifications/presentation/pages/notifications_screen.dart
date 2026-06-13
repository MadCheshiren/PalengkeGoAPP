import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/services/notification_service.dart';
import 'package:palengkego/features/notifications/application/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifService = ref.watch(notificationServiceProvider);

    return ListenableBuilder(
      listenable: notifService,
      builder: (context, _) {
        final notifications = notifService.forCustomer;
        final unreadCount = notifService.customerUnreadCount;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                        if (unreadCount > 0)
                          GestureDetector(
                            onTap: () => notifService
                                .markAllRead(NotificationTarget.customer),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
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

                // Sticky status banner
                SliverPersistentHeader(
                  pinned: true,
                  floating: false,
                  delegate: _StatusBannerDelegate(unreadCount: unreadCount),
                ),

                // Notification list
                if (notifications.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyNotifications(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final notif = notifications[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _NotificationCard(
                              notification: notif,
                              onTap: () => notifService.markRead(notif.id),
                            ),
                          );
                        },
                        childCount: notifications.length,
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 32,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF0B372B),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You're all caught up!",
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B372B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'New order updates will appear here.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notification card
// ---------------------------------------------------------------------------
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final config = _typeConfig(notification.type);
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isRead
              ? null
              : const Border(
                  left: BorderSide(color: Color(0xFFFFB902), width: 4)),
          boxShadow: const [
            BoxShadow(
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
                color: config.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(config.icon, size: 24, color: config.iconColor),
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
                          notification.title,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isRead
                                ? const Color(0xFF475569)
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (!isRead)
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
                    notification.body,
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
                    _relativeTime(notification.createdAt),
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
      ),
    );
  }

  ({IconData icon, Color iconColor, Color bgColor}) _typeConfig(
    NotificationType type,
  ) {
    return switch (type) {
      NotificationType.order => (
          icon: Icons.inventory_2_outlined,
          iconColor: Colors.white,
          bgColor: const Color(0xFF0B372B),
        ),
      NotificationType.promo => (
          icon: Icons.local_offer_outlined,
          iconColor: const Color(0xFF059669),
          bgColor: const Color(0xFFECFDF5),
        ),
      NotificationType.review => (
          icon: Icons.star_rate_rounded,
          iconColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFEF3C7),
        ),
      NotificationType.stock => (
          icon: Icons.inventory_2_outlined,
          iconColor: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEF2F2),
        ),
      NotificationType.admin => (
          icon: Icons.campaign_rounded,
          iconColor: const Color(0xFF3B82F6),
          bgColor: const Color(0xFFEFF6FF),
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Relative time helper
// ---------------------------------------------------------------------------
String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return '${diff.inDays ~/ 7} week${diff.inDays ~/ 7 > 1 ? 's' : ''} ago';
}

// ---------------------------------------------------------------------------
// Sticky status banner (unchanged visual logic, now data-driven)
// ---------------------------------------------------------------------------
class _StatusBannerDelegate extends SliverPersistentHeaderDelegate {
  final int unreadCount;
  _StatusBannerDelegate({required this.unreadCount});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final horizontalPadding = 16.0 * (1.0 - progress);
    final isAllCaughtUp = unreadCount == 0;
    final bannerColor = isAllCaughtUp
        ? const Color(0xFF6D9773)
        : const Color(0xFF0B372B);

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
                      isAllCaughtUp
                          ? "You're all caught up!"
                          : '$unreadCount new updates today',
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
                  isAllCaughtUp
                      ? Icons.check_rounded
                      : Icons.notifications_active_rounded,
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
  double get maxExtent => 120;

  @override
  double get minExtent => 84;

  @override
  bool shouldRebuild(covariant _StatusBannerDelegate oldDelegate) {
    return oldDelegate.unreadCount != unreadCount;
  }
}
