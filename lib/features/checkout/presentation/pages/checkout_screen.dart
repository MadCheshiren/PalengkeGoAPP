import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/config/fee_config.dart';
import 'package:palengkego/core/services/app_services.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/orders/domain/order_line_item.dart';

import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/profile/application/profile_provider.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/features/profile/application/preferences_provider.dart';
import 'package:palengkego/features/profile/domain/delivery_address.dart';
import 'package:palengkego/core/widgets/app_screen_header.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/checkout/domain/payment_selection.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_delivery_cards.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_delivery_option_card.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_footer.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_method_toggle.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_order_item.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_pickup_cards.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_section_title.dart';
import 'package:palengkego/features/checkout/presentation/widgets/checkout_summary_row.dart';
import 'package:palengkego/features/market/application/market_provider.dart';
import 'package:palengkego/features/market/domain/market_vendor.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _deliveryMethod = 0; // 0 = Delivery, 1 = Pick-Up
  bool _isPriority = false;
  final Map<String, TextEditingController> _vendorNotesControllers = {};

  @override
  void dispose() {
    for (final controller in _vendorNotesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(cartItemsProvider);
    final items = itemsAsync.value ?? [];
    final preferences = ref.watch(preferencesProvider);
    final selectedItems = items.where((item) => item.selected).toList();
    final subtotal = selectedItems.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );
    final deliveryFee = _deliveryMethod == 0 ? FeeConfig.deliveryFee : 0.0;
    final priorityFee = (_deliveryMethod == 0 && _isPriority)
        ? FeeConfig.priorityFee
        : 0.0;
    final Map<String, List<CartItem>> itemsByVendor = {};

    for (final item in selectedItems) {
      itemsByVendor.putIfAbsent(item.vendorName, () => []);
      itemsByVendor[item.vendorName]!.add(item);
    }

    for (final vendor in itemsByVendor.keys) {
      _vendorNotesControllers.putIfAbsent(
        vendor,
        () => TextEditingController(),
      );
    }

    final deliveryAddress = preferences.deliveryAddress;

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
                        ref
                            .read(preferencesProvider.notifier)
                            .updatePaymentMethod(value == 0 ? 'cod' : 'cop');
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
                        onChange: () async {
                          final result = await Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.setDeliveryAddress);
                          if (!mounted) return;
                          if (result is DeliveryAddress) {
                            ref
                                .read(preferencesProvider.notifier)
                                .updateAddress(
                                  primaryAddress: result.primaryAddress.isEmpty
                                      ? deliveryAddress.primaryAddress
                                      : result.primaryAddress,
                                  streetAddress: result.streetAddress,
                                  notes: result.notes,
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CheckoutDeliveryOptionCard(
                        isPrioritySelected: _isPriority,
                        onOptionChanged: (val) {
                          setState(() => _isPriority = val);
                        },
                      ),
                    ] else ...[
                      const CheckoutPickupHeader(),
                      const SizedBox(height: 12),
                      ...itemsByVendor.entries.map((entry) {
                        final vendorName = entry.key;
                        final allVendors = ref
                            .watch(allVendorsProvider)
                            .maybeWhen(data: (v) => v, orElse: () => []);
                        final vendorModel = allVendors.firstWhere(
                          (v) => v.name == vendorName,
                          orElse: () => const MarketVendor(
                            id: '',
                            name: 'Stall Holder',
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
                            vendorStall:
                                vendorModel.stallNumber ?? 'Market Stall',
                            vendorSection:
                                vendorModel.marketSection ?? 'Fish Section',
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
                    ...selectedItems.map(
                      (item) => CheckoutOrderItem(item: item),
                    ),
                    const SizedBox(height: 24),
                    const CheckoutSectionTitle(
                      icon: Icons.note_alt_outlined,
                      title: 'Order Notes / Instructions',
                    ),
                    const SizedBox(height: 12),
                    ...itemsByVendor.keys.map((vendorName) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes for $vendorName',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _notesTextField(vendorName),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    CheckoutSummaryRow(
                      label: 'Subtotal',
                      value: '₱${subtotal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    CheckoutSummaryRow(
                      label: 'Delivery Fee',
                      value: _deliveryMethod == 0
                          ? '₱${deliveryFee.toStringAsFixed(2)}'
                          : 'FREE',
                      highlighted: _deliveryMethod == 1,
                    ),
                    if (_deliveryMethod == 0 && _isPriority) ...[
                      const SizedBox(height: 8),
                      const CheckoutSummaryRow(
                        label: 'Priority Delivery Fee',
                        value: '₱29.00',
                        highlighted: true,
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    CheckoutSummaryRow(
                      label: 'Total',
                      value:
                          '₱${(subtotal + deliveryFee + priorityFee).toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            CheckoutFooter(
              enabled: selectedItems.isNotEmpty,
              onPlaceOrder: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      'Place Order',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to place this order? This action cannot be undone.',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF0B372B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
                if (!context.mounted) return;

                final Map<String, String> vendorNotes = {};
                for (final entry in _vendorNotesControllers.entries) {
                  final text = entry.value.text.trim();
                  if (text.isNotEmpty) {
                    vendorNotes[entry.key] = text;
                  }
                }

                final profile = ref.read(currentProfileProvider).value;
                final customerName = profile?.displayName ?? 'Customer';
                final customerUid = ref.read(authProvider)?.uid ?? '';

                // Create orders
                try {
                  final Map<String, (String, List<OrderLineItem>)>
                  groupedItems = {};
                  for (final item in selectedItems) {
                    groupedItems.putIfAbsent(
                      item.vendorName,
                      () => (item.image, <OrderLineItem>[]),
                    );
                    groupedItems[item.vendorName]!.$2.add(
                      OrderLineItem(
                        productId: item.productId,
                        productName: item.productName,
                        quantity: item.quantity,
                        unitPrice: item.price,
                        unit: item.unit,
                        image: item.image,
                      ),
                    );
                  }

                  final createdOrders = await ref
                      .read(orderRepositoryProvider)
                      .placeOrders(
                        groupedItems: groupedItems,
                        isPickup: _deliveryMethod == 1,
                        vendorNotes: vendorNotes.isNotEmpty
                            ? vendorNotes
                            : null,
                        customerName: customerName,
                        customerUid: customerUid,
                        isPriority: _deliveryMethod == 0 && _isPriority,
                        priorityFee: priorityFee,
                      );

                  ref.read(orderServiceProvider.notifier).refresh();
                  ref.read(cartItemsProvider.notifier).removeSelectedItems();

                  // Navigate to order confirmation screen
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.orderConfirmation,
                    (route) => false,
                    arguments: OrderConfirmationRouteArgs(
                      isPickup: _deliveryMethod == 1,
                      orders: createdOrders,
                      address: deliveryAddress.displayLine,
                    ),
                  );
                } catch (e, stack) {
                  if (kDebugMode) debugPrint('Error placing order: $e');
                  if (kDebugMode) debugPrint('Stacktrace: $stack');
                  if (context.mounted) {
                    AppServices.showError(
                      'Failed to place your order. Your cart is unchanged — please try again.',
                    );
                  }
                }
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
          arguments: PaymentMethodsRouteArgs(
            currentMethod: ref.read(preferencesProvider).paymentMethod,
            fulfillmentMethod: _deliveryMethod == 0 ? 'delivery' : 'pickup',
          ),
        );
        if (!mounted) return;
        if (result is PaymentSelectionResult) {
          final method = result.method;
          final cardLabel = result.cardData?.displayLabel;
          ref
              .read(preferencesProvider.notifier)
              .updatePaymentMethod(method, cardLabel: cardLabel);
          final message = switch (method) {
            'cod' => 'Cash on Delivery selected',
            'gcash' => 'GCash selected',
            'card' => 'Card selected',
            _ => 'Payment method updated',
          };
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
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
                    ref.watch(preferencesProvider).paymentTitle,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    ref.watch(preferencesProvider).paymentSubtitle,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _notesTextField(String vendorName) {
    return TextFormField(
      controller: _vendorNotesControllers[vendorName],
      maxLines: 3,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        hintText:
            'e.g. chop the pork into small cubes, select green bananas, etc.',
        hintStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          color: Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0B372B), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
