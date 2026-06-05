import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/core/services/customer_preferences_service.dart';
import 'package:palengkego/core/widgets/app_screen_header.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_delivery_cards.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_footer.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_method_toggle.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_order_item.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_pickup_cards.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_section_title.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_summary_row.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/market/application/market_provider.dart';
import 'package:palengkego/features/market/domain/market_vendor.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
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
    final cart = ref.read(cartServiceProvider);
    final orders = ref.read(orderServiceProvider);
    final selectedItems = cart.items
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

    final deliveryAddress = globalCustomerPreferences.deliveryAddress;

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
                    CheckoutMethodToggle(
                      deliveryMethod: _deliveryMethod,
                      onChanged: (value) {
                        setState(() => _deliveryMethod = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_deliveryMethod == 0) ...[
                      const CheckoutSectionTitle(
                        icon: Icons.location_on_outlined,
                        title: 'Delivery Address',
                      ),
                      const SizedBox(height: 12),
                      CheckoutDeliveryAddressCard(
                        deliveryAddress: deliveryAddress,
                      ),
                      const SizedBox(height: 12),
                      CheckoutDeliveryMapCard(
                        onTap: () async {
                          final result = await Navigator.of(context).pushNamed(
                            AppRoutes.setDeliveryAddress,
                          );
                          if (result != null && result is Map<String, dynamic>) {
                            final address = result['address'] as String;
                            final street = result['streetAddress'] as String;
                            final notes = result['notes'] as String;
                            globalCustomerPreferences.updateAddress(
                              primaryAddress: address,
                              streetAddress: street,
                              notes: notes,
                            );
                          }
                        },
                      ),
                    ] else ...[
                      const CheckoutPickupHeader(),
                      const SizedBox(height: 12),
                      ...itemsByVendor.entries.map((entry) {
                        final vendorName = entry.key;
                        final vendorModel = ref.watch(marketRepositoryProvider)
                            .getFeaturedVendors()
                            .firstWhere(
                              (v) => v.name == vendorName,
                              orElse: () => const MarketVendor(
                                id: '',
                                name: 'Vendor',
                                category: 'General',
                                rating: 4.6,
                                isVerified: false,
                                distance: '',
                                imageUrl: '',
                                stallNumber: 'Market Stall',
                                marketSection: 'Fish Section',
                              ),
                            );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CheckoutPickupCard(
                            vendorName: vendorName,
                            vendorStall: vendorModel.stallNumber ?? 'Market Stall',
                            vendorSection: vendorModel.marketSection ?? 'Fish Section',
                            vendorRating: vendorModel.rating,
                            vendorCount: 1,
                            vendorImageUrl: vendorModel.imageUrl,
                          ),
                        );
                      }),
                      const CheckoutReadyTimeCard(),
                    ],
                    const SizedBox(height: 24),
                    const CheckoutSectionTitle(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment Method',
                    ),
                    const SizedBox(height: 12),
                    _paymentMethodCard(),
                    const SizedBox(height: 24),
                    const CheckoutSectionTitle(
                      icon: Icons.shopping_basket_outlined,
                      title: 'Order Summary',
                    ),
                    const SizedBox(height: 12),
                    ...selectedItems.map((item) => CheckoutOrderItem(item: item)),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    CheckoutSummaryRow(
                      label: 'Subtotal',
                      value: 'PHP ${subtotal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    CheckoutSummaryRow(
                      label: 'Delivery Fee',
                      value: _deliveryMethod == 0
                          ? 'PHP ${deliveryFee.toStringAsFixed(2)}'
                          : 'FREE',
                      highlighted: _deliveryMethod == 1,
                    ),
                  ],
                ),
              ),
            ),
            CheckoutFooter(
              enabled: selectedItems.isNotEmpty,
              onPlaceOrder: () {
                // Create orders
                final createdOrders = orders.placeOrders(
                  items: selectedItems,
                  isPickup: _deliveryMethod == 1,
                );
                
                cart.removeSelectedItems();

                // Navigate to order confirmation screen
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.orderConfirmation,
                  (route) => false,
                  arguments: OrderConfirmationRouteArgs(
                    isPickup: _deliveryMethod == 1,
                    orders: createdOrders,
                    address: deliveryAddress.displayLine,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).pushNamed(
          AppRoutes.paymentMethods,
          arguments: const PaymentMethodsRouteArgs(currentMethod: 'cod'),
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
          if (!mounted) return;
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
}

