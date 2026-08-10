import 'package:palengkego/core/config/fee_config.dart';
import 'package:palengkego/core/services/app_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/domain/order_failure.dart';
import 'package:palengkego/features/orders/domain/order_line_item.dart';
import 'package:palengkego/features/profile/application/profile_provider.dart';

/// State + order placement logic for the checkout screen.
class CheckoutController extends ChangeNotifier {
  CheckoutController({required this.ref});

  final WidgetRef ref;

  int _deliveryMethod = 0; // 0 = Delivery, 1 = Pick-Up
  bool _isPriority = false;
  final Map<String, TextEditingController> _vendorNotesControllers = {};
  bool _placingOrder = false;
  bool _disposed = false;

  int get deliveryMethod => _deliveryMethod;
  bool get isPriority => _isPriority;
  bool get placingOrder => _placingOrder;

  double get priorityFee {
    return (_deliveryMethod == 0 && _isPriority) ? FeeConfig.priorityFee : 0.0;
  }

  TextEditingController notesControllerFor(String vendorName) {
    return _vendorNotesControllers.putIfAbsent(
      vendorName,
      () => TextEditingController(),
    );
  }

  void setDeliveryMethod(int value) {
    _deliveryMethod = value;
    _notify();
  }

  void setPriority(bool value) {
    _isPriority = value;
    _notify();
  }

  /// Groups the selected items by vendor and places the orders.
  /// Returns the created orders, or null (with an error shown) on failure.
  Future<List<MarketOrder>?> placeOrder({
    required List<CartItem> selectedItems,
  }) async {
    _placingOrder = true;
    _notify();

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

    try {
      final Map<String, (String, List<OrderLineItem>)> groupedItems = {};
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
            vendorNotes: vendorNotes.isNotEmpty ? vendorNotes : null,
            customerName: customerName,
            customerUid: customerUid,
            isPriority: _deliveryMethod == 0 && _isPriority,
            priorityFee: priorityFee,
          );

      ref.read(orderServiceProvider.notifier).refresh();
      ref.read(cartItemsProvider.notifier).removeSelectedItems();
      return createdOrders;
    } on OrderFailure catch (e) {
      AppServices.showError(e.message);
      return null;
    } catch (e, stack) {
      if (kDebugMode) debugPrint('Error placing order: $e');
      if (kDebugMode) debugPrint('Stacktrace: $stack');
      AppServices.showError(
        'Failed to place your order. Your cart is unchanged — please try again.',
      );
      return null;
    } finally {
      _placingOrder = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final controller in _vendorNotesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
