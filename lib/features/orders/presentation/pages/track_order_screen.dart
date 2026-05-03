import 'package:flutter/material.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/core/widgets/app_bottom_nav_bar.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';

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
class TrackOrderScreen extends StatelessWidget {
  final MarketOrder order;
  final bool isPickup;

  const TrackOrderScreen({
    super.key,
    required this.order,
    required this.isPickup,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Map Area - Replace with Google Maps
            _buildMapArea(),
            
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
                      _buildVendorInfo(),
                      const SizedBox(height: 20),
                      
                      // Order Progress Timeline
                      _buildOrderProgress(),
                      const SizedBox(height: 20),
                      
                      // Pick-up Verification OR Delivery Rider Info
                      if (isPickup)
                        _buildPickupVerification()
                      else
                        _buildRiderInfo(),
                      
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
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 1, // Orders tab
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

  /// TODO: Replace with Google Maps implementation
  /// 
  /// Implementation steps:
  /// 1. Add to pubspec.yaml:
  ///    google_maps_flutter: ^2.5.0
  ///    flutter_polyline_points: ^2.0.0 (for route drawing)
  ///
  /// 2. Get API key:
  ///    - Go to Google Cloud Console
  ///    - Enable Maps SDK for Android & iOS
  ///    - Create API key with restrictions
  ///
  /// 3. Android setup:
  ///    - Add to android/app/src/main/AndroidManifest.xml:
  ///      <meta-data android:name="com.google.android.geo.API_KEY"
  ///                 android:value="YOUR_API_KEY"/>
  ///
  /// 4. iOS setup:
  ///    - Add to ios/Runner/AppDelegate.swift:
  ///      GMSServices.provideAPIKey("YOUR_API_KEY")
  ///
  /// 5. Replace this placeholder with:
  ///    GoogleMap(
  ///      mapType: MapType.normal,
  ///      initialCameraPosition: CameraPosition(
  ///        target: _getMapCenter(),
  ///        zoom: 15,
  ///      ),
  ///      markers: _buildMarkers(),
  ///      polylines: _buildRoutePolyline(),
  ///      myLocationEnabled: true,
  ///      myLocationButtonEnabled: false,
  ///    )
  Widget _buildMapArea() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Placeholder map background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD9FBE6), Color(0xFFE9F7EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CustomPaint(
                painter: _MapGridPainter(),
                child: const SizedBox.expand(),
              ),
            ),
            
            // Arrival time badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED ARRIVAL',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPickup ? '8 mins' : '12-18 mins',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Distance badge (delivery only)
            if (!isPickup)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'DISTANCE',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '2.4 km',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Center pin
            const Center(
              child: Icon(
                Icons.location_on,
                size: 48,
                color: Color(0xFF0B372B),
              ),
            ),
            
            // Stall badge (pickup only)
            if (isPickup)
              Positioned(
                top: 100,
                right: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B372B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'STALL 12',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
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
                  order.vendorName,
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
                    : 'Order #${order.id}',
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

  Widget _buildOrderProgress() {
    final steps = isPickup
      ? [
          _ProgressStep(
            title: 'Order Confirmed',
            subtitle: 'Today, 10:45 AM • Payment Received',
            isCompleted: true,
            isActive: false,
            icon: Icons.check_circle,
          ),
          _ProgressStep(
            title: 'Preparing',
            subtitle: '10:52 AM • Merchant is packing your items',
            isCompleted: true,
            isActive: false,
            icon: Icons.storefront,
          ),
          _ProgressStep(
            title: 'Ready for Pick-Up',
            subtitle: 'Head to Stall 12 now',
            isCompleted: false,
            isActive: true,
            icon: Icons.shopping_bag,
          ),
        ]
      : [
          _ProgressStep(
            title: 'Order Confirmed',
            subtitle: 'Today, 10:45 AM',
            isCompleted: true,
            isActive: false,
            icon: Icons.check_circle,
          ),
          _ProgressStep(
            title: 'Preparing your Basket',
            subtitle: 'Lola is picking the freshest items',
            isCompleted: true,
            isActive: false,
            icon: Icons.shopping_basket,
          ),
          _ProgressStep(
            title: 'Out for Delivery',
            subtitle: 'Rider is heading your way',
            isCompleted: false,
            isActive: true,
            icon: Icons.delivery_dining,
          ),
          _ProgressStep(
            title: 'Arrived',
            subtitle: 'Enjoy your market-fresh items!',
            isCompleted: false,
            isActive: false,
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

  Widget _buildPickupVerification() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B372B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PICK-UP VERIFICATION',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'PG-882',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code,
                  size: 40,
                  color: Color(0xFF0B372B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Show this code to Juan at Stall 12',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B372B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 56,
                height: 56,
                color: const Color(0xFF1a4d3e),
                child: const Icon(Icons.person, color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Ricardo Dalisay',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFACC15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: Color(0xFF0B372B)),
                          SizedBox(width: 2),
                          Text(
                            '4.9',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B372B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Honda Click • ABC 1234',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.message_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.phone_outlined,
                onTap: () {},
                backgroundColor: const Color(0xFFFACC15),
                iconColor: const Color(0xFF0B372B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
    Color iconColor = const Color(0xFF0B372B),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
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

/// Map grid background painter (placeholder for Google Maps)
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBBF7D0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    const spacing = 40.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
