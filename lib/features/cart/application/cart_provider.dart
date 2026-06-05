import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/services/cart_service.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return globalCart;
});
