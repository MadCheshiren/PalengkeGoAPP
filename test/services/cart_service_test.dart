import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/core/services/cart_service.dart';

void main() {
  CartService buildCartWithItem() {
    final cart = CartService()
      ..addToCart(
        vendorName: 'Aling Nena',
        productName: 'Carrots',
        price: 120,
        weight: '500g',
        pricePerKg: 'PHP 120/500g',
        image: 'carrots.png',
      );

    return cart;
  }

  group('CartService', () {
    test('adds a new item and updates selected totals', () {
      final cart = buildCartWithItem();

      expect(cart.items, hasLength(1));
      expect(cart.itemCount, 1);
      expect(cart.subtotal, 120);
      expect(cart.items.single.vendorName, 'Aling Nena');
      expect(cart.items.single.productName, 'Carrots');
    });

    test('adding the same vendor product and weight increments quantity', () {
      final cart = buildCartWithItem()
        ..addToCart(
          vendorName: 'Aling Nena',
          productName: 'Carrots',
          price: 120,
          weight: '500g',
          pricePerKg: 'PHP 120/500g',
          image: 'carrots.png',
        );

      expect(cart.items, hasLength(1));
      expect(cart.items.single.quantity, 2);
      expect(cart.itemCount, 2);
      expect(cart.subtotal, 240);
    });

    test('adding a different product keeps existing cart items', () {
      final cart = buildCartWithItem()
        ..addToCart(
          vendorName: 'Mang Juan',
          productName: 'Bangus',
          price: 90,
          weight: '1pc',
          pricePerKg: 'PHP 90/pc',
          image: 'bangus.png',
        );

      expect(cart.items, hasLength(2));
      expect(cart.items.map((item) => item.productName), ['Carrots', 'Bangus']);
      expect(cart.subtotal, 210);
    });

    test('preserves stock quantity when adding an item', () {
      final cart = CartService()
        ..addToCart(
          vendorName: 'Aling Nena',
          productName: 'Carrots',
          price: 120,
          weight: '500g',
          pricePerKg: 'PHP 120/500g',
          image: 'carrots.png',
          stockQuantity: 7,
        );

      expect(cart.items.single.stockQuantity, 7);
    });

    test('updateQuantity removes an item when quantity is zero', () {
      final cart = buildCartWithItem();

      cart.updateQuantity(0, 0);

      expect(cart.items, isEmpty);
      expect(cart.itemCount, 0);
      expect(cart.subtotal, 0);
    });

    test('selectAll false excludes items from selected count and subtotal', () {
      final cart = buildCartWithItem()
        ..addToCart(
          vendorName: 'Mang Juan',
          productName: 'Bangus',
          price: 90,
          weight: '1pc',
          pricePerKg: 'PHP 90/pc',
          image: 'bangus.png',
        );

      cart.selectAll(false);

      expect(cart.items, hasLength(2));
      expect(cart.itemCount, 0);
      expect(cart.subtotal, 0);
      expect(cart.items.every((item) => !item.selected), isTrue);
    });

    test('clearCart removes every item', () {
      final cart = buildCartWithItem()
        ..addToCart(
          vendorName: 'Mang Juan',
          productName: 'Bangus',
          price: 90,
          weight: '1pc',
          pricePerKg: 'PHP 90/pc',
          image: 'bangus.png',
        );

      cart.clearCart();

      expect(cart.items, isEmpty);
      expect(cart.itemCount, 0);
      expect(cart.subtotal, 0);
    });
  });
}
