import 'package:flutter/material.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/core/services/order_service.dart';
import 'package:palengkego/features/cart/presentation/pages/shopping_cart_screen.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';
import 'order_details_screen.dart';
import 'track_order_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  _OrderTab _selectedTab = _OrderTab.all;

  @override
  void initState() {
    super.initState();
    globalOrders.addListener(_onOrdersChanged);
  }

  @override
  void dispose() {
    globalOrders.removeListener(_onOrdersChanged);
    super.dispose();
  }

  void _onOrdersChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context),
            _tabRow(),
            const Divider(height: 1, color: Color(0xFFE8ECE9)),
            Expanded(
              child: orders.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          _orderCard(context, orders[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<MarketOrder> _filteredOrders() {
    final orders = globalOrders.orders;

    switch (_selectedTab) {
      case _OrderTab.all:
        return orders;
      case _OrderTab.active:
        return orders
            .where(
              (order) =>
                  order.status == 'Pending' || order.status == 'Confirmed',
            )
            .toList();
      case _OrderTab.completed:
        return orders.where((order) => order.status == 'Completed').toList();
      case _OrderTab.cancelled:
        return orders.where((order) => order.status == 'Cancelled').toList();
    }
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Center(
        child: Text(
          'My Orders',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202020),
          ),
        ),
      ),
    );
  }

  Widget _tabRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Row(
        children: _OrderTab.values.map((tab) {
          final isSelected = _selectedTab == tab;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: Container(
                padding: const EdgeInsets.only(top: 8, bottom: 9),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF1B5546)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tab.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF1B5546)
                        : const Color(0xFF7A9C91),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _orderCard(BuildContext context, MarketOrder order) {
    final statusStyle = _statusStyle(order.status);
    final secondaryAction = _secondaryActionLabel(order.status);
    final primaryAction = _primaryActionLabel(order.status);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECE9)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 24, 40, 0.04),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  order.vendorImage,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 40,
                    height: 40,
                    color: const Color(0xFFE7ECE9),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 18,
                      color: Color(0xFF8A9A95),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.vendorName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF23342F),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Order ${order.id}',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8EB0A3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusStyle.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEDEFEA)),
          const SizedBox(height: 10),
          Text(
            _itemsPreview(order),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF89A89D),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _formatDateTime(order.placedAt),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9AB4AA),
                  ),
                ),
              ),
              Text(
                'PHP ${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF264A3D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (secondaryAction != null) ...[
                Expanded(
                  child: _actionButton(
                    label: secondaryAction,
                    onTap: () => _handleSecondaryAction(context, order),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: _actionButton(
                  label: primaryAction,
                  filled: secondaryAction == null,
                  trailingIcon: order.status == 'Confirmed'
                      ? Icons.local_shipping_outlined
                      : null,
                  onTap: () => _handlePrimaryAction(context, order),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onTap,
    bool filled = false,
    IconData? trailingIcon,
  }) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: filled ? const Color(0xFFF0F3F0) : Colors.white,
          foregroundColor: const Color(0xFF35554A),
          side: BorderSide(
            color: filled ? const Color(0xFFF0F3F0) : const Color(0xFFDDE5E0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 5),
              Icon(trailingIcon, size: 13),
            ] else if (filled) ...[
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded, size: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F5F3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 34,
              color: Color(0xFF9AB4AA),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No ${_selectedTab.label.toLowerCase()} orders yet',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF35554A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Placed orders will show up here automatically.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9AB4AA),
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(String status) {
    switch (status) {
      case 'Pending':
        return const _StatusStyle(
          background: Color(0xFFFFF4CC),
          foreground: Color(0xFFC78800),
        );
      case 'Confirmed':
        return const _StatusStyle(
          background: Color(0xFFE8F6E8),
          foreground: Color(0xFF6DA566),
        );
      case 'Completed':
        return const _StatusStyle(
          background: Color(0xFFE8F6E8),
          foreground: Color(0xFF6DA566),
        );
      case 'Cancelled':
        return const _StatusStyle(
          background: Color(0xFFFFE5E5),
          foreground: Color(0xFFEA7171),
        );
      default:
        return const _StatusStyle(
          background: Color(0xFFF2F4F3),
          foreground: Color(0xFF7B8F87),
        );
    }
  }

  String _itemsPreview(MarketOrder order) {
    return order.items
        .map((item) => '${item.productName}(${item.quantityLabel})')
        .join(', ');
  }

  String _primaryActionLabel(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Track Order';
      default:
        return 'View Details';
    }
  }

  String? _secondaryActionLabel(String status) {
    switch (status) {
      case 'Completed':
        return 'Reorder';
      default:
        return null;
    }
  }

  void _handlePrimaryAction(BuildContext context, MarketOrder order) {
    if (order.status == 'Confirmed' || order.status == 'Pending') {
      // Navigate to Track Order screen for active orders
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TrackOrderScreen(
            order: order,
            isPickup: order.isPickup,
          ),
        ),
      );
      return;
    }

    _showOrderDetails(context, order);
  }

  void _handleSecondaryAction(BuildContext context, MarketOrder order) {
    for (final item in order.items) {
      for (var count = 0; count < item.quantity; count++) {
        globalCart.addToCart(
          vendorName: order.vendorName,
          productName: item.productName,
          price: item.unitPrice,
          weight: item.weight,
          pricePerKg: item.pricePerKg,
          image: item.image,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${order.vendorName} items added back to cart.')),
    );
    // Cart is no longer a tab — push the cart screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ShoppingCartScreen()),
    );
  }

  void _showOrderDetails(BuildContext context, MarketOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(
          order: {
            'id': order.id,
            'vendorName': order.vendorName,
            'status': order.status,
            'statusDescription': order.status == 'Confirmed' ? 'Confirmed by vendor' : 'Preparing your fresh harvest',
            'estimatedArrival': '11:45 AM - 12:15 PM',
            'deliveryAddress': 'Unit 402, Greenview Residences, BGC, Taguig City',
            'vendorImage': order.items.isNotEmpty ? order.items.first.image : null,
            'vendorLocation': 'Stall #8-14, Wet Market Section',
            'items': order.items.map((item) => {
              'name': item.productName,
              'description': '${item.quantity}x • ${item.weight}',
              'price': '₱${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
              'unitPrice': '₱${item.pricePerKg}/kg',
              'image': item.image,
            }).toList(),
            'subtotal': '₱${order.total.toStringAsFixed(2)}',
            'deliveryFee': '₱49.00',
            'serviceFee': '₱10.00',
            'total': '₱${(order.total + 59).toStringAsFixed(2)}',
          },
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    return '${months[value.month - 1]} ${value.day}, ${value.year} • '
        '$hour:$minute $period';
  }
}

enum _OrderTab {
  all('All'),
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;

  const _OrderTab(this.label);
}

class _StatusStyle {
  final Color background;
  final Color foreground;

  const _StatusStyle({required this.background, required this.foreground});
}
