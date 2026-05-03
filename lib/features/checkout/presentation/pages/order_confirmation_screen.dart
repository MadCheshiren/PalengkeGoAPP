import 'package:flutter/material.dart';
import 'package:palengkego/core/services/customer_preferences_service.dart';
import 'package:palengkego/core/widgets/app_screen_header.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/checkout/presentation/pages/payment_methods_screen.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';
import 'package:palengkego/features/orders/presentation/pages/track_order_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final bool isPickup;
  final String orderNumber;
  final String? vendorName;
  final String? vendorStall;
  final String? vendorSection;
  final String? address;
  final MarketOrder? order;

  const OrderConfirmationScreen({
    super.key,
    required this.isPickup,
    required this.orderNumber,
    this.vendorName,
    this.vendorStall,
    this.vendorSection,
    this.address,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: 'Order Confirmation',
              size: 32,
              titleSize: 18,
              onBack: () => Navigator.of(context).pop(),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  children: [
                    // Success icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0B372B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Success message
                    const Text(
                      'Order Placed\nSuccessfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Order number
                    Text(
                      'Order Number: $orderNumber',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Information card
                    _buildInfoCard(),
                    const SizedBox(height: 16),

                    // Payment method card
                    _buildPaymentCard(context),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to track order screen
                        if (order != null) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => TrackOrderScreen(
                                order: order!,
                                isPickup: isPickup,
                              ),
                            ),
                            (route) => false,
                          );
                        } else {
                          // Fallback to orders list
                          mainTabNotifier.value = 2;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(initialIndex: 2),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B372B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isPickup ? 'Track Stall' : 'Track My Order',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to home
                        mainTabNotifier.value = 0;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const MainScreen(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0B372B),
                        side: const BorderSide(color: Color(0xFF0B372B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  Widget _buildInfoCard() {
    if (isPickup) {
      // Pick-up variant
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 20,
                  color: Color(0xFF0B372B),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pick-Up Information',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B372B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B372B),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    vendorStall ?? 'Stall',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'STALL DETAILS',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              vendorName ?? 'Vendor',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${vendorStall ?? ''}${vendorSection != null ? ', $vendorSection' : ''}',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ESTIMATED READY TIME',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '15-25 mins',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Delivery variant
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 20,
                  color: Color(0xFF0B372B),
                ),
                SizedBox(width: 8),
                Text(
                  'Delivery Information',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B372B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'ADDRESS',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address ?? globalCustomerPreferences.deliveryAddress.displayLine,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ESTIMATED TIME',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '12-25 mins',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPaymentCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: Color(0xFF0B372B),
              ),
              SizedBox(width: 8),
              Text(
                'Payment Method',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B372B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentMethodsScreen(
                    currentMethod: 'cod',
                  ),
                ),
              );
              if (result != null && result is Map<String, dynamic>) {
                final method = result['method'] as String;
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                      globalCustomerPreferences.paymentTitle,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
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
          ),
        ],
      ),
    );
  }
}
