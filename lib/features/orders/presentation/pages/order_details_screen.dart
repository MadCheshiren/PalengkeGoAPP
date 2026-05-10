import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Order #${order['id'] ?? 'EH-82931'}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Status Timeline Bento Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Status Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Status',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order['statusDescription'] ?? 'Preparing your fresh harvest',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Color(0xFF9A3412),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'PRIORITY',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF9A3412),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Timeline
                      _buildTimeline(order['currentStatus'] ?? 'Preparing'),
                    ],
                  ),
                ),
              ),
            ),

            // Estimated Arrival
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        size: 20,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ESTIMATED ARRIVAL',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order['estimatedArrival'] ?? '11:45 AM - 12:15 PM',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Delivery Address
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DELIVERY ADDRESS',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order['deliveryAddress'] ?? 'Unit 402, Greenview Residences, BGC, Taguig City',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vendor Stall Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VENDOR STALL',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              order['vendorImage'] ?? 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=100&h=100&fit=crop',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 48,
                                height: 48,
                                color: const Color(0xFFF3F4F6),
                                child: const Icon(Icons.store, size: 24, color: Color(0xFF9CA3AF)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['vendorName'] ?? "Lola's Fresh Catch",
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order['vendorLocation'] ?? 'Stall #8-14, Wet Market Section',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Call vendor
                          },
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Call Vendor'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0B372B),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Items List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items List',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${(order['items'] as List?)?.length ?? 3} Items',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B372B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._buildItemsList(order['items'] ?? _defaultItems),
                  ],
                ),
              ),
            ),

            // Payment Method
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 20,
                          color: Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PAYMENT METHOD',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Cash on Delivery',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Order Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Subtotal', order['subtotal'] ?? '₱500.00'),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Delivery Fee', order['deliveryFee'] ?? '₱49.00'),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Service Fee', order['serviceFee'] ?? '₱10.00'),
                      const Divider(height: 24, color: Color(0xFFE5E7EB)),
                      _buildSummaryRow('Total', order['total'] ?? '₱559.00', isTotal: true),
                    ],
                  ),
                ),
              ),
            ),

            // Cancel Order Button (hidden for completed orders)
            if (order['status'] != 'Completed')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _showCancelDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B372B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        'Cancel Order',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final steps = [
      {'label': 'Order Placed', 'time': '10:30 AM, Oct 24', 'status': 'completed'},
      {'label': 'Confirmed', 'time': '10:35 AM, Oct 24', 'status': 'completed'},
      {'label': 'Preparing', 'time': 'Vendor is weighing items', 'status': 'active'},
      {'label': 'Out for Delivery', 'time': '', 'status': 'pending'},
      {'label': 'Completed', 'time': '', 'status': 'pending'},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = step['status'] == 'completed';
        final isActive = step['status'] == 'active';
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? const Color(0xFF0B372B)
                        : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : isActive
                          ? const Icon(Icons.more_horiz, size: 14, color: Colors.white)
                          : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? const Color(0xFF0B372B) : const Color(0xFFE5E7EB),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['label']!,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isActive
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (step['time']!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      step['time']!,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isCompleted
                            ? const Color(0xFF6B7280)
                            : isActive
                                ? const Color(0xFF0B372B)
                                : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<Widget> _buildItemsList(List<dynamic> items) {
    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'] ?? 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=100&h=100&fit=crop',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(Icons.image, size: 24, color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Fresh Bangus',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['description'] ?? '2 Kilos • Cleaned & Gutted',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['price'] ?? '₱420.00',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  item['unitPrice'] ?? '₱210/kg',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Order?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No, Keep It',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Cancel order logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(fontFamily: 'PlusJakartaSans'),
            ),
          ),
        ],
      ),
    );
  }

  // Default items for demo
  final List<Map<String, dynamic>> _defaultItems = [
    {
      'name': 'Fresh Bangus (Milkfish)',
      'description': '2 Kilos • Cleaned & Gutted',
      'price': '₱420.00',
      'unitPrice': '₱210/kg',
    },
    {
      'name': 'Organic Tomatoes',
      'description': '500 Grams • Medium Size',
      'price': '₱45.00',
      'unitPrice': '₱90/kg',
    },
    {
      'name': 'Red Onions',
      'description': '250 Grams',
      'price': '₱35.00',
      'unitPrice': '₱140/kg',
    },
  ];
}
