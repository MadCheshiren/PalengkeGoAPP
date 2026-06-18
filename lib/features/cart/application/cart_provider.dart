import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

final cartItemsProvider = Provider<List<CartItem>>((ref) {
  final cart = ref.watch(cartServiceProvider);
  void listener() {
    ref.invalidateSelf();
  }
  cart.addListener(listener);
  ref.onDispose(() => cart.removeListener(listener));
  return List<CartItem>.unmodifiable(cart.items);
});

final cartCountProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartItemsProvider);
  return cartItems
      .where((item) => item.selected)
      .fold<int>(0, (sum, item) => sum + item.quantity);
});
