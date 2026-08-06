import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/cart/data/mock_cart_repository.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';
import 'package:palengkego/features/cart/domain/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return MockCartRepository();
});

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    final repository = ref.read(cartRepositoryProvider);
    return repository.getCartItems();
  }

  Future<void> addToCart(CartItem item) async {
    final repository = ref.read(cartRepositoryProvider);
    await repository.addToCart(item);
    ref.invalidateSelf();
  }

  Future<void> updateQuantity(
    String vendorName,
    String productName,
    String unit,
    double quantity,
  ) async {
    final repository = ref.read(cartRepositoryProvider);
    await repository.updateCartItemQuantity(
      vendorName: vendorName,
      productName: productName,
      unit: unit,
      quantity: quantity,
    );
    ref.invalidateSelf();
  }

  Future<void> toggleSelect(
    String vendorName,
    String productName,
    String unit,
  ) async {
    final repository = ref.read(cartRepositoryProvider);
    await repository.toggleItemSelection(
      vendorName: vendorName,
      productName: productName,
      unit: unit,
    );
    ref.invalidateSelf();
  }

  Future<void> selectAll(bool value) async {
    final repository = ref.read(cartRepositoryProvider);
    await repository.selectAll(value);
    ref.invalidateSelf();
  }

  Future<void> removeItem(
    String vendorName,
    String productName,
    String unit,
  ) async {
    final repository = ref.read(cartRepositoryProvider);
    await repository.removeCartItem(
      vendorName: vendorName,
      productName: productName,
      unit: unit,
    );
    ref.invalidateSelf();
  }

  Future<void> removeSelectedItems() async {
    final repository = ref.read(cartRepositoryProvider);
    await repository.removeSelectedItems();
    ref.invalidateSelf();
  }

  Future<void> clearCart() async {
    final repository = ref.read(cartRepositoryProvider);
    await repository.clearCart();
    ref.invalidateSelf();
  }
}

final cartItemsProvider = AsyncNotifierProvider<CartNotifier, List<CartItem>>(
  () {
    return CartNotifier();
  },
);

final cartCountProvider = Provider<AsyncValue<int>>((ref) {
  final cartItemsAsync = ref.watch(cartItemsProvider);
  return cartItemsAsync.whenData((cartItems) {
    return cartItems.length;
  });
});

final cartSubtotalProvider = Provider<AsyncValue<double>>((ref) {
  final cartItemsAsync = ref.watch(cartItemsProvider);
  return cartItemsAsync.whenData((cartItems) {
    return cartItems
        .where((item) => item.selected)
        .fold<double>(0, (sum, item) => sum + item.total);
  });
});
