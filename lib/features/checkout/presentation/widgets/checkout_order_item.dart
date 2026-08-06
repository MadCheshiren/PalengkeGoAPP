import 'package:flutter/material.dart';
import 'package:palengkego/core/presentation/widgets/adaptive_image.dart';
import 'package:palengkego/features/cart/domain/cart_item.dart';

class CheckoutOrderItem extends StatelessWidget {
  const CheckoutOrderItem({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final unit = item.unit;
    final priceLabel = '${item.price}/$unit';
    final quantityLabel = item.quantityLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AdaptiveImage(
              item.image.isNotEmpty ? item.image : null,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              placeholder: Container(
                width: 48,
                height: 48,
                color: const Color(0xFFE5E7EB),
                child: const Icon(
                  Icons.image_rounded,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B372B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$quantityLabel • $priceLabel',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₱${item.total.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
