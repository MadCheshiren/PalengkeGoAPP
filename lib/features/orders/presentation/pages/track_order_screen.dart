import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/widgets/app_bottom_nav_bar.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';
import 'package:palengkego/features/orders/presentation/widgets/tracking_contact_cards.dart';
import 'package:palengkego/features/orders/presentation/widgets/tracking_map_preview.dart';

/// Track Order Screen
/// Shows order progress with map view.
/// 
/// TODO: Google Maps Integration
/// - Add google_maps_flutter package to pubspec.yaml
/// - Get API key from Google Cloud Console (Maps SDK for Android/iOS)
/// - Add API key to AndroidManifest.xml and AppDelegate.swift
/// - Replace _MapPlaceholder with actual GoogleMap widget
/// - Implement route polyline drawing between user and vendor/rider
/// - Add custom markers for user location, vendor, and rider
///
/// For Delivery: Show rider location in real-time (requires Firebase/WebSocket)
/// For Pick-up: Show static route from user to vendor stall
class TrackOrderScreen extends ConsumerWidget {
  final MarketOrder order;
  final bool isPickup;

  const TrackOrderScreen({
    super.key,
    required this.order,
    required this.isPickup,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderService = ref.watch(orderServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: orderService,
          builder: (context, _) {
            // Find the latest order state, or fallback to the initial one
            final currentOrder = orderService.orders.firstWhere(
              (o) => o.id == order.id,
              orElse: () => order,
            );
            
            return Column(
              children: [
                // Header
                _buildHeader(context),
                
                // Map Area - Replace with Google Maps
                TrackingMapPreview(isPickup: isPickup),
                
                // Order Info Card
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vendor Info
                          _buildVendorInfo(currentOrder),
                          const SizedBox(height: 20),
                          
                          // Order Progress Timeline
                          _buildOrderProgress(currentOrder),
                          const SizedBox(height: 20),
                          
                          // Pick-up Verification OR Delivery Rider Info
                          if (isPickup)
                            const PickupVerificationCard()
                          else
                            const RiderInfoCard(),
                          
                          // Contact Stall Owner button (pickup only)
                          if (isPickup) ...[
                            const SizedBox(height: 20),
                            _buildContactStallButton(context),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 2, // Orders tab
        onTap: (index) => navigateToMainTab(context, index),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Always navigate to Orders tab, don't just pop
              navigateToMainTab(context, 1);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFF6F8F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF0B372B),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Track Order',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildVendorInfo(MarketOrder currentOrder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=100&h=100&fit=crop',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 56,
                height: 56,
                color: const Color(0xFFE5E7EB),
                child: const Icon(Icons.storefront_outlined, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentOrder.vendorName,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPickup 
                    ? 'Stall 12 • Pasig Public Market'
                    : 'Order #${currentOrder.id}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Processing badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'PROCESSING',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF166534),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProgress(MarketOrder currentOrder) {
    final steps = isPickup
      ? [
          _ProgressStep(
            title: 'Order Confirmed',
            subtitle: 'Today, 10:45 AM • Payment Received',
            isCompleted: true,
            isActive: currentOrder.status == OrderStatus.confirmed,
            icon: Icons.check_circle,
          ),
          _ProgressStep(
            title: 'Preparing',
            subtitle: '10:52 AM • Merchant is packing your items',
            isCompleted: currentOrder.status == OrderStatus.preparing || currentOrder.status == OrderStatus.ready || currentOrder.status == OrderStatus.completed,
            isActive: currentOrder.status == OrderStatus.preparing,
            icon: Icons.storefront,
          ),
          _ProgressStep(
            title: 'Ready for Pick-Up',
            subtitle: 'Head to Stall 12 now',
            isCompleted: currentOrder.status == OrderStatus.completed,
            isActive: currentOrder.status == OrderStatus.ready,
            icon: Icons.shopping_bag,
          ),
        ]
      : [
          _ProgressStep(
            title: 'Order Confirmed',
            subtitle: 'Today, 10:45 AM',
            isCompleted: true,
            isActive: currentOrder.status == OrderStatus.confirmed,
            icon: Icons.check_circle,
          ),
          _ProgressStep(
            title: 'Preparing your Basket',
            subtitle: 'Lola is picking the freshest items',
            isCompleted: currentOrder.status == OrderStatus.preparing || currentOrder.status == OrderStatus.ready || currentOrder.status == OrderStatus.completed,
            isActive: currentOrder.status == OrderStatus.preparing,
            icon: Icons.shopping_basket,
          ),
          _ProgressStep(
            title: 'Out for Delivery',
            subtitle: 'Rider is heading your way',
            isCompleted: currentOrder.status == OrderStatus.completed,
            isActive: currentOrder.status == OrderStatus.ready,
            icon: Icons.delivery_dining,
          ),
          _ProgressStep(
            title: 'Arrived',
            subtitle: 'Enjoy your market-fresh items!',
            isCompleted: currentOrder.status == OrderStatus.completed,
            isActive: currentOrder.status == OrderStatus.completed,
            icon: Icons.home,
          ),
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Progress',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: step.isCompleted || step.isActive
                        ? const Color(0xFF0B372B)
                        : const Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step.isCompleted ? Icons.check : step.icon,
                      size: 16,
                      color: step.isCompleted || step.isActive
                        ? Colors.white
                        : const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: step.isCompleted
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
                      step.title,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: step.isActive || step.isCompleted
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: step.isActive || step.isCompleted
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildContactStallButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement chat/call with stall owner
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact Stall Owner - Coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF0B372B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.chat_bubble_outline,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Contact Stall Owner',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress step data class
class _ProgressStep {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final IconData icon;

  _ProgressStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
    required this.icon,
  });
}

