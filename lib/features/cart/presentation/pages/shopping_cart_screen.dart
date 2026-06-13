import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/profile/application/preferences_provider.dart';
import 'package:palengkego/features/profile/domain/delivery_address.dart';
import 'package:palengkego/core/widgets/app_screen_header.dart';

import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:palengkego/features/cart/presentation/widgets/cart_summary_bar.dart';

class ShoppingCartScreen extends ConsumerStatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  ConsumerState<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends ConsumerState<ShoppingCartScreen> {
  int _findItemIndex(CartItem target) {
    return ref
        .read(cartServiceProvider)
        .items
        .indexWhere(
          (item) =>
              item.vendorName == target.vendorName &&
              item.productName == target.productName &&
              item.weight == target.weight,
        );
  }

  void _toggleSelectAll(String vendorName) {
    final cart = ref.read(cartServiceProvider);
    final vendorItems = cart.items
        .where((item) => item.vendorName == vendorName)
        .toList();
    final allSelected = vendorItems.every((item) => item.selected);
    for (final item in vendorItems) {
      final idx = _findItemIndex(item);
      if (idx < 0) continue;
      if (allSelected == item.selected) {
        cart.toggleSelect(idx);
      }
    }
  }

  void _toggleSelectAllItems() {
    final cart = ref.read(cartServiceProvider);
    final items = cart.items;
    final allSelected =
        items.isNotEmpty && items.every((item) => item.selected);
    cart.selectAll(!allSelected);
  }

  Future<void> _pickAddress() async {
    final currentAddress = ref.read(preferencesProvider).deliveryAddress;
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.setDeliveryAddress);
    if (result is DeliveryAddress) {
      ref.read(preferencesProvider.notifier).updateAddress(
        primaryAddress: result.primaryAddress.isEmpty
            ? currentAddress.primaryAddress
            : result.primaryAddress,
        streetAddress: result.streetAddress,
        notes: result.notes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartServiceProvider);
    final preferences = ref.watch(preferencesProvider);

    final items = cart.items;
    final selectedItems = items.where((item) => item.selected).toList();
    final subtotal = selectedItems.fold<double>(
      0.0,
      (sum, item) => sum + item.total,
    );
    final allSelected =
        items.isNotEmpty && items.every((item) => item.selected);
    final deliveryAddress = preferences.deliveryAddress;

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
                        trailing: Text(
                          '${items.length} item${items.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
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
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  8,
                                ),
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
                                        value: entry.value.every(
                                          (item) => item.selected,
                                        ),
                                        activeColor: const Color(0xFF0B372B),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (_) =>
                                            _toggleSelectAll(entry.key),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              for (final item in entry.value)
                                CartItemCard(
                                  item: item,
                                  onToggleSelect: () {
                                    final idx = _findItemIndex(item);
                                    if (idx >= 0) {
                                      cart.toggleSelect(idx);
                                    }
                                  },
                                  onQuantityChange: (delta) {
                                    final idx = _findItemIndex(item);
                                    if (idx < 0) return;
                                    final newQty = item.quantity + delta;
                                    if (newQty <= 0) {
                                      cart.removeItem(idx);
                                    } else {
                                      cart.updateQuantity(idx, newQty);
                                    }
                                  },
                                  onDelete: () {
                                    final idx = _findItemIndex(item);
                                    if (idx >= 0) {
                                      cart.removeItem(idx);
                                    }
                                  },
                                ),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ),
                ),
                if (items.isNotEmpty)
                  CartSummaryBar(
                    allSelected: allSelected,
                    subtotal: subtotal,
                    hasSelectedItems: selectedItems.isNotEmpty,
                    onToggleSelectAll: _toggleSelectAllItems,
                    onCheckout: () {
                      Navigator.of(context).pushNamed(AppRoutes.checkout);
                    },
                  ),
              ],
            ),
          ),
        );
  }
}
