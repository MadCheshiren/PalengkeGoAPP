import 'package:flutter/material.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/core/services/customer_preferences_service.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/core/widgets/app_screen_header.dart';
import 'package:palengkego/features/checkout/presentation/pages/checkout_screen.dart';
import 'package:palengkego/features/profile/presentation/pages/set_delivery_address_screen.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  @override
  void initState() {
    super.initState();
    globalCart.addListener(_onStateChanged);
    globalCustomerPreferences.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    globalCart.removeListener(_onStateChanged);
    globalCustomerPreferences.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  int _findItemIndex(CartItem target) {
    return globalCart.items.indexWhere(
      (item) =>
          item.vendorName == target.vendorName &&
          item.productName == target.productName &&
          item.weight == target.weight,
    );
  }

  void _toggleSelectAll(String vendorName) {
    final vendorItems =
        globalCart.items.where((item) => item.vendorName == vendorName).toList();
    final allSelected = vendorItems.every((item) => item.selected);
    for (final item in vendorItems) {
      final idx = _findItemIndex(item);
      if (idx < 0) continue;
      if (allSelected == item.selected) {
        globalCart.toggleSelect(idx);
      }
    }
  }

  void _toggleSelectAllItems() {
    final items = globalCart.items;
    final allSelected = items.isNotEmpty && items.every((item) => item.selected);
    globalCart.selectAll(!allSelected);
  }

  Future<void> _pickAddress() async {
    final currentAddress = globalCustomerPreferences.deliveryAddress;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SetDeliveryAddressScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      globalCustomerPreferences.updateAddress(
        primaryAddress:
            (result['address'] as String?) ?? currentAddress.primaryAddress,
        streetAddress: (result['streetAddress'] as String?) ?? '',
        notes: (result['notes'] as String?) ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = globalCart.items;
    final selectedItems = items.where((item) => item.selected).toList();
    final subtotal =
        selectedItems.fold<double>(0.0, (sum, item) => sum + item.total);
    final allSelected = items.isNotEmpty && items.every((item) => item.selected);
    final deliveryAddress = globalCustomerPreferences.deliveryAddress;

    final vendorGroups = <String, List<CartItem>>{};
    for (final item in items) {
      vendorGroups.putIfAbsent(item.vendorName, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppScreenHeader(
                    title: 'Shopping Cart',
                    trailing: Center(
                      child: Text(
                        '${items.length} item${items.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickAddress,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Deliver to ${deliveryAddress.displayLine}',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Color(0xFFCBD5E1),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Start adding items from the market',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
                      children: [
                        for (final entry in vendorGroups.entries) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.storefront_outlined,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0B372B),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: entry.value.every((item) => item.selected),
                                    activeColor: const Color(0xFF0B372B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (_) => _toggleSelectAll(entry.key),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (final item in entry.value)
                            _CartItemCard(
                              item: item,
                              onToggleSelect: () {
                                final idx = _findItemIndex(item);
                                if (idx >= 0) {
                                  globalCart.toggleSelect(idx);
                                }
                              },
                              onQuantityChange: (delta) {
                                final idx = _findItemIndex(item);
                                if (idx < 0) return;
                                final newQty = item.quantity + delta;
                                if (newQty <= 0) {
                                  globalCart.removeItem(idx);
                                } else {
                                  globalCart.updateQuantity(idx, newQty);
                                }
                              },
                              onDelete: () {
                                final idx = _findItemIndex(item);
                                if (idx >= 0) {
                                  globalCart.removeItem(idx);
                                }
                              },
                            ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
            ),
            if (items.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleSelectAllItems,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: allSelected,
                                activeColor: const Color(0xFF0B372B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (_) => _toggleSelectAllItems(),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'All',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              'PHP ${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: selectedItems.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    PageTransitions.slideFromRight(
                                      const CheckoutScreen(),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B372B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor: const Color(0xFF94A3B8),
                            disabledForegroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onToggleSelect,
    required this.onQuantityChange,
    required this.onDelete,
  });

  final CartItem item;
  final VoidCallback onToggleSelect;
  final ValueChanged<int> onQuantityChange;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: item.selected,
              activeColor: const Color(0xFF0B372B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (_) => onToggleSelect(),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: item.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.image,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.image_outlined,
                        size: 28,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.image_outlined,
                    size: 28,
                    color: Color(0xFF94A3B8),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.pricePerKg,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'PHP ${item.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                    const Spacer(),
                    _QuantityStepper(
                      quantity: item.quantity,
                      onChanged: onQuantityChange,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Color(0xFFEF4444),
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
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(-1),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: const Icon(Icons.remove_rounded, size: 16),
            ),
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(1),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0B372B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
