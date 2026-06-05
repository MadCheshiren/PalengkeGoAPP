import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';

class AddToCartBottomSheet extends ConsumerStatefulWidget {
  final String vendorName;
  final Map<String, dynamic> product;

  const AddToCartBottomSheet({
    super.key,
    required this.vendorName,
    required this.product,
  });

  static Future<void> show(
    BuildContext context, {
    required String vendorName,
    required Map<String, dynamic> product,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
      builder: (context) =>
          AddToCartBottomSheet(vendorName: vendorName, product: product),
    );
  }

  @override
  ConsumerState<AddToCartBottomSheet> createState() =>
      _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends ConsumerState<AddToCartBottomSheet> {
  late final List<String> _weights;
  late String _selectedWeight;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _weights = _resolveWeights(widget.product);
    _selectedWeight = _weights.first;
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = (widget.product['price'] as num?)?.toDouble() ?? 0;
    final selectedMultiplier = _weightMultiplier(_selectedWeight);
    final selectedUnitPrice = basePrice * selectedMultiplier;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, -4),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.product['imageUrl'] as String? ?? '',
                    width: 107,
                    height: 99,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      width: 107,
                      height: 99,
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(
                        Icons.image_rounded,
                        size: 28,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product['name'] as String? ?? 'Product',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B372B),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _priceLabel(basePrice),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6D9773),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _weights.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _weights.length <= 2 ? 2 : 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 18,
                childAspectRatio: 2.32,
              ),
              itemBuilder: (context, index) {
                final weight = _weights[index];
                final isSelected = weight == _selectedWeight;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeight = weight;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0C3A2D)
                          : const Color(0xFFF1F5F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0C3A2D)
                            : const Color(0xFFF3F4F6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color.fromRGBO(0, 0, 0, 0.25)
                              : const Color.fromRGBO(0, 0, 0, 0.18),
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      weight,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF0C3A2D),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Quantity',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F2),
                    border: Border.all(color: const Color(0xFFE5E7E6)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _roundQuantityButton(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          if (_quantity > 1) {
                            setState(() {
                              _quantity--;
                            });
                          }
                        },
                        foreground: const Color(0xFF6D9773),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          _quantity.toString(),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B372B),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Text(
                          'kg',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      _roundQuantityButton(
                        icon: Icons.add_rounded,
                        onTap: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                        background: const Color(0xFF0C3A2D),
                        foreground: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (!mounted) return;
                    final cart = ref.read(cartServiceProvider);
                    cart.addToCart(
                    vendorName: widget.vendorName,
                    productName: widget.product['name'] as String? ?? 'Item',
                    price: selectedUnitPrice,
                    weight: _selectedWeight,
                    pricePerKg: _priceLabel(basePrice),
                    image:
                        widget.product['imageUrl'] as String? ??
                        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&h=300&fit=crop',
                  );

                    final latestIndex = cart.items.lastIndexWhere(
                    (item) =>
                        item.vendorName == widget.vendorName &&
                        item.productName ==
                            (widget.product['name'] as String? ?? 'Item') &&
                        item.weight == _selectedWeight,
                  );

                    if (latestIndex >= 0) {
                      cart.updateQuantity(latestIndex, _quantity);
                    }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product['name']} added to cart',
                        style: const TextStyle(fontFamily: 'PlusJakartaSans'),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C3A2D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: const Color.fromRGBO(11, 55, 43, 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Text(
                  'Add to cart',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    Color background = Colors.transparent,
    required Color foreground,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: foreground),
      ),
    );
  }

  List<String> _resolveWeights(Map<String, dynamic> product) {
    final explicit = product['availableWeights'];
    if (explicit is List) {
      final weights = explicit.whereType<String>().toList();
      if (weights.isNotEmpty) {
        return weights;
      }
    }

    final name = (product['name'] as String? ?? '').toLowerCase();
    final category = (product['category'] as String? ?? '').toLowerCase();

    if (name.contains('latundan') ||
        name.contains('banana') ||
        category.contains('fruit')) {
      return ['1kg', '1/2', '1/4'];
    }

    return ['1kg', '1/2', '1/4', '1/8'];
  }

  double _weightMultiplier(String weight) {
    switch (weight) {
      case '1/2':
        return 0.5;
      case '1/4':
        return 0.25;
      case '1/8':
        return 0.125;
      case '1kg':
      default:
        return 1;
    }
  }

  String _priceLabel(double basePrice) {
    return 'PHP ${basePrice.toInt()}/kg';
  }
}
