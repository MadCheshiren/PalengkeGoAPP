class VendorOrderItem {
  VendorOrderItem({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.time,
    required this.status,
    required this.deliveryType,
  });

  final String id;
  final String customer;
  final List<String> items;
  final String total;
  final String time;
  String status;
  final String deliveryType;
}
