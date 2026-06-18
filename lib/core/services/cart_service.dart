import 'package:flutter/foundation.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);

  int get itemCount => _items
      .where((item) => item.selected)
      .fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items
      .where((item) => item.selected)
      .fold<double>(0, (sum, item) => sum + item.total);

  void _notifyAll() {
    notifyListeners();
  }

  void addToCart({
    required String vendorName,
    required String productName,
    required double price,
    required String weight,
    required String pricePerKg,
    required String image,
    int quantity = 1,
    int stockQuantity = 10,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.vendorName == vendorName &&
          item.productName == productName &&
          item.weight == weight,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
        stockQuantity: stockQuantity,
      );
    } else {
      _items.add(
        CartItem(
          vendorName: vendorName,
          productName: productName,
          price: price,
          weight: weight,
          pricePerKg: pricePerKg,
          image: image,
          quantity: quantity,
          stockQuantity: stockQuantity,
        ),
      );
    }
    _notifyAll();
  }

  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      _notifyAll();
    }
  }

  void toggleSelect(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index] = _items[index].copyWith(selected: !_items[index].selected);
      _notifyAll();
    }
  }

  void selectAll(bool value) {
    for (var index = 0; index < _items.length; index++) {
      _items[index] = _items[index].copyWith(selected: value);
    }
    _notifyAll();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _notifyAll();
    }
  }

  void removeSelectedItems() {
    _items.removeWhere((item) => item.selected);
    _notifyAll();
  }

  void clearCart() {
    _items.clear();
    _notifyAll();
  }
}
