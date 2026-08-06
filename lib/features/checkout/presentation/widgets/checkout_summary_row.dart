import 'package:flutter/material.dart';

class CheckoutSummaryRow extends StatelessWidget {
  const CheckoutSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.highlighted = false,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool highlighted;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? const Color(0xFF0B372B) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: (highlighted || isBold)
                ? const Color(0xFF0B372B)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
