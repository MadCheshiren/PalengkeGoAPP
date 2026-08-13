import 'package:flutter/material.dart';

/// Confirmation dialog before deleting a product. Returns true when confirmed.
Future<bool?> showVendorProductDeleteDialog(
  BuildContext context, {
  required String productName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Delete Product?',
        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
      ),
      content: Text(
        'Are you sure you want to delete "$productName"? This will remove it from your inventory and the customer view immediately.',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF6B7280),
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
