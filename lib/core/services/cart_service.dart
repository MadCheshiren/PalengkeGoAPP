import 'package:flutter/foundation.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';

class CartItem {
  final String vendorName;
  final String productName;
  final double price;
  final String weight;
  final String pricePerKg;
  final String image;
  int quantity;
  bool selected;

  CartItem({
    required this.vendorName,
    required this.productName,
    required this.price,
    required this.weight,
    required this.pricePerKg,
    required this.image,
    this.quantity = 1,
    this.selected = true,
  });

  double get total => price * quantity;
}

// Global cart instance
final globalCart = CartService();

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
    updateCartBadgeCount(itemCount);
    notifyListeners();
  }

  void addToCart({
    required String vendorName,
    required String productName,
    required double price,
    required String weight,
    required String pricePerKg,
    required String image,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.vendorName == vendorName &&
          item.productName == productName &&
          item.weight == weight,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(
          vendorName: vendorName,
          productName: productName,
          price: price,
          weight: weight,
          pricePerKg: pricePerKg,
          image: image,
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
        _items[index].quantity = quantity;
      }
      _notifyAll();
    }
  }

  void toggleSelect(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].selected = !_items[index].selected;
      _notifyAll();
    }
  }

  void selectAll(bool value) {
    for (final item in _items) {
      item.selected = value;
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
