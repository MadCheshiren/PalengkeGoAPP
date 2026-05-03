import 'package:flutter/material.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/core/services/customer_preferences_service.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/core/widgets/app_screen_header.dart';
import 'package:palengkego/features/checkout/presentation/pages/order_confirmation_screen.dart';
import 'package:palengkego/features/checkout/presentation/pages/payment_methods_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _deliveryMethod = 0; // 0 = Delivery, 1 = Pick-Up

  @override
  void initState() {
    super.initState();
    globalCustomerPreferences.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    globalCustomerPreferences.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = globalCart.items
        .where((item) => item.selected)
        .toList();
    final subtotal = selectedItems.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );
    final deliveryFee = _deliveryMethod == 0 ? 50.0 : 0.0;
    final Map<String, List<CartItem>> itemsByVendor = {};

    for (final item in selectedItems) {
      itemsByVendor.putIfAbsent(item.vendorName, () => []);
      itemsByVendor[item.vendorName]!.add(item);
    }

    final primaryVendor = itemsByVendor.entries.isNotEmpty
        ? itemsByVendor.entries.first
        : null;
    final deliveryAddress = globalCustomerPreferences.deliveryAddress;
    final vendorRating = _vendorRating(primaryVendor?.key);
    final vendorStall = _vendorStall(primaryVendor?.key);
    final vendorSection = _vendorSection(primaryVendor?.key);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppScreenHeader(title: 'Checkout', size: 32, titleSize: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _methodToggle(),
                    const SizedBox(height: 24),
                    if (_deliveryMethod == 0) ...[
                      _sectionTitle(
                        icon: Icons.location_on_outlined,
                        title: 'Delivery Address',
                      ),
                      const SizedBox(height: 12),
                      _deliveryAddressCard(deliveryAddress),
                      const SizedBox(height: 12),
                      _deliveryMapCard(),
                    ] else ...[
                      Row(
                        children: [
                          _sectionTitle(
                            icon: Icons.store_mall_directory_outlined,
                            title: 'Pick-Up Details',
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'READY IN 15-25M',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _pickupCard(
                        vendorName: primaryVendor?.key ?? 'Vendor',
                        vendorStall: vendorStall,
                        vendorSection: vendorSection,
                        vendorRating: vendorRating,
                        vendorCount: itemsByVendor.length,
                      ),
                      const SizedBox(height: 12),
                      _readyTimeCard(),
                    ],
                    const SizedBox(height: 24),
                    _sectionTitle(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment Method',
                    ),
                    const SizedBox(height: 12),
                    _paymentMethodCard(),
                    const SizedBox(height: 24),
                    _sectionTitle(
                      icon: Icons.shopping_basket_outlined,
                      title: 'Order Summary',
                    ),
                    const SizedBox(height: 12),
                    ...selectedItems.map(_orderItem),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    _summaryRow(
                      'Subtotal',
                      'PHP ${subtotal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    _summaryRow(
                      'Delivery Fee',
                      _deliveryMethod == 0
                          ? 'PHP ${deliveryFee.toStringAsFixed(2)}'
                          : 'FREE',
                      highlighted: _deliveryMethod == 1,
                    ),
                  ],
                ),
              ),
            ),
            _footer(
              enabled: selectedItems.isNotEmpty,
              onPlaceOrder: () {
                // Create orders and get the first one for tracking
                final createdOrders = globalOrders.placeOrders(
                  items: selectedItems,
                  isPickup: _deliveryMethod == 1,
                );
                final firstOrder = createdOrders.isNotEmpty ? createdOrders.first : null;
                final orderNumber = firstOrder?.id ?? '#${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 12)}';
                
                globalCart.removeSelectedItems();

                // Navigate to order confirmation screen
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        OrderConfirmationScreen(
                          isPickup: _deliveryMethod == 1,
                          orderNumber: orderNumber,
                          vendorName: primaryVendor?.key,
                          vendorStall: vendorStall,
                          vendorSection: vendorSection,
                          address: deliveryAddress.displayLine,
                          order: firstOrder,
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      final scaleTween = Tween(begin: 0.95, end: 1.0).chain(
                        CurveTween(curve: Curves.easeOutCubic),
                      );
                      final fadeTween = Tween(begin: 0.0, end: 1.0).chain(
                        CurveTween(curve: Curves.easeOut),
                      );

                      return ScaleTransition(
                        scale: animation.drive(scaleTween),
                        child: FadeTransition(
                          opacity: animation.drive(fadeTween),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 280),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 220),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodToggle() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleButton(
              label: 'Delivery',
              icon: Icons.local_shipping_outlined,
              selected: _deliveryMethod == 0,
              onTap: () => setState(() => _deliveryMethod = 0),
            ),
          ),
          Expanded(
            child: _toggleButton(
              label: 'Pick-Up',
              icon: Icons.storefront_outlined,
              selected: _deliveryMethod == 1,
              onTap: () => setState(() => _deliveryMethod = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected
                  ? const Color(0xFF0B372B)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? const Color(0xFF0B372B)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF111827)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _deliveryAddressCard(DeliveryAddress deliveryAddress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        // No border - using shadow per design system
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deliveryAddress.contactName,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deliveryAddress.displayLine,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryMapCard() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD9FBE6), Color(0xFFE9F7EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CustomPaint(
                painter: _MapPatternPainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.place_rounded,
              size: 40,
              color: Color(0xFF0B372B),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    offset: Offset(0, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.edit_outlined, size: 14, color: Color(0xFF0B372B)),
                  SizedBox(width: 4),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickupCard({
    required String vendorName,
    required String vendorStall,
    required String vendorSection,
    required double vendorRating,
    required int vendorCount,
  }) {
    final subtitle = vendorCount > 1
        ? '$vendorStall | $vendorSection + ${vendorCount - 1} more'
        : '$vendorStall | $vendorSection';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // No border - using shadow per design system
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&h=120&fit=crop&crop=face',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendorName,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B372B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFACC15),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$vendorRating',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '(100+ reviews)',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readyTimeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF0B372B)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTIMATED READY TIME',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ready by: 15-25 minutes',
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
        ],
      ),
    );
  }

  Widget _paymentMethodCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentMethodsScreen(
              currentMethod: 'cod', // Default to Cash on Delivery
            ),
          ),
        );
        if (result != null && result is Map<String, dynamic>) {
          final method = result['method'] as String;
          final cardData = result['cardData'] as Map<String, dynamic>?;
          final cardLabel = cardData == null
              ? null
              : '${cardData['brand'] ?? 'Card'} •••• ${cardData['last4'] ?? ''}';
          globalCustomerPreferences.updatePaymentMethod(
            method,
            cardLabel: cardLabel,
          );
          final message = switch (method) {
            'cod' => 'Cash on Delivery selected',
            'gcash' => 'GCash selected',
            'card' => 'Card selected',
            _ => 'Payment method updated',
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.payments_outlined,
                  size: 20,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    globalCustomerPreferences.paymentTitle,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    globalCustomerPreferences.paymentSubtitle,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.image,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 48,
                height: 48,
                color: const Color(0xFFE5E7EB),
                child: const Icon(
                  Icons.image_rounded,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B372B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity}kg • ${item.pricePerKg.replaceFirst('PHP ', '')}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'PHP ${item.total.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool highlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: highlighted
                ? const Color(0xFF0B372B)
                : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _footer({required bool enabled, required VoidCallback onPlaceOrder}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: enabled ? onPlaceOrder : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B372B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              disabledForegroundColor: Colors.white70,
              elevation: 6,
              shadowColor: const Color(0xFF0B372B).withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Place Order',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _vendorRating(String? vendorName) {
    switch (vendorName) {
      case 'Aicel D. Castillo Fish Retailer':
        return 4.5;
      case 'Diosa Fruit Stand':
        return 4.9;
      case 'William Del Rosario Meat Shop':
        return 4.5;
      case 'Paul\'s Meat Shop':
        return 4.9;
      case 'Merly Diego Dried Fish Store':
        return 4.7;
      case 'Sophie Sb’s Store':
      case 'Sofie Sb’s Store':
        return 4.7;
      default:
        return 4.6;
    }
  }

  String _vendorStall(String? vendorName) {
    switch (vendorName) {
      case 'Aicel D. Castillo Fish Retailer':
        return 'Block 14 | Stall 2';
      case 'Diosa Fruit Stand':
        return 'Stall 4';
      case 'William Del Rosario Meat Shop':
        return 'Block 15 | Stall 2';
      case 'Paul\'s Meat Shop':
        return 'Stall #33';
      case 'Merly Diego Dried Fish Store':
        return 'Block 3 | Stall 4';
      case 'Sophie Sb’s Store':
      case 'Sofie Sb’s Store':
        return 'Block 7 | Stall 2';
      default:
        return 'Market Stall';
    }
  }

  String _vendorSection(String? vendorName) {
    switch (vendorName) {
      case 'Diosa Fruit Stand':
        return 'Fruit Section';
      case 'William Del Rosario Meat Shop':
      case 'Paul\'s Meat Shop':
        return 'Meat Section';
      case 'Sophie Sb’s Store':
      case 'Sofie Sb’s Store':
        return 'Vegetable Section';
      default:
        return 'Fish Section';
    }
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFA7F3D0)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFBBF7D0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(size.width * 0.05, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.55,
        size.width * 0.48,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.72,
        size.width * 0.95,
        size.height * 0.40,
      );

    final path2 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.08)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.20,
        size.width * 0.52,
        size.height * 0.05,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.18,
        size.width * 0.88,
        size.height * 0.10,
      );

    final path3 = Path()
      ..moveTo(size.width * 0.52, size.height * 0.10)
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.32,
        size.width * 0.52,
        size.height * 0.92,
      );

    canvas.drawPath(path1, roadPaint);
    canvas.drawPath(path2, thinRoadPaint);
    canvas.drawPath(path3, thinRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
